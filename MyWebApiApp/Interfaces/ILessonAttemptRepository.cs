using MyWebApiApp.DTOs.LessonContent;
using MyWebApiApp.Models;

namespace MyWebApiApp.Interfaces
{
    public interface ILessonAttemptRepository
    {
        Task<LessonContentDto?> GetLessonContentAsync(int lessonId);
        Task<LessonContentDto?> StartLessonAsync(string userId, int lessonId);
        Task<SubmitAnswerResponse> SubmitAnswerAsync(string userId, int attemptId, SubmitAnswerRequest request);
        Task<CompleteLessonResponse?> CompleteLessonAsync(string userId, int attemptId);
        //Task<List<Question>> GetQuestionsForLessonAsync(int lessonId);
        //Task<bool> ValidateAnswerAsync(int questionId, string answer);
    }
}
