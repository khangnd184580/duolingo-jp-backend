using MyWebApiApp.DTOs.Item;
using MyWebApiApp.DTOs.UserProfile;

namespace MyWebApiApp.Interfaces
{
    public interface IShopRepository
    {
        Task<List<ItemDto>> GetAllItemsAsync(string? category);
        Task<PurchaseItemResponse> PurchaseItemAsync(string userId, int itemId);
        Task<UserProfileDto> GetUserInventoryAsync(string userId);
        Task<bool> EquipItemAsync(string userId, int itemId);
        
    }
}
