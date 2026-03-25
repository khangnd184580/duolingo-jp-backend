using Microsoft.AspNetCore.Mvc;
using MyWebApiApp.Models;
using System.Threading.Tasks;
namespace MyWebApiApp.Interfaces
{
    public interface IAchievementRepository
    {
        Task<List<Achievement>> GetAllAchievementsAsync();
        Task<List<UserAchievement>> GetUserAchievementsAsync(string userId);
        Task<bool> IsAchievementUnlockedAsync(string userId, int achievementId);
        Task UnlockAchievementAsync(string userId, int achievementId);
        Task<UserAchievement?> GetUserAchievementAsync(string userId, int achievementId);
        Task SaveChangesAsync();
    }
}
