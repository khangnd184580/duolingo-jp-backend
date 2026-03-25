-- ============================================
-- WipeLearningTables.sql
-- Delete data only (keep tables/columns).
-- Order is important to satisfy FK constraints.
--
-- Usage (sqlcmd):
--   sqlcmd -S YOUR_SERVER -d DuolingoJP -E -i WipeLearningTables.sql
-- ============================================

USE [DuolingoJP];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    PRINT 'Deleting learning tables data...';

    -- Child-most tables first
    DELETE FROM dbo.UserAnswers;
    DELETE FROM dbo.LessonAttempts;
    DELETE FROM dbo.QuestionOptions;
    DELETE FROM dbo.Questions;
    DELETE FROM dbo.Lessons;
    DELETE FROM dbo.[Topic];

    PRINT 'Resetting identity seeds (if any)...';

    -- Reset identity (safe even if table is empty; assumes identity columns per EF models)
    DBCC CHECKIDENT (N'dbo.UserAnswers', RESEED, 0);
    DBCC CHECKIDENT (N'dbo.LessonAttempts', RESEED, 0);
    DBCC CHECKIDENT (N'dbo.QuestionOptions', RESEED, 0);
    DBCC CHECKIDENT (N'dbo.Questions', RESEED, 0);
    DBCC CHECKIDENT (N'dbo.Lessons', RESEED, 0);
    DBCC CHECKIDENT (N'dbo.[Topic]', RESEED, 0);

    COMMIT TRAN;

    PRINT 'Wipe completed.';

    -- Quick counts
    SELECT 'Topic' AS TableName, COUNT(*) AS [Count] FROM dbo.[Topic]
    UNION ALL SELECT 'Lessons', COUNT(*) FROM dbo.Lessons
    UNION ALL SELECT 'Questions', COUNT(*) FROM dbo.Questions
    UNION ALL SELECT 'QuestionOptions', COUNT(*) FROM dbo.QuestionOptions
    UNION ALL SELECT 'LessonAttempts', COUNT(*) FROM dbo.LessonAttempts
    UNION ALL SELECT 'UserAnswers', COUNT(*) FROM dbo.UserAnswers;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;

    PRINT 'Error occurred:';
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;
END CATCH;

