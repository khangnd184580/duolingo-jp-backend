using MyWebApiApp.Data;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc;

namespace MyWebApiApp.Repository
{
    public class AchievementRepository : IAchievementRepository
    {
        private readonly ApplicationDbContext _context;

        public AchievementRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<Achievement>> GetAllAchievementsAsync()
        {
            return await _context.Achievements.ToListAsync();
        }

        public async Task<UserAchievement?> GetUserAchievementAsync(string userId, int achievementId)
        {
            return await _context.UserAchievements
                .FirstOrDefaultAsync(x => x.UserId == userId && x.AchievementId == achievementId);
        }

        public async Task<List<UserAchievement>> GetUserAchievementsAsync(string userId)
        {
            return await _context.UserAchievements
                .Include(x => x.Achievement)
                .Where(x => x.UserId == userId)
                .ToListAsync();
        }

        public async Task<bool> IsAchievementUnlockedAsync(string userId, int achievementId)
        {
            return await _context.UserAchievements
                .AnyAsync(x => x.UserId == userId && x.AchievementId == achievementId);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }

        public async Task UnlockAchievementAsync(string userId, int achievementId)
        {
            var userAchievement = new UserAchievement
            {
                UserId = userId,
                AchievementId = achievementId,
                UnlockedAt = DateTime.UtcNow,
                IsClaimed = false
            };

            await _context.UserAchievements.AddAsync(userAchievement);
        }
    }
}
