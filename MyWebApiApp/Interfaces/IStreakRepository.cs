using MyWebApiApp.DTOs.Streak;

namespace MyWebApiApp.Interfaces
{
    public interface IStreakRepository
    {
        Task UpdateStreakAsync(string userId);
        Task<StreakResponse?> GetStreakAsync(string userId);
    }
}
