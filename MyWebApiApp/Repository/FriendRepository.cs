using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.DTOs.Friends;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;

namespace MyWebApiApp.Repository
{
    public class FriendRepository : IFriendRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<AppUser> _userManager;

        public FriendRepository(ApplicationDbContext context, UserManager<AppUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        public async Task<FriendOperationResult> SendFriendRequestByUsernameAsync(string requesterUserId, string targetUsername)
        {
            var trimmed = targetUsername?.Trim() ?? string.Empty;
            if (string.IsNullOrEmpty(trimmed))
                return new FriendOperationResult { Success = false, Message = "Nhập username" };

            var addressee = await _userManager.FindByNameAsync(trimmed);
            if (addressee == null)
                return new FriendOperationResult { Success = false, Message = "Không tìm thấy người dùng" };

            if (addressee.Id == requesterUserId)
                return new FriendOperationResult { Success = false, Message = "Không thể kết bạn với chính mình" };

            var areFriends = await _context.FriendRequests.AnyAsync(fr =>
                fr.Status == FriendRequestStatus.Accepted
                && ((fr.RequesterId == requesterUserId && fr.AddresseeId == addressee.Id)
                    || (fr.RequesterId == addressee.Id && fr.AddresseeId == requesterUserId)));

            if (areFriends)
                return new FriendOperationResult { Success = false, Message = "Hai bạn đã là bạn bè" };

            var pendingMeToThem = await _context.FriendRequests.FirstOrDefaultAsync(fr =>
                fr.Status == FriendRequestStatus.Pending
                && fr.RequesterId == requesterUserId
                && fr.AddresseeId == addressee.Id);

            if (pendingMeToThem != null)
                return new FriendOperationResult { Success = false, Message = "Bạn đã gửi lời mời rồi" };

            var pendingThemToMe = await _context.FriendRequests.FirstOrDefaultAsync(fr =>
                fr.Status == FriendRequestStatus.Pending
                && fr.RequesterId == addressee.Id
                && fr.AddresseeId == requesterUserId);

            if (pendingThemToMe != null)
                return new FriendOperationResult
                {
                    Success = false,
                    Message = "Người này đã gửi lời mời cho bạn. Vui lòng xem mục lời mời và chấp nhận."
                };

            _context.FriendRequests.Add(new FriendRequest
            {
                RequesterId = requesterUserId,
                AddresseeId = addressee.Id,
                Status = FriendRequestStatus.Pending,
                CreatedAt = DateTime.UtcNow
            });
            await _context.SaveChangesAsync();

            return new FriendOperationResult { Success = true, Message = "Đã gửi lời mời kết bạn" };
        }

        public async Task<List<FriendUserDto>> GetFriendsAsync(string userId)
        {
            var friendIds = await _context.FriendRequests
                .AsNoTracking()
                .Where(fr => fr.Status == FriendRequestStatus.Accepted
                             && (fr.RequesterId == userId || fr.AddresseeId == userId))
                .Select(fr => fr.RequesterId == userId ? fr.AddresseeId : fr.RequesterId)
                .Distinct()
                .ToListAsync();

            if (friendIds.Count == 0)
                return new List<FriendUserDto>();

            return await _context.Users
                .AsNoTracking()
                .Where(u => friendIds.Contains(u.Id))
                .Select(u => new FriendUserDto
                {
                    UserId = u.Id,
                    Username = u.UserName ?? u.Id,
                    AvatarUrl = null
                })
                .OrderBy(f => f.Username)
                .ToListAsync();
        }

        public async Task<List<FriendRequestIncomingDto>> GetIncomingRequestsAsync(string userId)
        {
            var requests = await _context.FriendRequests
                .AsNoTracking()
                .Where(fr => fr.Status == FriendRequestStatus.Pending && fr.AddresseeId == userId)
                .OrderByDescending(fr => fr.CreatedAt)
                .ToListAsync();

            if (requests.Count == 0)
                return new List<FriendRequestIncomingDto>();

            var fromIds = requests.Select(r => r.RequesterId).Distinct().ToList();
            var users = await _context.Users
                .AsNoTracking()
                .Where(u => fromIds.Contains(u.Id))
                .ToDictionaryAsync(u => u.Id, u => u.UserName ?? u.Id);

            return requests.Select(fr => new FriendRequestIncomingDto
            {
                RequestId = fr.Id,
                FromUserId = fr.RequesterId,
                FromUsername = users.TryGetValue(fr.RequesterId, out var name) ? name : fr.RequesterId,
                CreatedAt = fr.CreatedAt
            }).ToList();
        }

        public async Task<FriendOperationResult> AcceptRequestAsync(string userId, int requestId)
        {
            var fr = await _context.FriendRequests.FirstOrDefaultAsync(x => x.Id == requestId);
            if (fr == null)
                return new FriendOperationResult { Success = false, Message = "Không tìm thấy lời mời" };

            if (fr.AddresseeId != userId)
                return new FriendOperationResult { Success = false, Message = "Bạn không thể chấp nhận lời mời này" };

            if (fr.Status != FriendRequestStatus.Pending)
                return new FriendOperationResult { Success = false, Message = "Lời mời không còn hiệu lực" };

            fr.Status = FriendRequestStatus.Accepted;
            await _context.SaveChangesAsync();
            return new FriendOperationResult { Success = true, Message = "Đã chấp nhận kết bạn" };
        }

        public async Task<FriendOperationResult> DeclineRequestAsync(string userId, int requestId)
        {
            var fr = await _context.FriendRequests.FirstOrDefaultAsync(x => x.Id == requestId);
            if (fr == null)
                return new FriendOperationResult { Success = false, Message = "Không tìm thấy lời mời" };

            if (fr.AddresseeId != userId)
                return new FriendOperationResult { Success = false, Message = "Bạn không thể từ chối lời mời này" };

            if (fr.Status != FriendRequestStatus.Pending)
                return new FriendOperationResult { Success = false, Message = "Lời mời không còn hiệu lực" };

            fr.Status = FriendRequestStatus.Declined;
            await _context.SaveChangesAsync();
            return new FriendOperationResult { Success = true, Message = "Đã từ chối lời mời" };
        }
    }
}
