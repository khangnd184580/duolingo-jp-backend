using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using MyWebApiApp.Models;
using System.Reflection.Emit;

namespace MyWebApiApp.Data
{
    public class ApplicationDbContext : IdentityDbContext<AppUser>
    {
        public ApplicationDbContext(DbContextOptions dbContextOptions) : base(dbContextOptions)
        {
            
        }

        public DbSet<Alphabet> Alphabets { get; set; }
        public DbSet<Item> Items { get; set; }
        public DbSet<UserItem> UserItems { get; set; }
        public DbSet<Lesson> Lessons { get; set; }
        public DbSet<UserProgress> UserProgress { get; set; }
        public DbSet<Question> Questions { get; set; }
        public DbSet<QuestionOption> QuestionOptions { get; set; }
        public DbSet<LessonAttempt> LessonAttempts { get; set; }
        public DbSet<UserAnswer> UserAnswers { get; set; }
        public DbSet<VwPopularItem> VwPopularItems { get; set; }
        public DbSet<Achievement> Achievements { get; set; }
        public DbSet<UserAchievement> UserAchievements { get; set; }
        public DbSet<TaskItem> Tasks { get; set; }
        public DbSet<UserTask> UserTasks { get; set; }
        public DbSet<FriendRequest> FriendRequests { get; set; }
        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);
            builder.Entity<Item>()
                .ToTable("Items");

            // Configure Question entity
            builder.Entity<Question>()
                    .HasMany(q => q.QuestionOptions)
                    .WithOne(o => o.Question)
                    .HasForeignKey(o => o.QuestionId)
                    .OnDelete(DeleteBehavior.Cascade);

            List<IdentityRole> roles = new List<IdentityRole>
            {
                new IdentityRole
                {
                    Id = "1",
                    Name = "Admin",
                    NormalizedName = "ADMIN",
                    ConcurrencyStamp = "1"
                },
                new IdentityRole
                {
                    Id = "2",
                    Name = "User",
                    NormalizedName = "USER",
                    ConcurrencyStamp = "2"
                },
            };
            builder.Entity<IdentityRole>().HasData(roles);

            builder.Entity<FriendRequest>(e =>
            {
                e.ToTable("FriendRequests");
                e.HasIndex(x => new { x.AddresseeId, x.Status });
                e.HasIndex(x => new { x.RequesterId, x.Status });
            });
        }
    }
}
