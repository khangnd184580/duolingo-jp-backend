namespace MyWebApiApp.DTOs.Profile
{
    public class ProfileResponse
    {
        public string Id { get; set; }

        public string Username { get; set; }

        public string Email { get; set; }

        public int Level { get; set; }

        public int CurrentXP { get; set; }

        public int TotalXP { get; set; }

        public int Gems { get; set; }

        public int Hearts { get; set; }

        public int MaxHearts { get; set; }

        public int CurrentStreak { get; set; }

        public int LongestStreak { get; set; }

        /// <summary>
        /// True when the user has completed at least one lesson today (Vietnam calendar day).
        /// Used to dim the streak UI until today's practice is done.
        /// </summary>
        public bool HasStudiedToday { get; set; }

        public List<LevelProgressItem> LevelProgress { get; set; } = new();
    }

    public class LevelProgressItem
    {
        public string LevelName { get; set; } = string.Empty;

        public int CompletedLessons { get; set; }

        public int TotalLessons { get; set; }
    }
}
