using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Data;
using MyWebApiApp.DTOs.Item;
using MyWebApiApp.DTOs.UserItem;
using MyWebApiApp.DTOs.UserProfile;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;
using System.Net.ServerSentEvents;
using System.Security.Claims;

namespace MyWebApiApp.Controllers
{
    [Route("api/shop")]
    [ApiController]
    public class ShopController : ControllerBase
    {
        private readonly IShopRepository _shopRepository;

        public ShopController(IShopRepository shopRepository)
        {
            _shopRepository = shopRepository;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        ///// Lấy danh sách items
        //[HttpGet("items")]
        //public async Task<ActionResult<List<ItemDto>>> GetItems()
        //{
        //    var userId = GetUserId();

        //    var items = await _shopRepository.GetAllItemsAsync(userId);

        //    return Ok(items);
        //}

        [HttpGet("items")]
        public async Task<ActionResult<List<ItemDto>>> GetAllItems(string? category)
        {
            var items = await _shopRepository.GetAllItemsAsync(category);
            return Ok(items);
        }

        /// Mua item
        [HttpPost("purchase")]
        [Authorize]
        public async Task<ActionResult<PurchaseItemResponse>> PurchaseItem(
            [FromBody] PurchaseItemRequest request)
        {
            var userId = GetUserId();

            var response = await _shopRepository.PurchaseItemAsync(userId, request.ItemId);

            if (!response.Success)
            {
                return BadRequest(response);
            }

            return Ok(response);
        }

        /// Equip item
        [HttpPost("equip")]
        [Authorize]
        public async Task<ActionResult> EquipItem(
            [FromBody] PurchaseItemRequest request)
        {
            var userId = GetUserId();

            var success = await _shopRepository.EquipItemAsync(userId, request.ItemId);

            if (!success)
            {
                return BadRequest(new { message = "Không thể trang bị vật phẩm" });
            }

            return Ok(new { message = "Trang bị thành công" });
        }

        /// Lấy profile
        [HttpGet("inventory")]
        public async Task<ActionResult<UserProfileDto>> GetUserInventory()
        {
            var userId = GetUserId();

            var profile = await _shopRepository.GetUserInventoryAsync(userId);

            if (profile == null)
            {
                return NotFound();
            }

            return Ok(profile);
        }
    }
}
