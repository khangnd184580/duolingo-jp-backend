USE [DuolingoJP];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    IF OBJECT_ID(N'dbo.Tasks', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Tasks
        (
            TaskId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            TaskName NVARCHAR(255) NOT NULL,
            TaskType NVARCHAR(100) NOT NULL,
            TargetValue INT NOT NULL,
            RewardXP INT NOT NULL,
            RewardGems INT NOT NULL,
            IsDaily BIT NOT NULL
        );
    END

    IF OBJECT_ID(N'dbo.UserTasks', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.UserTasks
        (
            UserTaskId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId NVARCHAR(450) NOT NULL,
            TaskId INT NOT NULL,
            Progress INT NOT NULL,
            IsCompleted BIT NOT NULL,
            IsClaimed BIT NOT NULL,
            AssignedDate DATE NOT NULL,
            CONSTRAINT FK_UserTasks_Tasks_TaskId FOREIGN KEY (TaskId) REFERENCES dbo.Tasks(TaskId),
            CONSTRAINT FK_UserTasks_AspNetUsers_UserId FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
        );
    END

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserTasks_UserId_AssignedDate' AND object_id = OBJECT_ID(N'dbo.UserTasks'))
    BEGIN
        CREATE INDEX IX_UserTasks_UserId_AssignedDate ON dbo.UserTasks(UserId, AssignedDate);
    END

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;

