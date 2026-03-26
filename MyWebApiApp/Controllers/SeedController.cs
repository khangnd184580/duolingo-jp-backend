using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;

namespace MyWebApiApp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SeedController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public SeedController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Find missing QuestionOptions by comparing with expected range
        /// </summary>
        [HttpGet("check-missing-options")]
        public async Task<IActionResult> CheckMissingOptions()
        {
            try
            {
                // Get all existing OptionIds
                var existingIds = await _context.QuestionOptions
                    .Select(q => q.OptionId)
                    .OrderBy(id => id)
                    .ToListAsync();

                // Find missing IDs in range 1-2048
                var missingIds = new List<int>();
                for (int i = 1; i <= 2048; i++)
                {
                    if (!existingIds.Contains(i))
                    {
                        missingIds.Add(i);
                    }
                }

                return Ok(new
                {
                    total = existingIds.Count,
                    expected = 2048,
                    missing = missingIds.Count,
                    missingIds = missingIds,
                    firstMissing = missingIds.Take(10),
                    lastMissing = missingIds.Skip(Math.Max(0, missingIds.Count - 10)).Take(10)
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        /// <summary>
        /// Import specific QuestionOptions by IDs
        /// </summary>
        [HttpPost("import-missing-options")]
        public async Task<IActionResult> ImportMissingOptions([FromBody] List<int> optionIds)
        {
            try
            {
                var sqlFilePath = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "Scripts",
                    "question_options_only.sql"
                );

                if (!System.IO.File.Exists(sqlFilePath))
                {
                    return NotFound(new { error = "SQL file not found" });
                }

                var sqlContent = await System.IO.File.ReadAllTextAsync(sqlFilePath);
                
                int imported = 0;
                foreach (var optionId in optionIds)
                {
                    // Find the INSERT statement for this OptionId
                    var pattern = $"({optionId},";
                    var lines = sqlContent.Split('\n');
                    var matchingLine = lines.FirstOrDefault(l => l.Trim().StartsWith(pattern));
                    
                    if (matchingLine != null)
                    {
                        var values = matchingLine.Trim().TrimEnd(',');
                        var insertSql = $"INSERT INTO \"QuestionOptions\" (\"OptionId\", \"QuestionId\", \"OptionText\", \"IsCorrect\") VALUES {values};";
                        
                        try
                        {
                            await _context.Database.ExecuteSqlRawAsync(insertSql);
                            imported++;
                        }
                        catch { }
                    }
                }

                return Ok(new
                {
                    message = $"Imported {imported} missing options",
                    imported,
                    stats = await GetCurrentStats()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        /// <summary>
        /// Import ONLY QuestionOptions in small batches (fixes missing 512 options)
        /// </summary>
        [HttpPost("import-question-options-batched")]
        public async Task<IActionResult> ImportQuestionOptionsBatched()
        {
            try
            {
                var sqlFilePath = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "Scripts",
                    "question_options_only.sql"
                );

                if (!System.IO.File.Exists(sqlFilePath))
                {
                    return NotFound(new
                    {
                        error = "SQL file not found",
                        path = sqlFilePath,
                        currentDir = Directory.GetCurrentDirectory()
                    });
                }

                var sqlContent = await System.IO.File.ReadAllTextAsync(sqlFilePath);

                // Delete existing first
                await _context.Database.ExecuteSqlRawAsync("DELETE FROM \"QuestionOptions\"");

                // Extract all INSERT statements
                var lines = sqlContent.Split('\n')
                    .Where(l => l.Trim().StartsWith("(") && l.Trim().EndsWith(","))
                    .Select(l => l.Trim().TrimEnd(','))
                    .ToList();

                int total = lines.Count;
                int imported = 0;
                int batchSize = 50;

                // Insert in batches
                for (int i = 0; i < lines.Count; i += batchSize)
                {
                    var batch = lines.Skip(i).Take(batchSize).ToList();
                    var batchSql = $"INSERT INTO \"QuestionOptions\" (\"OptionId\", \"QuestionId\", \"OptionText\", \"IsCorrect\") VALUES {string.Join(",\n", batch)};";

                    try
                    {
                        await _context.Database.ExecuteSqlRawAsync(batchSql);
                        imported += batch.Count;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Batch {i}-{i + batchSize} failed: {ex.Message}");
                    }
                }

                // Update sequence
                await _context.Database.ExecuteSqlRawAsync("SELECT setval('\"QuestionOptions_OptionId_seq\"', (SELECT MAX(\"OptionId\") FROM \"QuestionOptions\") + 1)");

                return Ok(new
                {
                    message = $"QuestionOptions imported: {imported}/{total}",
                    imported,
                    total,
                    stats = await GetCurrentStats()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Import ONLY QuestionOptions (fixes missing 512 options)
        /// </summary>
        [HttpPost("import-question-options-only")]
        public async Task<IActionResult> ImportQuestionOptionsOnly()
        {
            try
            {
                var sqlFilePath = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "Scripts",
                    "question_options_only.sql"
                );

                if (!System.IO.File.Exists(sqlFilePath))
                {
                    return NotFound(new
                    {
                        error = "SQL file not found",
                        path = sqlFilePath
                    });
                }

                var sqlContent = await System.IO.File.ReadAllTextAsync(sqlFilePath);

                // Split and execute
                var statements = sqlContent
                    .Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrWhiteSpace(s) && !s.StartsWith("--"))
                    .ToList();

                int executed = 0;
                foreach (var statement in statements)
                {
                    try
                    {
                        await _context.Database.ExecuteSqlRawAsync(statement);
                        executed++;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Failed statement: {ex.Message}");
                    }
                }

                return Ok(new
                {
                    message = "QuestionOptions imported successfully!",
                    executed,
                    stats = await GetCurrentStats()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Import ONLY Shop Items (fixes missing items)
        /// </summary>
        [HttpPost("import-items-only")]
        public async Task<IActionResult> ImportItemsOnly()
        {
            try
            {
                // Delete existing items first
                await _context.Database.ExecuteSqlRawAsync("DELETE FROM \"Items\"");

                // Insert all 15 items with IsActive = true
                var itemsSql = @"
INSERT INTO ""Items"" (""ItemId"", ""Name"", ""Description"", ""Price"", ""Category"", ""ImageUrl"", ""IsActive"") VALUES
(1, 'Streak Freeze', 'Protect your streak for one day if you forget to practice', 200, 'PowerUp', '/images/items/streak-freeze.png', true),
(2, 'Heart Refill', 'Instantly refill all your hearts', 350, 'PowerUp', '/images/items/heart-refill.png', true),
(3, 'Double XP Boost', 'Earn 2x XP for 15 minutes', 150, 'PowerUp', '/images/items/double-xp.png', true),
(4, 'Timer Boost', 'Get extra time on timed challenges', 100, 'PowerUp', '/images/items/timer-boost.png', true),
(5, 'Golden Owl Avatar', 'Show off with a premium avatar', 500, 'Cosmetic', '/images/items/golden-owl.png', true),
(6, 'Cherry Blossom Theme', 'Beautiful sakura-themed interface', 800, 'Cosmetic', '/images/items/sakura-theme.png', true),
(7, 'Samurai Avatar', 'Traditional samurai warrior avatar', 600, 'Cosmetic', '/images/items/samurai-avatar.png', true),
(8, 'Ninja Avatar', 'Stealthy ninja avatar', 600, 'Cosmetic', '/images/items/ninja-avatar.png', true),
(9, 'Premium Monthly', 'Unlimited hearts, no ads, offline lessons', 1200, 'Subscription', '/images/items/premium.png', true),
(10, 'Study Pack (5 Hearts)', 'Get 5 extra hearts instantly', 50, 'Consumable', '/images/items/heart-pack.png', true),
(11, 'Weekend Streak Repair', 'Repair your streak if broken within 7 days', 400, 'PowerUp', '/images/items/streak-repair.png', true),
(12, 'Legendary Chest', 'Mystery box with random rewards', 1000, 'Mystery', '/images/items/legendary-chest.png', true),
(13, 'XP Boost Bundle', '3x Double XP Boosts', 400, 'Bundle', '/images/items/xp-bundle.png', true),
(14, 'Heart Protection', 'Lose only half hearts for wrong answers (1 hour)', 250, 'PowerUp', '/images/items/heart-protection.png', true),
(15, 'Lucky Charm', 'Higher chance of getting rare items', 700, 'Special', '/images/items/lucky-charm.png', true);";

                await _context.Database.ExecuteSqlRawAsync(itemsSql);

                // Update sequence
                await _context.Database.ExecuteSqlRawAsync("SELECT setval('\"Items_ItemId_seq\"', 15)");

                return Ok(new
                {
                    message = "Items imported successfully!",
                    stats = await GetCurrentStats()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Auto-import all data from embedded SQL file
        /// Just call this endpoint - no file upload needed!
        /// </summary>
        [HttpPost("auto-import")]
        public async Task<IActionResult> AutoImport()
        {
            try
            {
                var sqlFilePath = Path.Combine(
                    Directory.GetCurrentDirectory(), 
                    "Scripts", 
                    "full_data_export_postgresql.sql"
                );

                if (!System.IO.File.Exists(sqlFilePath))
                {
                    return NotFound(new 
                    { 
                        error = "SQL file not found",
                        path = sqlFilePath,
                        currentDir = Directory.GetCurrentDirectory()
                    });
                }

                var sqlContent = await System.IO.File.ReadAllTextAsync(sqlFilePath);
                
                // Split and execute statements
                var statements = sqlContent
                    .Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrWhiteSpace(s) 
                            && !s.StartsWith("--") 
                            && !s.StartsWith("SET ")
                            && !s.Contains("PERFORM setval"))
                    .ToList();

                int executed = 0;
                int failed = 0;
                var sampleErrors = new List<string>();

                foreach (var statement in statements)
                {
                    try
                    {
                        await _context.Database.ExecuteSqlRawAsync(statement);
                        executed++;
                    }
                    catch (Exception ex)
                    {
                        failed++;
                        if (sampleErrors.Count < 5)
                        {
                            sampleErrors.Add($"{statement.Substring(0, Math.Min(60, statement.Length))}... => {ex.Message}");
                        }
                    }
                }

                return Ok(new 
                { 
                    message = $"Import completed! {executed} statements executed, {failed} failed",
                    executed,
                    failed,
                    sampleErrors,
                    stats = await GetCurrentStats()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Import data by executing SQL file (upload file via form)
        /// </summary>
        [HttpPost("upload-sql")]
        public async Task<IActionResult> UploadSqlFile(IFormFile sqlFile)
        {
            if (sqlFile == null || sqlFile.Length == 0)
            {
                return BadRequest(new { error = "No file uploaded" });
            }

            try
            {
                using var reader = new StreamReader(sqlFile.OpenReadStream());
                var sqlContent = await reader.ReadToEndAsync();

                // Split and execute statements
                var statements = sqlContent
                    .Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrWhiteSpace(s) 
                            && !s.StartsWith("--") 
                            && !s.StartsWith("SET session_replication_role")
                            && !s.StartsWith("PERFORM setval"))
                    .ToList();

                int executed = 0;
                foreach (var statement in statements)
                {
                    try
                    {
                        await _context.Database.ExecuteSqlRawAsync(statement);
                        executed++;
                    }
                    catch (Exception ex)
                    {
                        // Log but continue
                        Console.WriteLine($"Failed: {statement.Substring(0, Math.Min(50, statement.Length))} - {ex.Message}");
                    }
                }

                return Ok(new 
                { 
                    message = $"Executed {executed} statements",
                    stats = await GetCurrentStats()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        private async Task<object> GetCurrentStats()
        {
            return new
            {
                levels = await _context.Set<Models.Level>().CountAsync(),
                topics = await _context.Set<Models.Topic>().CountAsync(),
                lessons = await _context.Lessons.CountAsync(),
                questions = await _context.Questions.CountAsync(),
                questionOptions = await _context.QuestionOptions.CountAsync(),
                items = await _context.Items.CountAsync(),
                achievements = await _context.Achievements.CountAsync()
            };
        }

        /// <summary>
        /// Execute SQL batch from request body (splits by semicolon)
        /// </summary>
        [HttpPost("execute-sql-batch")]
        public async Task<IActionResult> ExecuteSqlBatch([FromBody] SqlBatchRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.SqlContent))
                {
                    return BadRequest(new { error = "SQL content is empty" });
                }

                // Split SQL into individual statements
                var statements = request.SqlContent
                    .Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => s.Trim())
                    .Where(s => !string.IsNullOrWhiteSpace(s) && !s.StartsWith("--"))
                    .ToList();

                int executed = 0;
                int failed = 0;
                var errors = new List<string>();

                foreach (var statement in statements)
                {
                    try
                    {
                        await _context.Database.ExecuteSqlRawAsync(statement);
                        executed++;
                    }
                    catch (Exception ex)
                    {
                        failed++;
                        if (errors.Count < 10) // Only keep first 10 errors
                        {
                            errors.Add($"{statement.Substring(0, Math.Min(50, statement.Length))}... - {ex.Message}");
                        }
                    }
                }

                return Ok(new 
                { 
                    message = $"Executed {executed} statements, {failed} failed",
                    executed,
                    failed,
                    errors = errors.Take(5),
                    stats = new
                    {
                        levels = await _context.Set<Models.Level>().CountAsync(),
                        topics = await _context.Set<Models.Topic>().CountAsync(),
                        lessons = await _context.Lessons.CountAsync(),
                        questions = await _context.Questions.CountAsync(),
                        questionOptions = await _context.QuestionOptions.CountAsync(),
                        items = await _context.Items.CountAsync(),
                        achievements = await _context.Achievements.CountAsync()
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        public class SqlBatchRequest
        {
            public string SqlContent { get; set; } = string.Empty;
        }

        /// <summary>
        /// Execute SQL directly from request body
        /// Use this to import data by pasting SQL content
        /// </summary>
        [HttpPost("execute-sql")]
        public async Task<IActionResult> ExecuteSql([FromBody] string sqlContent)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(sqlContent))
                {
                    return BadRequest(new { error = "SQL content is empty" });
                }

                // Execute the SQL
                await _context.Database.ExecuteSqlRawAsync(sqlContent);

                return Ok(new 
                { 
                    message = "SQL executed successfully!",
                    stats = new
                    {
                        levels = await _context.Set<Models.Level>().CountAsync(),
                        topics = await _context.Set<Models.Topic>().CountAsync(),
                        lessons = await _context.Lessons.CountAsync(),
                        questions = await _context.Questions.CountAsync(),
                        questionOptions = await _context.QuestionOptions.CountAsync(),
                        items = await _context.Items.CountAsync(),
                        achievements = await _context.Achievements.CountAsync()
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Seed database with data from SQL Server export
        /// WARNING: This will DELETE all existing data!
        /// </summary>
        [HttpPost("import-from-local")]
        public async Task<IActionResult> ImportFromLocalDatabase()
        {
            try
            {
                // Read the SQL file
                var sqlFilePath = Path.Combine(Directory.GetCurrentDirectory(), "Scripts", "full_data_export_postgresql.sql");
                
                if (!System.IO.File.Exists(sqlFilePath))
                {
                    return NotFound(new { error = "SQL file not found", path = sqlFilePath });
                }

                var sqlContent = await System.IO.File.ReadAllTextAsync(sqlFilePath);

                // Execute the SQL
                await _context.Database.ExecuteSqlRawAsync(sqlContent);

                return Ok(new 
                { 
                    message = "Database seeded successfully!",
                    stats = new
                    {
                        levels = await _context.Set<Models.Level>().CountAsync(),
                        topics = await _context.Set<Models.Topic>().CountAsync(),
                        lessons = await _context.Lessons.CountAsync(),
                        questions = await _context.Questions.CountAsync(),
                        questionOptions = await _context.QuestionOptions.CountAsync(),
                        items = await _context.Items.CountAsync(),
                        achievements = await _context.Achievements.CountAsync()
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Get current database statistics
        /// </summary>
        [HttpGet("stats")]
        public async Task<IActionResult> GetStats()
        {
            try
            {
                return Ok(new
                {
                    levels = await _context.Set<Models.Level>().CountAsync(),
                    topics = await _context.Set<Models.Topic>().CountAsync(),
                    lessons = await _context.Lessons.CountAsync(),
                    questions = await _context.Questions.CountAsync(),
                    questionOptions = await _context.QuestionOptions.CountAsync(),
                    items = await _context.Items.CountAsync(),
                    achievements = await _context.Achievements.CountAsync(),
                    users = await _context.Users.CountAsync()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }
}
