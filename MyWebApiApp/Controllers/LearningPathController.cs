using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;
using System.Security.Claims;

namespace MyWebApiApp.Controllers
{
    [Route("api/learning-path")]
    [ApiController]
    public class LearningPathController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<AppUser> _userManager;

        public LearningPathController(
            ApplicationDbContext context,
            UserManager<AppUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }


        [HttpGet("japanese-path")]
        public async Task<IActionResult> GetPath()
        {
            // 1️⃣ Lấy UserId từ JWT
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Token không hợp lệ");
            }
            // 2️⃣ Lấy toàn bộ Lesson
            var lessons = await _context.Lessons
                .OrderBy(l => l.LessonId)
                .ToListAsync();

            // 3️⃣ Lấy danh sách LessonId đã hoàn thành
            var completedLessonIds = await _context.UserProgress
                .Where(p => p.UserId == userId)
                .Select(p => p.LessonId)
                .ToListAsync();

            // 4️⃣ Merge lại
            var result = lessons.Select(lesson => new
            {
                lesson.LessonId,
                lesson.LessonName,
                

                // Nếu tồn tại trong UserProgress => đã hoàn thành
                IsCompleted = completedLessonIds.Contains(lesson.LessonId)
            });

            return Ok(result);
        }
        
        

        [HttpGet("my-progress")]
        public async Task<IActionResult> GetMyProgress()
        {
            // Nếu chưa đăng nhập
            if (User?.Identity == null || !User.Identity.IsAuthenticated)
            {
                return Unauthorized("Người dùng chưa đăng nhập");
            }

            // Lấy UserId từ token
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Token không hợp lệ hoặc không chứa UserId");
            }

            var progress = await _context.UserProgress
                .Where(p => p.UserId == userId)
                .Include(p => p.Lesson)
                .Select(p => new
                {
                    p.LessonId,
                    LessonName = p.Lesson.LessonName,
                    p.CompletedDate,
                    p.EarnedXP
                })
                .ToListAsync();

            return Ok(progress);


        }

        [HttpGet("mistakes")]
        public IActionResult GetMistakes()
        {
            // TODO: get user's wrong answers

            return Ok(new
            {
                message = "Mistake review endpoint created"
            });
        }
    }

}

