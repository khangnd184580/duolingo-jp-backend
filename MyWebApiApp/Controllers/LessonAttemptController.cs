using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyWebApiApp.DTOs.LessonContent;
using MyWebApiApp.Extensions;
using MyWebApiApp.Interfaces;

namespace MyWebApiApp.Controllers
{
    [Route("api/lesson-attempt")]
    [ApiController]
    [Authorize]
    public class LessonAttemptController : ControllerBase
    {
        private readonly ILessonAttemptRepository _lessonContentRepo;

        public LessonAttemptController(ILessonAttemptRepository lessonContentRepo)
        {
            _lessonContentRepo = lessonContentRepo;
        }

        // GET: api/lesson-content/{lessonId}
        [HttpGet("{lessonId}")]
        public async Task<IActionResult> GetLessonContent(int lessonId)
        {
            var content = await _lessonContentRepo.GetLessonContentAsync(lessonId);
            
            if (content == null)
                return NotFound(new { message = "Lesson not found" });

            return Ok(content);
        }

        // POST: api/lesson-content/start/{lessonId}
        [HttpPost("start/{lessonId}")]
        public async Task<IActionResult> StartLesson(int lessonId)
        {
            var userId = User.GetUserId();
            
            var result = await _lessonContentRepo.StartLessonAsync(userId, lessonId);
            
            if (result == null)
                return NotFound(new { message = "Lesson not found or user not found" });

            return Ok(result);
        }

        // POST: api/lesson-content/submit-answer/{attemptId}
        [HttpPost("submit-answer/{attemptId}")]
        public async Task<IActionResult> SubmitAnswer(int attemptId, [FromBody] SubmitAnswerRequest request)
        {
            try
            {
                var userId = User.GetUserId();
                var result = await _lessonContentRepo.SubmitAnswerAsync(userId, attemptId, request);
                
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // POST: api/lesson-content/complete/{attemptId}
        [HttpPost("complete/{attemptId}")]
        public async Task<IActionResult> CompleteLesson(int attemptId)
        {
            var userId = User.GetUserId();
            var result = await _lessonContentRepo.CompleteLessonAsync(userId, attemptId);
            
            if (result == null)
                return NotFound(new { message = "Lesson attempt not found" });

            return Ok(result);
        }
    }
}
