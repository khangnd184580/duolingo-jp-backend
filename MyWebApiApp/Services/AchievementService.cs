using MyWebApiApp.Data;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;
using Microsoft.EntityFrameworkCore;

namespace MyWebApiApp.Services
{
    public class AchievementService : IAchievementService
    {
        private readonly ApplicationDbContext _context;

        public AchievementService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task CheckLessonAchievementsAsync(string userId)
        {
            var achievements = await _context.Achievements.ToListAsync();
            if (!achievements.Any())
                return;

            var lessonCompleted = await _context.UserProgress
                .CountAsync(x => x.UserId == userId && x.IsCompleted);

            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null)
                return;

            foreach (var achievement in achievements)
            {
                bool alreadyUnlocked = await _context.UserAchievements
                    .AnyAsync(x => x.UserId == userId && x.AchievementId == achievement.AchievementId);

                if (alreadyUnlocked)
                    continue;

                var currentValue = achievement.AchievementType switch
                {
                    "LESSON_COMPLETE" => lessonCompleted,
                    "TOTAL_XP" => user.TotalXP,
                    "STREAK_DAYS" => user.CurrentStreak,
                    _ => 0
                };

                if (currentValue >= achievement.RequiredValue)
                {
                    _context.UserAchievements.Add(new UserAchievement
                    {
                        UserId = userId,
                        AchievementId = achievement.AchievementId,
                        UnlockedAt = DateTime.UtcNow,
                        IsClaimed = false
                    });
                }
            }

            await _context.SaveChangesAsync();
        }
    }
}
