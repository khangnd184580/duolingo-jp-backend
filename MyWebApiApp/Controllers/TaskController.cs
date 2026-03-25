using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyWebApiApp.Extensions;
using MyWebApiApp.Interfaces;

namespace MyWebApiApp.Controllers
{
    [Route("api/tasks")]
    [ApiController]
    [Authorize]
    public class TaskController : ControllerBase
    {
        private readonly ITaskRepository _taskRepo;

        public TaskController(ITaskRepository taskRepo)
        {
            _taskRepo = taskRepo;
        }

        [HttpGet("daily")]
        public async Task<IActionResult> GetDailyTasks()
        {
            var userId = User.GetUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var tasks = await _taskRepo.GetDailyTasksAsync(userId);

            return Ok(tasks);
        }

        /// <summary>
        /// Nhận thưởng task
        /// </summary>
        [HttpPost("{taskId}/claim")]
        public async Task<IActionResult> ClaimTaskReward(int taskId)
        {
            var userId = User.GetUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            try
            {
                var result = await _taskRepo.ClaimTaskRewardAsync(userId, taskId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Lấy tiến độ task
        /// </summary>
        [HttpGet("progress")]
        public async Task<IActionResult> GetTaskProgress()
        {
            var userId = User.GetUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var result = await _taskRepo.GetTaskProgressAsync(userId);

            return Ok(result);
        }
    }
}
