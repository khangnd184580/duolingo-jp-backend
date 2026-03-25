namespace MyWebApiApp.Models
{
    public class VwPopularItem
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string NameVi { get; set; } = null!;
        public string Category { get; set; } = null!;
        public int Price { get; set; }
        public int? PurchaseCount { get; set; }
        public int? EquippedCount { get; set; }
    }
}
