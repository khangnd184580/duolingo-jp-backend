using MyWebApiApp.Data;
using MyWebApiApp.DTOs.Profile;
using MyWebApiApp.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace MyWebApiApp.Repository
{
    public class ProfileRepository : IProfileRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly IHeartRepository _heartRepository;

        public ProfileRepository(ApplicationDbContext context, IHeartRepository heartRepository)
        {
            _context = context;
            _heartRepository = heartRepository;
        }

        public async Task<ProfileResponse?> GetProfileAsync(string userId)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
                return null;

            // Recalculate hearts before returning profile so UI always sees auto-refill result.
            await _heartRepository.GetHeartsAsync(userId);
            user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null)
                return null;

            var levelProgress = await BuildLevelProgressAsync(userId);
            var todayVn = GetVietnamTodayDate();
            var hasStudiedToday = user.LastStudyDate.HasValue &&
                                  user.LastStudyDate.Value.Date == todayVn;

            return new ProfileResponse
            {
                Id = user.Id,
                Username = user.UserName,
                Email = user.Email,
                Level = user.Level,
                CurrentXP = user.CurrentXP,
                TotalXP = user.TotalXP,
                Gems = user.Gems,
                Hearts = user.CurrentHearts,
                MaxHearts = user.MaxHearts,
                CurrentStreak = user.CurrentStreak,
                LongestStreak = user.LongestStreak,
                HasStudiedToday = hasStudiedToday,
                LevelProgress = levelProgress
            };
        }

        public async Task<UserSummaryDto?> GetUserSummaryAsync(string userId)
        {
            return new UserSummaryDto
            {
                UserName = "DemoUser",
                TotalXP = 0,
                CurrentStreak = 0,
                CurrentHearts = 5,
                LessonsCompleted = 0
            };
        }

        public async Task<ProfileResponse?> UpdateProfileAsync(string userId, UpdateProfileRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
                return null;

            if (!string.IsNullOrEmpty(request.UserName))
            {
                user.UserName = request.UserName;
            }

            await _context.SaveChangesAsync();
            var levelProgress = await BuildLevelProgressAsync(userId);

            var todayVn2 = GetVietnamTodayDate();
            var hasStudiedToday2 = user.LastStudyDate.HasValue &&
                                   user.LastStudyDate.Value.Date == todayVn2;

            return new ProfileResponse
            {
                Id = user.Id,
                Username = user.UserName,
                Email = user.Email,
                Level = user.Level,
                CurrentXP = user.CurrentXP,
                TotalXP = user.TotalXP,
                Gems = user.Gems,
                Hearts = user.CurrentHearts,
                MaxHearts = user.MaxHearts,
                CurrentStreak = user.CurrentStreak,
                LongestStreak = user.LongestStreak,
                HasStudiedToday = hasStudiedToday2,
                LevelProgress = levelProgress
            };
        }

        private static DateTime GetVietnamTodayDate()
        {
            try
            {
                var tz = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
                return TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz).Date;
            }
            catch
            {
                return DateTime.UtcNow.AddHours(7).Date;
            }
        }

        private async Task<List<LevelProgressItem>> BuildLevelProgressAsync(string userId)
        {
            var completedLessonIds = await _context.UserProgress
                .Where(p => p.UserId == userId)
                .Select(p => p.LessonId)
                .Distinct()
                .ToListAsync();

            var completedSet = completedLessonIds.ToHashSet();

            var lessons = await _context.Lessons
                .Select(l => new
                {
                    l.LessonId,
                    LevelName = l.Topic.Level.LevelName
                })
                .ToListAsync();

            var grouped = lessons
                .Select(l => new
                {
                    NormalizedLevel = NormalizeJlptLevel(l.LevelName),
                    l.LessonId
                })
                .Where(x => !string.IsNullOrWhiteSpace(x.NormalizedLevel))
                .GroupBy(x => x.NormalizedLevel!)
                .ToDictionary(
                    g => g.Key,
                    g => new LevelProgressItem
                    {
                        LevelName = g.Key,
                        TotalLessons = g.Count(),
                        CompletedLessons = g.Count(x => completedSet.Contains(x.LessonId))
                    });

            var displayOrder = new[] { "N5", "N4", "N3", "N2", "N1" };
            return displayOrder
                .Select(level => grouped.TryGetValue(level, out var item)
                    ? item
                    : new LevelProgressItem
                    {
                        LevelName = level,
                        TotalLessons = 0,
                        CompletedLessons = 0
                    })
                .ToList();
        }

        private static string? NormalizeJlptLevel(string? rawLevel)
        {
            if (string.IsNullOrWhiteSpace(rawLevel))
                return null;

            var upper = rawLevel.ToUpperInvariant();
            if (upper.Contains("N1")) return "N1";
            if (upper.Contains("N2")) return "N2";
            if (upper.Contains("N3")) return "N3";
            if (upper.Contains("N4")) return "N4";
            if (upper.Contains("N5")) return "N5";
            return null;
        }
    }
}
