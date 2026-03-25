using System.ComponentModel.DataAnnotations;

namespace MyWebApiApp.Models
{
    public class LessonAttempt
    {
        [Key]
        public int LessonAttemptId { get; set; }
        [Required]
        public string UserId { get; set; }
        [Required]
        public int LessonId { get; set; }

        public DateTime StartedAt { get; set; } = DateTime.UtcNow;

        public DateTime? CompletedAt { get; set; }

        public int TotalQuestions { get; set; }

        public int CorrectAnswers { get; set; }

        public bool IsPassed { get; set; }

        // Navigation
        public Lesson Lesson { get; set; } = null!;
        public AppUser User { get; set; } = null!;

        public ICollection<UserAnswer> UserAnswers { get; set; } = new List<UserAnswer>();
    }
}
