using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using MyWebApiApp.Data;
using MyWebApiApp.Interfaces;
using MyWebApiApp.Models;
using MyWebApiApp.Services;
using Swashbuckle.AspNetCore.SwaggerGen;
using Swashbuckle.AspNetCore.SwaggerUI;
using Swashbuckle.AspNetCore;
using Microsoft.OpenApi;
using Microsoft.OpenApi.Models;
using MyWebApiApp.Repository;



namespace MyWebApiApp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            builder.Services.AddControllers();
            
            // CORS Configuration for Flutter app
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowFlutterApp", policy =>
                {
                    policy.AllowAnyOrigin()
                          .AllowAnyMethod()
                          .AllowAnyHeader();
                });
            });
            
            // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen(options =>
            {
                options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    In = ParameterLocation.Header,
                    Description = "Please enter a valid token",
                    Name = "Authorization",
                    Type = SecuritySchemeType.Http,
                    Scheme = "bearer",
                    BearerFormat = "JWT"
                });

                options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
            });


            // Database Configuration - Auto-detect SQL Server or PostgreSQL
            var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
            var usePostgres = builder.Configuration.GetValue<bool>("UsePostgreSQL");
            
            builder.Services.AddDbContext<ApplicationDbContext>(options =>
            {
                if (usePostgres)
                {
                    options.UseNpgsql(connectionString);
                }
                else
                {
                    options.UseSqlServer(connectionString);
                }
            });

            builder.Services.AddIdentity<AppUser, IdentityRole>(options =>
            {
                options.Password.RequireDigit = true;
                options.Password.RequireLowercase = true;
                options.Password.RequireUppercase = true;
                options.Password.RequireNonAlphanumeric = true;
                options.Password.RequiredLength = 12;
            })
            .AddEntityFrameworkStores<ApplicationDbContext>();

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme =
                options.DefaultChallengeScheme =
                options.DefaultForbidScheme =
                options.DefaultScheme =
                options.DefaultSignInScheme =
                options.DefaultSignOutScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = builder.Configuration["JWT:Issuer"],
                    ValidateAudience = true,
                    ValidAudience = builder.Configuration["JWT:Audience"],
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(
                        System.Text.Encoding.UTF8.GetBytes(builder.Configuration["JWT:SigningKey"])
                    )
                };
            });


            builder.Services.AddScoped<ITokenService, TokenService>();
            builder.Services.AddScoped<IAlphabetRepository, AlphabetRepository>();
            builder.Services.AddScoped<IShopRepository, ShopRepository>();
            builder.Services.AddScoped<ILearningRepository, LearningRepository>();
            builder.Services.AddScoped<ILessonAttemptRepository, LessonAttemptRepository>();
            builder.Services.AddScoped<IProfileRepository, ProfileRepository>();
            builder.Services.AddScoped<IStreakRepository, StreakRepository>();
            builder.Services.AddScoped<IHeartRepository, HeartRepository>();
            builder.Services.AddScoped<IAchievementRepository, AchievementRepository>();
            builder.Services.AddScoped<IAchievementService, AchievementService>();
            builder.Services.AddScoped<ITaskRepository, TaskRepository>();
            builder.Services.AddScoped<ILeaderboardRepository, LeaderboardRepository>();
            builder.Services.AddScoped<IFriendRepository, FriendRepository>();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {

                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseCors("AllowFlutterApp");
            app.UseHttpsRedirection();
            app.UseAuthentication();
            app.UseAuthorization();



            app.MapControllers();

            app.Run();
        }
    }
}
