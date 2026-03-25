using System.ComponentModel.DataAnnotations;

namespace MyWebApiApp.Models
{
    public class UserAnswer
    {
        [Key]
        public int UserAnswerId { get; set; }
        [Required]
        public int LessonAttemptId { get; set; }
        [Required]
        public int QuestionId { get; set; }
        [Required]
        public int SelectedOptionId { get; set; }

        public bool IsCorrect { get; set; }

        // Navigation
        public LessonAttempt LessonAttempt { get; set; } = null!;

        public Question Question { get; set; } = null!;
        public QuestionOption SelectedOption { get; set; } = null!;
    }
}
