namespace MyWebApiApp.Models
{
    public class Question
    {
        public int QuestionId { get; set; }
        public int LessonId { get; set; }

        public string Content { get; set; }

        public int OrderIndex { get; set; }

        // Navigation
        public Lesson Lesson { get; set; }

        public ICollection<QuestionOption> QuestionOptions { get; set; }
    }
}
