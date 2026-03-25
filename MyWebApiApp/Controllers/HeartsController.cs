using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyWebApiApp.Interfaces;
using System.Security.Claims;

namespace MyWebApiApp.Controllers
{
    [Route("api/hearts")]
    [ApiController]
    public class HeartsController : ControllerBase
    {
        private readonly IHeartRepository _heartRepo;

        public HeartsController(IHeartRepository heartRepo)
        {
            _heartRepo = heartRepo;
        }
        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        [HttpGet]
        public async Task<IActionResult> GetHearts()
        {
            var userId = GetUserId();
            var hearts = await _heartRepo.GetHeartsAsync(userId);
            if (hearts == null)
            {
                return NotFound();
            }
            return Ok(hearts);
        }

        [HttpPost("refill")]
        public async Task<IActionResult> RefillHearts()
        {
            // TODO: implement logic refill hearts using item

            return Ok(new
            {
                message = "Refill hearts endpoint created (logic not implemented yet)"
            });
        }

        [HttpPost("practice")]
        public async Task<IActionResult> PracticeForHeart()
        {
            // TODO: implement practice lesson logic

            return Ok(new
            {
                message = "Practice for heart endpoint created (logic not implemented yet)"
            });
        }
    }
}
