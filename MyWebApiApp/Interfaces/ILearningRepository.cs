namespace MyWebApiApp.Interfaces
{
    public interface ILearningRepository
    {
        Task<IEnumerable<object>> GetJapanesePathAsync(int userId);
        Task UpdateProgressAsync(int userId, int lessonId);
    }
}
