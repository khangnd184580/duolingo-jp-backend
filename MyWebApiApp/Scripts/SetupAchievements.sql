USE [DuolingoJP];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    IF OBJECT_ID(N'dbo.Achievements', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Achievements
        (
            AchievementId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Name NVARCHAR(255) NOT NULL,
            Description NVARCHAR(500) NOT NULL,
            IconUrl NVARCHAR(255) NOT NULL,
            RequiredValue INT NOT NULL,
            AchievementType NVARCHAR(50) NOT NULL
        );
    END

    IF OBJECT_ID(N'dbo.UserAchievements', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.UserAchievements
        (
            UserAchievementId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId NVARCHAR(450) NOT NULL,
            AchievementId INT NOT NULL,
            UnlockedAt DATETIME2 NOT NULL,
            IsClaimed BIT NOT NULL CONSTRAINT DF_UserAchievements_IsClaimed DEFAULT (0),
            ClaimedAt DATETIME2 NULL,
            CONSTRAINT FK_UserAchievements_AspNetUsers_UserId FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id),
            CONSTRAINT FK_UserAchievements_Achievements_AchievementId FOREIGN KEY (AchievementId) REFERENCES dbo.Achievements(AchievementId)
        );
    END

    IF COL_LENGTH('dbo.UserAchievements', 'IsClaimed') IS NULL
    BEGIN
        ALTER TABLE dbo.UserAchievements
            ADD IsClaimed BIT NOT NULL CONSTRAINT DF_UserAchievements_IsClaimed DEFAULT (0);
    END

    IF COL_LENGTH('dbo.UserAchievements', 'ClaimedAt') IS NULL
    BEGIN
        ALTER TABLE dbo.UserAchievements
            ADD ClaimedAt DATETIME2 NULL;
    END

    MERGE dbo.Achievements AS tgt
    USING (VALUES
        (N'Bài học đầu tiên', N'Hoàn thành bài học đầu tiên của bạn', N'/icons/first_lesson.png', 1, N'LESSON_COMPLETE'),
        (N'Người học chăm chỉ', N'Hoàn thành 10 bài học', N'/icons/lesson_10.png', 10, N'LESSON_COMPLETE'),
        (N'Bậc thầy bài học', N'Hoàn thành 50 bài học', N'/icons/lesson_50.png', 50, N'LESSON_COMPLETE'),
        (N'Người mới tích XP', N'Đạt 100 XP', N'/icons/xp_100.png', 100, N'TOTAL_XP'),
        (N'Cao thủ XP', N'Đạt 1000 XP', N'/icons/xp_1000.png', 1000, N'TOTAL_XP'),
        (N'Streak 3 ngày', N'Học liên tiếp trong 3 ngày', N'/icons/streak_3.png', 3, N'STREAK_DAYS'),
        (N'Streak 7 ngày', N'Học liên tiếp trong 7 ngày', N'/icons/streak_7.png', 7, N'STREAK_DAYS')
    ) AS src(Name, Description, IconUrl, RequiredValue, AchievementType)
    ON tgt.RequiredValue = src.RequiredValue
       AND tgt.AchievementType = src.AchievementType
    WHEN MATCHED THEN
        UPDATE SET
            Name = src.Name,
            Description = src.Description,
            IconUrl = src.IconUrl,
            RequiredValue = src.RequiredValue,
            AchievementType = src.AchievementType
    WHEN NOT MATCHED THEN
        INSERT (Name, Description, IconUrl, RequiredValue, AchievementType)
        VALUES (src.Name, src.Description, src.IconUrl, src.RequiredValue, src.AchievementType);

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;

