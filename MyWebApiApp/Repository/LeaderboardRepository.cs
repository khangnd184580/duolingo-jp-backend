using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.DTOs.Leaderboard;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;

namespace MyWebApiApp.Repository
{
    public class LeaderboardRepository : ILeaderboardRepository
    {
        private readonly ApplicationDbContext _context;

        public LeaderboardRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<WeeklyLeaderboardResponse> GetWeeklyGlobalAsync(string currentUserId)
        {
            return await BuildWeeklyAsync(currentUserId, filterUserIds: null);
        }

        public async Task<WeeklyLeaderboardResponse> GetWeeklyFriendsAsync(string currentUserId)
        {
            var friendIds = await GetAcceptedFriendIdsAsync(currentUserId);
            var filter = friendIds.Append(currentUserId).Distinct().ToHashSet();
            return await BuildWeeklyAsync(currentUserId, filter);
        }

        private async Task<WeeklyLeaderboardResponse> BuildWeeklyAsync(
            string currentUserId,
            IReadOnlyCollection<string>? filterUserIds)
        {
            var (weekStartUtc, weekEndUtc) = GetVietnamWeekRangeUtc(DateTime.UtcNow);

            var xpAgg = await _context.UserProgress
                .AsNoTracking()
                .Where(p => p.CompletedDate != null
                            && p.CompletedDate >= weekStartUtc
                            && p.CompletedDate < weekEndUtc)
                .GroupBy(p => p.UserId)
                .Select(g => new { UserId = g.Key, WeeklyXp = g.Sum(x => x.EarnedXP) })
                .ToListAsync();

            var xpDict = xpAgg.ToDictionary(x => x.UserId, x => x.WeeklyXp);

            var usersQuery = _context.Users.AsNoTracking().AsQueryable();
            if (filterUserIds != null && filterUserIds.Count > 0)
                usersQuery = usersQuery.Where(u => filterUserIds.Contains(u.Id));

            var users = await usersQuery
                .Select(u => new { u.Id, u.UserName })
                .ToListAsync();

            var rows = users
                .Select(u => new LeaderboardEntryDto
                {
                    UserId = u.Id,
                    Username = string.IsNullOrEmpty(u.UserName) ? u.Id : u.UserName,
                    AvatarUrl = null,
                    WeeklyXp = xpDict.TryGetValue(u.Id, out var xp) ? xp : 0,
                    IsCurrentUser = u.Id == currentUserId,
                    Rank = 0
                })
                .OrderByDescending(e => e.WeeklyXp)
                .ThenBy(e => e.Username)
                .ToList();

            for (var i = 0; i < rows.Count; i++)
            {
                rows[i].Rank = i + 1;
                rows[i].IsCurrentUser = rows[i].UserId == currentUserId;
            }

            var me = rows.FirstOrDefault(r => r.UserId == currentUserId);

            return new WeeklyLeaderboardResponse
            {
                WeekStartUtc = weekStartUtc,
                WeekEndUtc = weekEndUtc,
                Entries = rows,
                MyRank = me?.Rank,
                MyWeeklyXp = me?.WeeklyXp ?? 0
            };
        }

        private async Task<List<string>> GetAcceptedFriendIdsAsync(string userId)
        {
            return await _context.FriendRequests
                .AsNoTracking()
                .Where(fr => fr.Status == FriendRequestStatus.Accepted
                             && (fr.RequesterId == userId || fr.AddresseeId == userId))
                .Select(fr => fr.RequesterId == userId ? fr.AddresseeId : fr.RequesterId)
                .Distinct()
                .ToListAsync();
        }

        private static (DateTime utcStart, DateTime utcEnd) GetVietnamWeekRangeUtc(DateTime utcNow)
        {
            try
            {
                var tz = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
                var vnNow = TimeZoneInfo.ConvertTimeFromUtc(utcNow, tz);
                var daysSinceMonday = ((int)vnNow.DayOfWeek - (int)DayOfWeek.Monday + 7) % 7;
                var mondayVn = vnNow.Date.AddDays(-daysSinceMonday);
                var nextMondayVn = mondayVn.AddDays(7);

                var utcStart = TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(mondayVn, DateTimeKind.Unspecified), tz);
                var utcEnd = TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(nextMondayVn, DateTimeKind.Unspecified), tz);
                return (utcStart, utcEnd);
            }
            catch
            {
                var vnDate = utcNow.AddHours(7).Date;
                var daysSinceMonday = ((int)vnDate.DayOfWeek - (int)DayOfWeek.Monday + 7) % 7;
                var monday = vnDate.AddDays(-daysSinceMonday);
                var nextMonday = monday.AddDays(7);
                return (monday.AddHours(-7), nextMonday.AddHours(-7));
            }
        }
    }
}
