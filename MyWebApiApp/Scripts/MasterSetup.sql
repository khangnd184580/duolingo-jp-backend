-- ============================================
-- MASTER SETUP — schema fixes + learning seed + shop seed
-- Matches MyWebApiApp EF models (NOT the old Units/Nodes scripts).
--
-- Run from this folder so :r paths resolve:
--   cd ...\MyWebApiApp\Scripts
--   sqlcmd -S YOUR_SERVER -d DuolingoJP -E -i MasterSetup.sql
--
-- Or run each file in order in SSMS.
-- ============================================

PRINT '=== 1/3 FixDatabaseForCurrentBackend ===';
:r FixDatabaseForCurrentBackend.sql

PRINT '=== 2/3 SeedLearningContent_EfCompatible ===';
:r SeedLearningContent_EfCompatible.sql

PRINT '=== 3/4 SeedShopItems ===';
:r SeedShopItems.sql

PRINT '=== 4/4 CreateFriendRequestsTable ===';
:r CreateFriendRequestsTable.sql

PRINT '';
PRINT 'MasterSetup finished.';
