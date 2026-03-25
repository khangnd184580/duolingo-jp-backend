using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyWebApiApp.Models
{
    
    public class Item
    {
        [Key]
        public int ItemId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int Price { get; set; }
        public string Category { get; set; } = string.Empty;
        public string ImageUrl { get; set; }
        public bool IsActive { get; set; } = true;

    }
}
