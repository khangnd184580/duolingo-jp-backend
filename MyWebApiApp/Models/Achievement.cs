namespace MyWebApiApp.Models
{
    public class Achievement
    {
        public int AchievementId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string IconUrl { get; set; }
        public int RequiredValue { get; set; }
        public string AchievementType { get; set; }
    }
}
