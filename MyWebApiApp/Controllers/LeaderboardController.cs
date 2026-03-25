using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyWebApiApp.Interfaces;
using System.Security.Claims;

namespace MyWebApiApp.Controllers
{
    [Route("api/leaderboard")]
    [ApiController]
    [Authorize]
    public class LeaderboardController : ControllerBase
    {
        private readonly ILeaderboardRepository _leaderboard;

        public LeaderboardController(ILeaderboardRepository leaderboard)
        {
            _leaderboard = leaderboard;
        }

        private string GetUserId() =>
            User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;

        /// <summary>
        /// XP tuần (UTC+7): tổng EarnedXP từ UserProgress trong tuần hiện tại — tất cả user.
        /// </summary>
        [HttpGet("weekly/global")]
        public async Task<IActionResult> GetWeeklyGlobal()
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var data = await _leaderboard.GetWeeklyGlobalAsync(userId);
            return Ok(data);
        }

        /// <summary>
        /// XP tuần — chỉ bạn bè (đã chấp nhận) và bản thân.
        /// </summary>
        [HttpGet("weekly/friends")]
        public async Task<IActionResult> GetWeeklyFriends()
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var data = await _leaderboard.GetWeeklyFriendsAsync(userId);
            return Ok(data);
        }

        /// <summary>Alias: cùng dữ liệu với weekly/global.</summary>
        [HttpGet]
        public async Task<IActionResult> GetLeaderboard()
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            return Ok(await _leaderboard.GetWeeklyGlobalAsync(userId));
        }
    }
}
