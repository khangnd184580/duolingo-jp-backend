namespace MyWebApiApp.Models
{
    public class Lesson
    {
        public int LessonId { get; set; }
        public int TopicId { get; set; }
        public string LessonName { get; set; } = null!;
        public int BaseXP { get; set; }

        public Topic Topic { get; set; }
        public ICollection<Question> Questions { get; set; }
    }
}
