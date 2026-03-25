using MyWebApiApp.DTOs.Item;
using MyWebApiApp.Models;

namespace MyWebApiApp.Mappers
{
    public static class ItemMappers
    {
        public static ItemDto ToItemResponse(this Item itemModel)
        {
            return new ItemDto
            {
                Id = itemModel.ItemId,
                Name = itemModel.Name,
                Description = itemModel.Description,
                Price = itemModel.Price,
                Category = itemModel.Category,
                ImageUrl = itemModel.ImageUrl
            };
        }
    }
}
