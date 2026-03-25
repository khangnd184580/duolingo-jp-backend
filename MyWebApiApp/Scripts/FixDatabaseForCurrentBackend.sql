-- ============================================
-- Align UserItems with MyWebApiApp.Models.UserItem / EF snapshot
-- Idempotent — safe to run multiple times
-- ============================================
-- Change database name if yours differs (must match appsettings ConnectionStrings)
USE [DuolingoJP];
GO

SET NOCOUNT ON;

-- 1) Shop / inventory: IsEquipped (required by ShopRepository)
IF COL_LENGTH('dbo.UserItems', 'IsEquipped') IS NULL
BEGIN
    ALTER TABLE dbo.UserItems ADD IsEquipped BIT NOT NULL
        CONSTRAINT DF_UserItems_IsEquipped DEFAULT (0);
    PRINT 'Added UserItems.IsEquipped';
END
ELSE
    PRINT 'UserItems.IsEquipped already exists';

-- 2) PK column name: EF model uses property Id → column should be "Id"
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.UserItems') AND name = N'UserItemId')
   AND NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.UserItems') AND name = N'Id')
BEGIN
    EXEC sp_rename N'dbo.UserItems.UserItemId', N'Id', N'COLUMN';
    PRINT 'Renamed UserItems.UserItemId -> Id';
END
ELSE IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.UserItems') AND name = N'Id')
    PRINT 'UserItems primary key column already named Id';
ELSE
    PRINT 'UserItems PK column: no rename needed (unexpected layout — check manually)';

PRINT 'FixDatabaseForCurrentBackend completed.';
