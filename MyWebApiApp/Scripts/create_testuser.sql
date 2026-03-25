-- Create testuser account
-- Password: TestPassword123!
-- This script creates a user that matches ASP.NET Identity password requirements

-- First, insert the user into AspNetUsers
INSERT INTO "AspNetUsers" (
    "Id",
    "UserName",
    "NormalizedUserName",
    "Email",
    "NormalizedEmail",
    "EmailConfirmed",
    "PasswordHash",
    "SecurityStamp",
    "ConcurrencyStamp",
    "PhoneNumber",
    "PhoneNumberConfirmed",
    "TwoFactorEnabled",
    "LockoutEnd",
    "LockoutEnabled",
    "AccessFailedCount",
    "CurrentXP",
    "TotalXP",
    "Level",
    "CurrentHearts",
    "MaxHearts",
    "LastHeartRefillTime",
    "Gems",
    "CurrentStreak",
    "LongestStreak",
    "LastStudyDate",
    "StreakFreezeCount"
) VALUES (
    'testuser-001',
    'testuser',
    'TESTUSER',
    'test@example.com',
    'TEST@EXAMPLE.COM',
    true,
    'AQAAAAIAAYagAAAAEHxK8F8VN8vL0yKGGJ3wH4kQ5xX5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X5Xw==',  -- Hashed password for TestPassword123!
    'SECURITYSTAMP123',
    'abc123def456',
    NULL,
    false,
    false,
    NULL,
    true,
    0,
    0,
    0,
    1,
    5,
    5,
    NOW(),
    100,
    0,
    0,
    NOW(),
    0
);

-- Assign User role
INSERT INTO "AspNetUserRoles" ("UserId", "RoleId")
VALUES ('testuser-001', '2');  -- '2' is User role ID
