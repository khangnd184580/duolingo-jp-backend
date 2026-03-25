using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.DTOs.Item;
using MyWebApiApp.DTOs.UserProfile;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Mappers;
using MyWebApiApp.Models;

namespace MyWebApiApp.Repository
{
    public class ShopRepository : IShopRepository
    {
        private readonly ApplicationDbContext _context;

        public ShopRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<bool> EquipItemAsync(string userId, int itemId)
        {
            var userItem = await _context.UserItems
                .Include(ui => ui.Item)
                .FirstOrDefaultAsync(ui => ui.UserId == userId && ui.ItemId == itemId);

            if (userItem == null)
            {
                return false;
            }
            if (userItem.Item.Category == "powerup")
            {
                _context.UserItems.Remove(userItem);
                await _context.SaveChangesAsync();
                return true;
            }
            else if (userItem.Item.Category == "outfit")
            {
                var equippedOutfits = await _context.UserItems
                    .Include(ui => ui.Item)
                    .Where(ui => ui.UserId == userId && ui.Item.Category == "outfit" && ui.IsEquipped)
                    .ToListAsync();

                foreach(var outfit in equippedOutfits)
                {
                    outfit.IsEquipped = false;
                }
                userItem.IsEquipped = !userItem.IsEquipped;
                await _context.SaveChangesAsync();
                return true;
            }
            else if(userItem.Item.Category == "decoration") 
            {
                userItem.IsEquipped = !userItem.IsEquipped;
                await _context.SaveChangesAsync();
                return true;
            }
            return false;
        }

        public async Task<List<ItemDto>> GetAllItemsAsync(string? category)
        {
            var query = _context.Items.Where(i => i.IsActive);
            if (!string.IsNullOrEmpty(category))
            {
                query = query.Where(i => i.Category.ToLower() == category.ToLower());
            }

            var items = await query.Select(i => i.ToItemResponse()).ToListAsync();

            // UI/business override for test flow:
            // itemId=1 ("Nạp lại Trái tim") should cost 40 gems.
            var heartRefill = items.FirstOrDefault(i => i.Id == 1);
            if (heartRefill != null)
            {
                heartRefill.Price = 40;
            }

            return items;
        }

        public async Task<UserProfileDto> GetUserInventoryAsync(string userId)
        {
            var user = await _context.Users
                .Include(u => u.UserItems)
                .ThenInclude(ui => ui.Item)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                return new UserProfileDto();
            }

            return new UserProfileDto
            {
                Id = user.Id,
                Username = user.UserName,
                Email = user.Email,
                Gems = user.Gems,
                PurchasedItems = user.UserItems.Select(ui => new ItemDto
                {
                    Id = ui.Item.ItemId,
                    Name = ui.Item.Name,
                    Description = ui.Item.Description,
                    Price = ui.Item.Price,
                    ImageUrl = ui.Item.ImageUrl,
                    Category = ui.Item.Category,
                    IsPurchased = true,
                    IsEquipped = ui.IsEquipped
                }).ToList()
            };
        }

        public async Task<PurchaseItemResponse> PurchaseItemAsync(string userId, int itemId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return new PurchaseItemResponse
                {
                    Success = false,
                    Message = "Người dùng không tồn tại"
                };
            }

            var item = await _context.Items.FindAsync(itemId);
            if (item == null || !item.IsActive)
            {
                return new PurchaseItemResponse
                {
                    Success = false,
                    Message = "Vật phẩm không tồn tại hoặc không khả dụng"
                };
            }

            var existingPurchase = await _context.UserItems
                .FirstOrDefaultAsync(ui => ui.UserId == userId && ui.ItemId == itemId);

            var allowRepurchase = itemId == 10 || itemId == 1;
            if (existingPurchase != null)
            {
                // Special test item:
                // Allow re-purchasing itemId=10 (Gói ngọc trai) to test rewards repeatedly.
                if (!allowRepurchase)
                {
                    return new PurchaseItemResponse
                    {
                        Success = false,
                        Message = "Bạn đã sở hữu vật phẩm này rồi",
                        RemainingGems = user.Gems
                    };
                }

                existingPurchase.PurchasedAt = DateTime.UtcNow;
                existingPurchase.IsEquipped = false;
            }

            var effectivePrice = itemId == 1 ? 40 : item.Price;

            if (user.Gems < effectivePrice)
            {
                return new PurchaseItemResponse
                {
                    Success = false,
                    Message = $"Không đủ gems. Cần {effectivePrice} gems, bạn có {user.Gems} gems",
                    RemainingGems = user.Gems
                };
            }

            user.Gems -= effectivePrice;

            // Heart refill consumable:
            // - itemId=1 should restore exactly 1 heart immediately.
            if (itemId == 1)
            {
                user.CurrentHearts = Math.Min(user.MaxHearts, user.CurrentHearts + 1);
            }

            // Special test reward:
            // - Flutter mock uses itemId=10 as "Gói Ngọc trai"
            // - When purchasing, user should receive gems reward immediately.
            // Update request: spend 50, receive 300 gems.
            if (itemId == 10)
            {
                user.Gems += 300;
            }

            if (existingPurchase == null)
            {
                var userItem = new UserItem
                {
                    UserId = userId,
                    ItemId = itemId,
                    PurchasedAt = DateTime.UtcNow,
                    IsEquipped = false
                };

                _context.UserItems.Add(userItem);
            }
            else
            {
                _context.UserItems.Update(existingPurchase);
            }

            await _context.SaveChangesAsync();

            return new PurchaseItemResponse
            {
                Success = true,
                Message = $"Mua {item.Name} thành công!",
                RemainingGems = user.Gems
            };
        }
    }
}
