-- ============================================
-- Seed Data for Shop Items (Items table — matches EF)
-- ============================================
USE [DuolingoJP];
GO

PRINT 'Seeding Shop Items...';

-- ============================================
-- SEED ITEMS (Shop Products)
-- ============================================
IF NOT EXISTS (SELECT 1 FROM Items WHERE ItemId = 1)
BEGIN
    SET IDENTITY_INSERT Items ON;
    
    INSERT INTO Items (ItemId, Name, Description, Price, Category, ImageUrl, IsActive) VALUES
    -- Power-ups
    (1, 'Streak Freeze', 'Protect your streak for one day if you forget to practice', 200, 'PowerUp', '/images/items/streak-freeze.png', 1),
    (2, 'Heart Refill', 'Instantly refill all your hearts', 350, 'PowerUp', '/images/items/heart-refill.png', 1),
    (3, 'Double XP Boost', 'Earn 2x XP for 15 minutes', 150, 'PowerUp', '/images/items/double-xp.png', 1),
    (4, 'Timer Boost', 'Get extra time on timed challenges', 100, 'PowerUp', '/images/items/timer-boost.png', 1),
    
    -- Cosmetics
    (5, 'Golden Owl Avatar', 'Show off with a premium avatar', 500, 'Cosmetic', '/images/items/golden-owl.png', 1),
    (6, 'Cherry Blossom Theme', 'Beautiful sakura-themed interface', 800, 'Cosmetic', '/images/items/sakura-theme.png', 1),
    (7, 'Samurai Avatar', 'Traditional samurai warrior avatar', 600, 'Cosmetic', '/images/items/samurai-avatar.png', 1),
    (8, 'Ninja Avatar', 'Stealthy ninja avatar', 600, 'Cosmetic', '/images/items/ninja-avatar.png', 1),
    
    -- Subscriptions
    (9, 'Premium Monthly', 'Unlimited hearts, no ads, offline lessons', 1200, 'Subscription', '/images/items/premium.png', 1),
    (10, 'Study Pack (5 Hearts)', 'Get 5 extra hearts instantly', 50, 'Consumable', '/images/items/heart-pack.png', 1),
    
    -- Special Items
    (11, 'Weekend Streak Repair', 'Repair your streak if broken within 7 days', 400, 'PowerUp', '/images/items/streak-repair.png', 1),
    (12, 'Legendary Chest', 'Mystery box with random rewards', 1000, 'Mystery', '/images/items/legendary-chest.png', 1),
    (13, 'XP Boost Bundle', '3x Double XP Boosts', 400, 'Bundle', '/images/items/xp-bundle.png', 1),
    (14, 'Heart Protection', 'Lose only half hearts for wrong answers (1 hour)', 250, 'PowerUp', '/images/items/heart-protection.png', 1),
    (15, 'Lucky Charm', 'Higher chance of getting rare items', 700, 'Special', '/images/items/lucky-charm.png', 1);
    
    SET IDENTITY_INSERT Items OFF;
    PRINT '✓ Items seeded successfully';
END
ELSE
BEGIN
    PRINT '✓ Items already exist';
END

-- ============================================
-- VERIFICATION
-- ============================================
PRINT '';
PRINT '========== SHOP ITEMS VERIFICATION ==========';

SELECT 
    Category,
    COUNT(*) as ItemCount,
    AVG(Price) as AvgPrice
FROM Items
WHERE IsActive = 1
GROUP BY Category;

PRINT '';
SELECT * FROM Items WHERE IsActive = 1 ORDER BY Category, Price;

PRINT '';
PRINT '========== SHOP SEEDING COMPLETED! ==========';
