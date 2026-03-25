using System.ComponentModel.DataAnnotations.Schema;

namespace MyWebApiApp.Models
{
    [Table("UserTasks")]
    public class UserTask
    {
        public int UserTaskId { get; set; }
        public string UserId { get; set; }

        public int TaskId { get; set; }
        public int Progress { get; set; }

        public bool IsCompleted { get; set; }
        public bool IsClaimed { get; set; }

        public DateTime AssignedDate { get; set; }

        public TaskItem Task { get; set; }
    }
}
