using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.DTOs.LessonContent;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;
using MyWebApiApp.Services;

namespace MyWebApiApp.Repository
{
    public class LessonAttemptRepository : ILessonAttemptRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly IStreakRepository _streakRepo;
        private readonly IHeartRepository _heartRepo;
        private readonly ITaskRepository _taskRepo;
        private readonly IAchievementService _achievementService;
        private readonly UserManager<AppUser> _userManager;
        
        public LessonAttemptRepository(
            ApplicationDbContext context, 
            IStreakRepository streakRepo, 
            IHeartRepository heartRepo,
            ITaskRepository taskRepo,
            IAchievementService achievementService,
            UserManager<AppUser> userManager)
        {
            _context = context;
            _streakRepo = streakRepo;
            _heartRepo = heartRepo;
            _taskRepo = taskRepo;
            _achievementService = achievementService;
            _userManager = userManager;
        }

        public async Task<CompleteLessonResponse?> CompleteLessonAsync(string userId, int attemptId)
        {
            var attempt = await _context.LessonAttempts
        .FirstOrDefaultAsync(a =>
            a.LessonAttemptId == attemptId
            && a.UserId == userId);

            if (attempt == null)
                return null;

            // Nếu đã complete rồi thì không cho complete lại
            if (attempt.CompletedAt != null)
                throw new Exception("Lesson already completed.");

            attempt.CompletedAt = DateTime.UtcNow;

            double scorePercent = attempt.TotalQuestions == 0
                ? 0
                : (double)attempt.CorrectAnswers / attempt.TotalQuestions;

            attempt.IsPassed = scorePercent >= 0.8;

            int earnedXP = 0;

            if (attempt.IsPassed)
            {
                // Lấy XP gốc của lesson
                var lesson = await _context.Lessons
                    .FirstOrDefaultAsync(l => l.LessonId == attempt.LessonId);

                earnedXP = lesson?.BaseXP ?? 10; // fallback 10 XP nếu null

                // Kiểm tra đã có progress chưa
                var existingProgress = await _context.UserProgress
                    .FirstOrDefaultAsync(p =>
                        p.UserId == userId &&
                        p.LessonId == attempt.LessonId);

                if (existingProgress == null)
                {
                    _context.UserProgress.Add(new UserProgress
                    {
                        UserId = userId,
                        LessonId = attempt.LessonId,
                        IsCompleted = true,
                        CompletedDate = DateTime.UtcNow,
                        EarnedXP = earnedXP
                    });
                }
                else
                {
                    // Nếu đã có thì chỉ update (trường hợp học lại)
                    existingProgress.IsCompleted = true;
                    existingProgress.CompletedDate = DateTime.UtcNow;
                    existingProgress.EarnedXP = earnedXP;
                }
                
                // Update user stats: XP and Gems
                var user = await _userManager.FindByIdAsync(userId);
                if (user != null)
                {
                    user.CurrentXP += earnedXP;
                    user.TotalXP += earnedXP;
                    user.Gems += 10; // Reward 10 gems per lesson completion
                    await _userManager.UpdateAsync(user);
                }
                
                // Update streak
                await _streakRepo.UpdateStreakAsync(userId);

            }

            await _context.SaveChangesAsync();
            await _taskRepo.UpdateDailyTaskProgressAsync(userId);
            await _achievementService.CheckLessonAchievementsAsync(userId);

            return new CompleteLessonResponse
            {
                TotalQuestions = attempt.TotalQuestions,
                CorrectAnswers = attempt.CorrectAnswers,
                IsPassed = attempt.IsPassed,
                EarnedXP = earnedXP,
                Accuracy = scorePercent * 100
            };
        }

        public async Task<LessonContentDto?> GetLessonContentAsync(int lessonId)
        {
            var lesson = await _context.Lessons
            .Include(l => l.Questions)
                .ThenInclude(q => q.QuestionOptions)
            .FirstOrDefaultAsync(l => l.LessonId == lessonId);

            if (lesson == null) return null;

            return new LessonContentDto
            {
                AttemptId = 0,
                Questions = lesson.Questions
                    .OrderBy(q => q.OrderIndex)
                    .Select(q => new QuestionDto
                    {
                        QuestionId = q.QuestionId,
                        Content = q.Content,
                        Options = q.QuestionOptions
                            .Select(o => new OptionDto
                            {
                                OptionId = o.OptionId,
                                OptionText = o.OptionText
                            }).ToList()
                    }).ToList()
            };
        }

        public async Task<LessonContentDto?> StartLessonAsync(string userId, int lessonId)
        {
            var lesson = await _context.Lessons
            .Include(l => l.Questions)
                .ThenInclude(q => q.QuestionOptions)
            .FirstOrDefaultAsync(l => l.LessonId == lessonId);

            if (lesson == null) return null;

            var attempt = new LessonAttempt
            {
                UserId = userId,
                LessonId = lessonId,
                StartedAt = DateTime.UtcNow,
                TotalQuestions = lesson.Questions.Count,
                CorrectAnswers = 0,
                IsPassed = false
            };

            _context.LessonAttempts.Add(attempt);
            await _context.SaveChangesAsync();

            // Count "started a lesson" as daily study activity for streak.
            await _streakRepo.UpdateStreakAsync(userId);
            await _achievementService.CheckLessonAchievementsAsync(userId);

            return new LessonContentDto
            {
                AttemptId = attempt.LessonAttemptId,
                Questions = lesson.Questions
                    .OrderBy(q => q.OrderIndex)
                    .Select(q => new QuestionDto
                    {
                        QuestionId = q.QuestionId,
                        Content = q.Content,
                        Options = q.QuestionOptions
                            .Select(o => new OptionDto
                            {
                                OptionId = o.OptionId,
                                OptionText = o.OptionText
                            }).ToList()
                    }).ToList()
            };
        }

        public async Task<SubmitAnswerResponse> SubmitAnswerAsync(string userId, int attemptId, SubmitAnswerRequest request)
        {
            var attempt = await _context.LessonAttempts
            .FirstOrDefaultAsync(a => a.LessonAttemptId == attemptId && a.UserId == userId);

            if (attempt == null)
                throw new Exception("Invalid attempt");

            var option = await _context.QuestionOptions
                .FirstOrDefaultAsync(o =>
                    o.OptionId == request.SelectedOptionId &&
                    o.QuestionId == request.QuestionId);

            if (option == null)
                throw new Exception("Invalid option");

            var userAnswer = new UserAnswer
            {
                LessonAttemptId = attemptId,
                QuestionId = request.QuestionId,
                SelectedOptionId = request.SelectedOptionId,
                IsCorrect = option.IsCorrect
            };

            if (option.IsCorrect)
            {
                attempt.CorrectAnswers++;
            }
            else
            {
                var heartRemaining = await _heartRepo.LoseHeartAsync(userId);
                if (!heartRemaining)
                {
                    throw new Exception("No hearts remaining");
                }
            }


            _context.UserAnswers.Add(userAnswer);
            await _context.SaveChangesAsync();

            // Get current hearts after update
            var user = await _userManager.FindByIdAsync(userId);
            var currentHearts = user?.CurrentHearts ?? 0;

            return new SubmitAnswerResponse
            {
                IsCorrect = option.IsCorrect,
                RemainingHearts = currentHearts
            };
        }
    }
}
