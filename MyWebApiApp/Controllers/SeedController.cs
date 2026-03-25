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
