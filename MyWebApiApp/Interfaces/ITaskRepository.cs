using MyWebApiApp.Models;

namespace MyWebApiApp.Interfaces
{
    public interface ITaskRepository
    {
        Task<List<UserTask>> GetDailyTasksAsync(string userId);
        Task<object> ClaimTaskRewardAsync(string userId, int taskId);
        Task<List<UserTask>> GetTaskProgressAsync(string userId);
        Task UpdateDailyTaskProgressAsync(string userId);
    }
}
