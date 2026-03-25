namespace MyWebApiApp.DTOs.Profile
{
    public class UserSummaryDto
    {
        public string UserName { get; set; }

        public int TotalXP { get; set; }

        public int CurrentStreak { get; set; }

        public int CurrentHearts { get; set; }

        public int LessonsCompleted { get; set; }
    }
}
