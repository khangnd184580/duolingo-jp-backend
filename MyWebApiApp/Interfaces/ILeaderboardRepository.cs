using MyWebApiApp.DTOs.Leaderboard;

namespace MyWebApiApp.Interfaces
{
    public interface ILeaderboardRepository
    {
        Task<WeeklyLeaderboardResponse> GetWeeklyGlobalAsync(string currentUserId);
        Task<WeeklyLeaderboardResponse> GetWeeklyFriendsAsync(string currentUserId);
    }
}
