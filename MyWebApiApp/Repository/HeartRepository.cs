using MyWebApiApp.Data;
using MyWebApiApp.DTOs.Heart;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;

namespace MyWebApiApp.Repository
{
    public class HeartRepository : IHeartRepository
    {
        private readonly ApplicationDbContext _context;
        private const int REFILL_MINUTES = 5;

        public HeartRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<HeartResponse?> GetHeartsAsync(string userId)
        {
            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                return null;

            RefillHearts(user);

            await _context.SaveChangesAsync();

            return new HeartResponse
            {
                CurrentHearts = user.CurrentHearts,
                MaxHearts = user.MaxHearts,
                NextRefillTime = user.CurrentHearts < user.MaxHearts
                    ? user.LastHeartRefillTime?.AddMinutes(REFILL_MINUTES)
                    : null
            };
        }

        public async Task<bool> LoseHeartAsync(string userId)
        {
            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                return false;

            RefillHearts(user);

            if (user.CurrentHearts <= 0)
                return false;

            user.CurrentHearts--;

            if (user.CurrentHearts < user.MaxHearts && user.LastHeartRefillTime == null)
                user.LastHeartRefillTime = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return true;
        }

        private void RefillHearts(AppUser user)
        {
            if (user.CurrentHearts >= user.MaxHearts)
            {
                user.LastHeartRefillTime = null;
                return;
            }

            if (user.LastHeartRefillTime == null)
                return;

            var minutesPassed = (DateTime.UtcNow - user.LastHeartRefillTime.Value).TotalMinutes;

            var heartsToAdd = (int)(minutesPassed / REFILL_MINUTES);

            if (heartsToAdd > 0)
            {
                user.CurrentHearts = Math.Min(user.MaxHearts, user.CurrentHearts + heartsToAdd);

                // Keep leftover minutes instead of resetting to "now"
                user.LastHeartRefillTime = user.LastHeartRefillTime.Value.AddMinutes(heartsToAdd * REFILL_MINUTES);

                if (user.CurrentHearts >= user.MaxHearts)
                {
                    user.LastHeartRefillTime = null;
                }
            }
        }
    }
}
