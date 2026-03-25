using System.ComponentModel.DataAnnotations;

namespace MyWebApiApp.Models
{
    public class QuestionOption
    {
        [Key]
        public int OptionId { get; set; }

        public int QuestionId { get; set; }

        public string OptionText { get; set; }

        public bool IsCorrect { get; set; }

        // Navigation
        public Question Question { get; set; }
    }
}
