namespace MyWebApiApp.DTOs.Achievement
{
    public class ClaimAchievementResponse
    {
        public bool Success { get; set; }

        public string Message { get; set; }

        public int RewardXP { get; set; }

        public int RewardGems { get; set; }
    }
}
