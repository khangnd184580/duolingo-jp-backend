namespace MyWebApiApp.Models
{
    public class Topic
    {
        public int TopicId { get; set; }
        public string TopicName { get; set; } = null!;
        public int LevelId { get; set; }
        public Level Level { get; set; } = null!;
        public ICollection<Lesson> Lessons { get; set; } = new List<Lesson>();
    }
}
