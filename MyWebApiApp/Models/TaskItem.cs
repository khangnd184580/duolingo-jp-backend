using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyWebApiApp.Models
{
    [Table("Tasks")]
    public class TaskItem
    {
        [Key]
        public int TaskId { get; set; }
        public string TaskName { get; set; }
        public string TaskType { get; set; }
        public int TargetValue { get; set; }
        public int RewardXP { get; set; }
        public int RewardGems { get; set; }
        public bool IsDaily { get; set; }
    }
}
