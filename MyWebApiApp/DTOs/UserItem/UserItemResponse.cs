namespace MyWebApiApp.DTOs.UserItem
{
    public class UserItemResponse
    {
        public int UserItemId { get; set; }
        public int ItemId { get; set; }
        public string ItemName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public DateTime PurchasedAt { get; set; }
    }
}
