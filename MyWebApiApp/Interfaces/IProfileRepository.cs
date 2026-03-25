using MyWebApiApp.DTOs.Profile;

namespace MyWebApiApp.Interfaces
{
    public interface IProfileRepository
    {
        Task<ProfileResponse?> GetProfileAsync(string userId);
        Task<ProfileResponse?> UpdateProfileAsync(string userId, UpdateProfileRequest request);
        //Task<ProfileResponse?> GetUserProfileAsync(string userId);
        //Task<List<ProfileResponse>> GetAllProfilesAsync();
        //Task<bool> DeleteProfileAsync(string userId);
        Task<UserSummaryDto?> GetUserSummaryAsync(string userId);
    }
}
