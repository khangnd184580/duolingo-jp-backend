namespace MyWebApiApp.DTOs.Item
{
    public class ItemDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int Price { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public bool IsPurchased { get; set; }
        public bool IsEquipped { get; set; }
    }
}
