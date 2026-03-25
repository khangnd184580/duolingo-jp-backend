namespace MyWebApiApp.Models
{
    public class UserItem
    {
        public int Id { get; set; }
        public string? UserId { get; set; } // Keep as string - proper FK to AspNetUsers
        public int ItemId { get; set; }
        public int Quantity { get; set; } = 1;
        public DateTime PurchasedAt { get; set; } = DateTime.Now;
        public bool IsEquipped { get; set; }

        public AppUser User { get; set; } = null!;
        public Item Item { get; set; } = null!;
    }
}
