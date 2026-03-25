namespace MyWebApiApp.DTOs.Item
{
    public class PurchaseItemResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public int RemainingGems { get; set; }
    }
}
