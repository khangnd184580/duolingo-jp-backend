using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;
using MyWebApiApp.Repository;
using System.Security.Claims;

namespace MyWebApiApp.Controllers
{
    [Route("api/achievements")]
    [ApiController]
    [Authorize]
    public class AchievementController : ControllerBase
    {
        private readonly IAchievementRepository _achievementRepo;
        private readonly UserManager<AppUser> _userManager;
        private readonly ApplicationDbContext _context;

        public AchievementController(
            IAchievementRepository achievementRepo,
            UserManager<AppUser> userManager,
            ApplicationDbContext context)
        {
            _achievementRepo = achievementRepo;
            _userManager = userManager;
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAchievements()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var achievements = await _achievementRepo.GetAllAchievementsAsync();
            var user = await _userManager.FindByIdAsync(userId);
            var completedLessons = await _context.UserProgress.CountAsync(x => x.UserId == userId && x.IsCompleted);
            var userAchievements = await _achievementRepo.GetUserAchievementsAsync(userId);

            // Auto-unlock achievements immediately when progress already meets target
            // (prevents stale "4/1 but still locked" state).
            var unlockedSet = userAchievements.Select(x => x.AchievementId).ToHashSet();
            foreach (var achievement in achievements)
            {
                var progress = GetProgressValue(achievement.AchievementType, user, completedLessons);
                if (progress >= achievement.RequiredValue && !unlockedSet.Contains(achievement.AchievementId))
                {
                    await _achievementRepo.UnlockAchievementAsync(userId, achievement.AchievementId);
                }
            }
            await _achievementRepo.SaveChangesAsync();
            userAchievements = await _achievementRepo.GetUserAchievementsAsync(userId);

            var result = achievements.Select(a => new
            {
                a.AchievementId,
                a.Name,
                a.Description,
                a.IconUrl,
                a.RequiredValue,
                a.AchievementType,
                progressValue = GetProgressValue(a.AchievementType, user, completedLessons),
                progressPercent = GetProgressPercent(a, user, completedLessons),
                unlocked = userAchievements.Any(ua => ua.AchievementId == a.AchievementId),
                isClaimed = userAchievements.Any(ua => ua.AchievementId == a.AchievementId && ua.IsClaimed),
                rewardGems = 10
            });

            return Ok(result);
        }

        [HttpPost("{achievementId}/claim")]
        public async Task<IActionResult> ClaimAchievement(int achievementId)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var userAchievement = await _achievementRepo
                .GetUserAchievementAsync(userId, achievementId);

            if (userAchievement == null)
            {
                return BadRequest("Achievement not unlocked");
            }

            if (userAchievement.IsClaimed)
            {
                return BadRequest("Achievement reward already claimed");
            }

            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
            {
                return NotFound("User not found");
            }

            const int rewardXP = 0;
            const int rewardGems = 10;
            user.Gems += rewardGems;

            userAchievement.IsClaimed = true;
            userAchievement.ClaimedAt = DateTime.UtcNow;
            await _achievementRepo.SaveChangesAsync();
            await _userManager.UpdateAsync(user);

            return Ok(new
            {
                success = true,
                message = "Nhận 10 kim cương thành công",
                rewardXP,
                rewardGems
            });
        }

        private static int GetProgressValue(string achievementType, AppUser? user, int completedLessons)
        {
            if (user == null) return 0;

            return achievementType switch
            {
                "LESSON_COMPLETE" => completedLessons,
                "TOTAL_XP" => user.TotalXP,
                "STREAK_DAYS" => user.CurrentStreak,
                _ => 0
            };
        }

        private static double GetProgressPercent(Achievement achievement, AppUser? user, int completedLessons)
        {
            var progressValue = GetProgressValue(achievement.AchievementType, user, completedLessons);
            if (achievement.RequiredValue <= 0) return 0;
            var percent = (double)progressValue / achievement.RequiredValue;
            return Math.Min(1.0, Math.Max(0.0, percent));
        }
    }
}
