using Microsoft.AspNetCore.Identity;

namespace MyWebApiApp.Models
{
    public class AppUser : IdentityUser
    {
        public int CurrentXP { get; set; } = 0;
        public int TotalXP { get; set; } = 0;
        public int Level { get; set; } = 1;
        public int CurrentHearts { get; set; } = 5;
        public int MaxHearts { get; set; } = 5;
        public DateTime? LastHeartRefillTime { get; set; }
        public int Gems { get; set; } = 0;
        public int CurrentStreak { get; set; } = 0;
        public int LongestStreak { get; set; } = 0;
        public DateTime? LastStudyDate { get; set; }
        public int StreakFreezeCount { get; set; } = 0;

        public virtual ICollection<UserItem> UserItems { get; set; } = new List<UserItem>();

        // Navigation properties
    }
}
