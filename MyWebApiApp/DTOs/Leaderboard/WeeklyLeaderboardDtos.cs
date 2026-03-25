namespace MyWebApiApp.DTOs.Leaderboard
{
    public class WeeklyLeaderboardResponse
    {
        public DateTime WeekStartUtc { get; set; }
        public DateTime WeekEndUtc { get; set; }
        public List<LeaderboardEntryDto> Entries { get; set; } = new();
        public int? MyRank { get; set; }
        public int MyWeeklyXp { get; set; }
    }

    public class LeaderboardEntryDto
    {
        public int Rank { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        public int WeeklyXp { get; set; }
        public bool IsCurrentUser { get; set; }
    }
}
