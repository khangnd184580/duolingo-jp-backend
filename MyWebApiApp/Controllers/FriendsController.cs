using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyWebApiApp.DTOs.Friends;
using MyWebApiApp.Interfaces;
using System.Security.Claims;

namespace MyWebApiApp.Controllers
{
    [Route("api/friends")]
    [ApiController]
    [Authorize]
    public class FriendsController : ControllerBase
    {
        private readonly IFriendRepository _friends;

        public FriendsController(IFriendRepository friends)
        {
            _friends = friends;
        }

        private string GetUserId() =>
            User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;

        [HttpPost("request")]
        public async Task<IActionResult> SendRequest([FromBody] SendFriendRequestDto body)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var result = await _friends.SendFriendRequestByUsernameAsync(userId, body.Username);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpGet]
        public async Task<IActionResult> ListFriends()
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var list = await _friends.GetFriendsAsync(userId);
            return Ok(list);
        }

        [HttpGet("requests/incoming")]
        public async Task<IActionResult> Incoming()
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var list = await _friends.GetIncomingRequestsAsync(userId);
            return Ok(list);
        }

        [HttpPost("requests/{requestId:int}/accept")]
        public async Task<IActionResult> Accept(int requestId)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var result = await _friends.AcceptRequestAsync(userId, requestId);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("requests/{requestId:int}/decline")]
        public async Task<IActionResult> Decline(int requestId)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var result = await _friends.DeclineRequestAsync(userId, requestId);
            if (!result.Success)
                return BadRequest(result);
            return Ok(result);
        }
    }
}
