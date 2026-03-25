using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using System;
using System.Threading.Tasks;

namespace MyWebApiApp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HealthController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public HealthController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            try
            {
                return Ok(new
                {
                    status = "OK",
                    message = "API is running",
                    timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    status = "ERROR",
                    message = ex.Message
                });
            }
        }

        [HttpGet("db")]
        public async Task<IActionResult> CheckDatabase()
        {
            try
            {
                var canConnect = await _context.Database.CanConnectAsync();
                
                if (canConnect)
                {
                    var dbName = _context.Database.GetDbConnection().Database;
                    var serverName = _context.Database.GetDbConnection().DataSource;
                    
                    return Ok(new
                    {
                        status = "OK",
                        message = "Database connection successful",
                        database = dbName,
                        server = serverName,
                        timestamp = DateTime.UtcNow
                    });
                }
                else
                {
                    return StatusCode(500, new
                    {
                        status = "ERROR",
                        message = "Cannot connect to database"
                    });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    status = "ERROR",
                    message = $"Database connection failed: {ex.Message}",
                    innerException = ex.InnerException?.Message
                });
            }
        }

        [HttpGet("db/tables")]
        public async Task<IActionResult> CheckTables()
        {
            try
            {
                var canConnect = await _context.Database.CanConnectAsync();
                
                if (!canConnect)
                {
                    return StatusCode(500, new
                    {
                        status = "ERROR",
                        message = "Cannot connect to database"
                    });
                }

                var tableInfo = new
                {
                    hasUsers = await _context.Users.AnyAsync(),
                    userCount = await _context.Users.CountAsync()
                };

                return Ok(new
                {
                    status = "OK",
                    message = "Database tables accessible",
                    data = tableInfo,
                    timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    status = "ERROR",
                    message = $"Error accessing database tables: {ex.Message}",
                    innerException = ex.InnerException?.Message
                });
            }
        }
    }
}
