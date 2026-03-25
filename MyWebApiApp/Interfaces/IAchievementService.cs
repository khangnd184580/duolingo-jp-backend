namespace MyWebApiApp.Interfaces
{
    public interface IAchievementService
    {
        Task CheckLessonAchievementsAsync(string userId);
    }
}
