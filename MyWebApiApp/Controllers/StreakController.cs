using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.DTOs;
using MyWebApiApp.Interfaces;
using System.Security.Claims;

namespace MyWebApiApp.Controllers
{
    [Route("api/streak")]
    [ApiController]
    [Authorize]
    public class StreakController : ControllerBase
    {
        private readonly IStreakRepository _streakRepo;

        public StreakController(IStreakRepository streakRepo)
        {
            _streakRepo = streakRepo;
        }

        [HttpGet]
        public async Task<IActionResult> GetStreak()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (userId == null)
                return Unauthorized();

            var streak = await _streakRepo.GetStreakAsync(userId);

            if (streak == null)
                return NotFound();

            return Ok(streak);
        }
    }
}
