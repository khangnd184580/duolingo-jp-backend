using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;

namespace MyWebApiApp.Repository
{
    public class TaskRepository : ITaskRepository
    {
        private readonly ApplicationDbContext _context;
        private const string TaskTypeXp = "DAILY_XP_20";
        private const string TaskTypeLessons = "DAILY_COMPLETE_3_LESSONS";
        private const string TaskTypeAccuracy = "DAILY_90_PERCENT_ONCE";

        public TaskRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<object> ClaimTaskRewardAsync(string userId, int taskId)
        {
            var today = GetVietnamDate();

            var userTask = await _context.UserTasks
                .Include(x => x.Task)
                .FirstOrDefaultAsync(x =>
                    x.UserId == userId &&
                    x.TaskId == taskId &&
                    x.AssignedDate == today);

            if (userTask == null)
                throw new Exception("Task not found");

            if (!userTask.IsCompleted)
                throw new Exception("Task not completed");

            if (userTask.IsClaimed)
                throw new Exception("Reward already claimed");

            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null)
                throw new Exception("User not found");

            user.TotalXP += userTask.Task.RewardXP;
            user.Gems += userTask.Task.RewardGems;

            // Extra reward rule: complete 3 lessons gives +1 heart.
            if (userTask.Task.TaskType == TaskTypeLessons)
            {
                user.CurrentHearts = Math.Min(user.MaxHearts, user.CurrentHearts + 1);
            }

            userTask.IsClaimed = true;

            await _context.SaveChangesAsync();

            return new
            {
                rewardXP = userTask.Task.RewardXP,
                rewardGems = userTask.Task.RewardGems,
                rewardHearts = userTask.Task.TaskType == TaskTypeLessons ? 1 : 0
            };
        }

        public async Task<List<UserTask>> GetDailyTasksAsync(string userId)
        {
            await EnsureFixedDailyTasksAsync();
            var today = GetVietnamDate();

            // Kiểm tra user đã có task hôm nay chưa
            var existingTasks = await _context.UserTasks
                .Include(x => x.Task)
                .Where(x => x.UserId == userId && x.AssignedDate == today)
                .ToListAsync();

            if (!existingTasks.Any())
            {
                var fixedTasks = await _context.Tasks
                    .Where(x => x.IsDaily &&
                           (x.TaskType == TaskTypeXp ||
                            x.TaskType == TaskTypeLessons ||
                            x.TaskType == TaskTypeAccuracy))
                    .OrderBy(x => x.TaskId)
                    .ToListAsync();

                var userTasks = new List<UserTask>();

                foreach (var task in fixedTasks)
                {
                    userTasks.Add(new UserTask
                    {
                        UserId = userId,
                        TaskId = task.TaskId,
                        AssignedDate = DateTime.SpecifyKind(today, DateTimeKind.Utc),
                        Progress = 0,
                        IsCompleted = false,
                        IsClaimed = false
                    });
                }

                _context.UserTasks.AddRange(userTasks);
                await _context.SaveChangesAsync();
            }

            await UpdateDailyTaskProgressAsync(userId);

            return await _context.UserTasks
                .Include(x => x.Task)
                .Where(x => x.UserId == userId && x.AssignedDate == today)
                .OrderBy(x => x.Task.TaskId)
                .ToListAsync();
        }

        public async Task<List<UserTask>> GetTaskProgressAsync(string userId)
        {
            await UpdateDailyTaskProgressAsync(userId);
            return await _context.UserTasks
            .Include(x => x.Task)
            .Where(x => x.UserId == userId)
            .ToListAsync();
        }

        public async Task UpdateDailyTaskProgressAsync(string userId)
        {
            var today = GetVietnamDate();
            var (utcStart, utcEnd) = GetVietnamDayRangeUtc(today);

            var todayTasks = await _context.UserTasks
                .Include(x => x.Task)
                .Where(x => x.UserId == userId && x.AssignedDate == today)
                .ToListAsync();

            if (!todayTasks.Any())
                return;

            var earnedXpToday = await _context.UserProgress
                .Where(x =>
                    x.UserId == userId &&
                    x.CompletedDate != null &&
                    x.CompletedDate.Value >= utcStart &&
                    x.CompletedDate.Value < utcEnd)
                .SumAsync(x => (int?)x.EarnedXP) ?? 0;

            var completedLessonsToday = await _context.LessonAttempts
                .Where(x =>
                    x.UserId == userId &&
                    x.CompletedAt != null &&
                    x.CompletedAt.Value >= utcStart &&
                    x.CompletedAt.Value < utcEnd)
                .CountAsync();

            var highAccuracyLessonsToday = await _context.LessonAttempts
                .Where(x =>
                    x.UserId == userId &&
                    x.CompletedAt != null &&
                    x.CompletedAt.Value >= utcStart &&
                    x.CompletedAt.Value < utcEnd &&
                    x.TotalQuestions > 0 &&
                    ((double)x.CorrectAnswers / x.TotalQuestions) >= 0.9)
                .CountAsync();

            foreach (var userTask in todayTasks)
            {
                var progressValue = userTask.Task.TaskType switch
                {
                    TaskTypeXp => earnedXpToday,
                    TaskTypeLessons => completedLessonsToday,
                    TaskTypeAccuracy => highAccuracyLessonsToday,
                    _ => 0
                };

                userTask.Progress = Math.Min(progressValue, userTask.Task.TargetValue);
                userTask.IsCompleted = userTask.Progress >= userTask.Task.TargetValue;
            }

            await _context.SaveChangesAsync();
        }

        private async Task EnsureFixedDailyTasksAsync()
        {
            await UpsertDailyTaskAsync(
                taskType: TaskTypeXp,
                taskName: "Kiếm được tổng cộng 20 XP",
                targetValue: 20,
                rewardXp: 0,
                rewardGems: 20);

            await UpsertDailyTaskAsync(
                taskType: TaskTypeLessons,
                taskName: "Hoàn thành 3 bài học",
                targetValue: 3,
                rewardXp: 0,
                rewardGems: 10);

            await UpsertDailyTaskAsync(
                taskType: TaskTypeAccuracy,
                taskName: "Đạt từ 90% trong 1 bài học",
                targetValue: 1,
                rewardXp: 0,
                rewardGems: 30);

            await _context.SaveChangesAsync();
        }

        private async Task UpsertDailyTaskAsync(
            string taskType,
            string taskName,
            int targetValue,
            int rewardXp,
            int rewardGems)
        {
            var task = await _context.Tasks.FirstOrDefaultAsync(x => x.TaskType == taskType);
            if (task == null)
            {
                _context.Tasks.Add(new TaskItem
                {
                    TaskName = taskName,
                    TaskType = taskType,
                    TargetValue = targetValue,
                    RewardXP = rewardXp,
                    RewardGems = rewardGems,
                    IsDaily = true
                });
                return;
            }

            task.TaskName = taskName;
            task.TargetValue = targetValue;
            task.RewardXP = rewardXp;
            task.RewardGems = rewardGems;
            task.IsDaily = true;
        }

        private static DateTime GetVietnamDate()
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

        private static (DateTime utcStart, DateTime utcEnd) GetVietnamDayRangeUtc(DateTime vietnamDate)
        {
            try
            {
                var tz = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
                var localStart = DateTime.SpecifyKind(vietnamDate.Date, DateTimeKind.Unspecified);
                var localEnd = DateTime.SpecifyKind(vietnamDate.Date.AddDays(1), DateTimeKind.Unspecified);
                var utcStart = TimeZoneInfo.ConvertTimeToUtc(localStart, tz);
                var utcEnd = TimeZoneInfo.ConvertTimeToUtc(localEnd, tz);
                return (utcStart, utcEnd);
            }
            catch
            {
                // VN is UTC+7 without DST.
                var utcStart = DateTime.SpecifyKind(vietnamDate.Date.AddHours(-7), DateTimeKind.Utc);
                var utcEnd = DateTime.SpecifyKind(vietnamDate.Date.AddDays(1).AddHours(-7), DateTimeKind.Utc);
                return (utcStart, utcEnd);
            }
        }
    }
}
