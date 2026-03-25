using Azure.Core;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.DTOs.Profile;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Repository;
using System.Security.Claims;

namespace MyWebApiApp.Controllers
{
    [Route("api/profile")]
    [ApiController]
    [Authorize]
    public class ProfileController : ControllerBase
    {
        private readonly IProfileRepository _profileRepo;
        public ProfileController(IProfileRepository profileRepo)
        {
            _profileRepo = profileRepo;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        [HttpGet("display")]
        public async Task<IActionResult> GetProfile()
        {
            var userId = GetUserId();

            var profile = await _profileRepo.GetProfileAsync(userId);

            if (profile == null)
                return NotFound();

            return Ok(profile);
        }

        [HttpPut("modify")]
        public async Task<IActionResult> UpdateProfile(UpdateProfileRequest request)
        {
            var userId = GetUserId();

            var profile = await _profileRepo.UpdateProfileAsync(userId, request);

            if (profile == null)
                return NotFound();

            return Ok(profile);
        }

        [HttpGet("summary/{userId}")]
        public async Task<ActionResult<UserSummaryDto>> GetUserSummary(string userId)
        {
            var summary = await _profileRepo.GetUserSummaryAsync(userId);

            if (summary == null)
            {
                return NotFound();
            }

            return Ok(summary);
        }
    }
}
