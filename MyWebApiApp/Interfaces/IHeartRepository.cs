using MyWebApiApp.DTOs.Heart;

namespace MyWebApiApp.Interfaces
{
    public interface IHeartRepository
    {
        Task<HeartResponse?> GetHeartsAsync(string userId);
        Task<bool> LoseHeartAsync(string userId);
    }
}
