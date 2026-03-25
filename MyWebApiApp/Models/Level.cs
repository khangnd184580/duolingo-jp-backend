namespace MyWebApiApp.Models
{
    public class Level
    {
        public int LevelId { get; set; }
        public string LevelName { get; set; } = null!;
        public ICollection<Topic> Topics { get; set; } = new List<Topic>();
    }
}
