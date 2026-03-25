namespace MyWebApiApp.DTOs.Streak
{
    public class StreakResponse
    {
        public int CurrentStreak { get; set; }
        public int LongestStreak { get; set; }
        public DateTime? LastStudyDate { get; set; }
        public bool HasStudiedToday { get; set; }
    }
}
