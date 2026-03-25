using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyWebApiApp.Models
{
    public enum FriendRequestStatus : int
    {
        Pending = 0,
        Accepted = 1,
        Declined = 2
    }

    [Table("FriendRequests")]
    public class FriendRequest
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(450)]
        public string RequesterId { get; set; } = null!;

        [Required]
        [MaxLength(450)]
        public string AddresseeId { get; set; } = null!;

        public FriendRequestStatus Status { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
