using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyWebApiApp.Models
{

    public class UserProgress
    {
        [Key]
        public int ProgressId { get; set; }
        public string UserId { get; set; } // Keep as string - proper FK to AspNetUsers
        public int LessonId { get; set; }
        
        [Column("Status")]
        public bool IsCompleted { get; set; }
        
        public DateTime? CompletedDate { get; set; }
        public int EarnedXP { get; set; }

        // Navigation property
        public AppUser User { get; set; } = null!;
        public Lesson Lesson { get; set; } = null!;
    }
}
