using MyWebApiApp.DTOs.Friends;

namespace MyWebApiApp.Interfaces
{
    public interface IFriendRepository
    {
        Task<FriendOperationResult> SendFriendRequestByUsernameAsync(string requesterUserId, string targetUsername);
        Task<List<FriendUserDto>> GetFriendsAsync(string userId);
        Task<List<FriendRequestIncomingDto>> GetIncomingRequestsAsync(string userId);
        Task<FriendOperationResult> AcceptRequestAsync(string userId, int requestId);
        Task<FriendOperationResult> DeclineRequestAsync(string userId, int requestId);
    }
}
