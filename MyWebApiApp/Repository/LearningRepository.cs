using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;
using System;

namespace MyWebApiApp.Repository
{
    public class LearningRepository : ILearningRepository
    {
        private readonly ApplicationDbContext _context;

        public LearningRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public Task<IEnumerable<object>> GetJapanesePathAsync(int userId)
        {
            throw new NotImplementedException();
        }

        public Task UpdateProgressAsync(int userId, int lessonId)
        {
            throw new NotImplementedException();
        }

        //public async Task<IEnumerable<object>> GetJapanesePathAsync(int userId)
        //{
        //    // Lấy tất cả Unit và Node theo thứ tự
        //    var units = await _context.Units
        //        .OrderBy(u => u.UnitNumber)
        //        .Include(u => u.Nodes)
        //        .ToListAsync();

        //    // Lấy tiến độ của User hiện tại
        //    var progressMap = await _context.UserLessonProgresses
        //        .Where(p => p.UserId == userId)
        //        .ToDictionaryAsync(p => p.NodeId, p => p.Status);

        //    return units.Select(u => new {
        //        u.UnitId,
        //        u.Title,
        //        u.UnitNumber,
        //        Nodes = u.Nodes.OrderBy(n => n.Position).Select(n => new {
        //            n.NodeId,
        //            n.NodeType,
        //            n.Position,
        //            // Nếu chưa có tiến độ, Node đầu tiên của Unit 1 là Unlocked, còn lại là Locked
        //            Status = progressMap.ContainsKey(n.NodeId) ? progressMap[n.NodeId] :
        //                     (u.UnitNumber == 1 && n.Position == 1 ? "Unlocked" : "Locked")
        //        })
        //    });
        //}

        //public async Task UpdateProgressAsync(int userId, int lessonId)
        //{
        //    var lesson = await _context.Lessons.FindAsync(lessonId);
        //    if (lesson == null) return;

        //    var nodeId = lesson.NodeId;
        //    var totalLessonsInNode = await _context.Lessons.CountAsync(l => l.NodeId == nodeId);

        //    var userProgress = await _context.UserLessonProgresses
        //        .FirstOrDefaultAsync(p => p.UserId == userId && p.NodeId == nodeId);

        //    if (userProgress == null)
        //    {
        //        userProgress = new UserLessonProgress
        //        {
        //            UserId = userId,
        //            NodeId = nodeId,
        //            CurrentLessonIndex = 1,
        //            Status = "Unlocked"
        //        };
        //        _context.UserLessonProgresses.Add(userProgress);
        //    }
        //    else if (userProgress.Status != "Completed")
        //    {
        //        userProgress.CurrentLessonIndex++;
        //    }

        //    // Nếu hoàn thành Node hiện tại
        //    if (userProgress.CurrentLessonIndex >= totalLessonsInNode)
        //    {
        //        userProgress.Status = "Completed";

        //        // Tìm Node tiếp theo (Có thể ở Unit hiện tại hoặc Unit kế tiếp)
        //        var currentNode = await _context.Nodes.FindAsync(nodeId);

        //        // Tìm Node có Position tiếp theo trong cùng Unit
        //        var nextNode = await _context.Nodes
        //            .Where(n => n.UnitId == currentNode.UnitId && n.Position > currentNode.Position)
        //            .OrderBy(n => n.Position)
        //            .FirstOrDefaultAsync();

        //        // Nếu không có trong Unit hiện tại, tìm Node đầu tiên của Unit tiếp theo
        //        if (nextNode == null)
        //        {
        //            var nextUnit = await _context.Units
        //                .Where(u => u.UnitNumber > _context.Units.Find(currentNode.UnitId).UnitNumber)
        //                .OrderBy(u => u.UnitNumber)
        //                .FirstOrDefaultAsync();

        //            if (nextUnit != null)
        //            {
        //                nextNode = await _context.Nodes
        //                    .Where(n => n.UnitId == nextUnit.UnitId)
        //                    .OrderBy(n => n.Position)
        //                    .FirstOrDefaultAsync();
        //            }
        //        }

        //        if (nextNode != null)
        //        {
        //            // Kiểm tra xem đã tồn tại progress chưa để tránh duplicate
        //            var exists = await _context.UserLessonProgresses
        //                .AnyAsync(p => p.UserId == userId && p.NodeId == nextNode.NodeId);
        //            if (!exists)
        //            {
        //                _context.UserLessonProgresses.Add(new UserLessonProgress
        //                {
        //                    UserId = userId,
        //                    NodeId = nextNode.NodeId,
        //                    Status = "Unlocked"
        //                });
        //            }
        //        }
        //    }
        //    await _context.SaveChangesAsync();
        //}
    }
}
