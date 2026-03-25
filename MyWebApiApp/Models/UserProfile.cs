namespace MyWebApiApp.Models
{
    public class UserProfile
    {
        public int ProfileID { get; set; }
        public int UserID { get; set; }
        public string DisplayName { get; set; }
        public string? AvatarUrl { get; set; }
        public int XP { get; set; }
        public int Gems { get; set; }
        public int StreakCount { get; set; }

        public AppUser User { get; set; }
    }
}
