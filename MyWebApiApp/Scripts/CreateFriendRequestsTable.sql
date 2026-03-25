-- Friend requests / friendships (single table: Pending -> Accepted/Declined)
USE [DuolingoJP];
GO

IF OBJECT_ID(N'dbo.FriendRequests', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FriendRequests (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        RequesterId NVARCHAR(450) NOT NULL,
        AddresseeId NVARCHAR(450) NOT NULL,
        Status INT NOT NULL CONSTRAINT DF_FriendRequests_Status DEFAULT (0),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_FriendRequests_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT FK_FriendRequests_Requester FOREIGN KEY (RequesterId) REFERENCES dbo.AspNetUsers(Id),
        CONSTRAINT FK_FriendRequests_Addressee FOREIGN KEY (AddresseeId) REFERENCES dbo.AspNetUsers(Id)
    );

    CREATE INDEX IX_FriendRequests_Addressee_Status ON dbo.FriendRequests(AddresseeId, Status);
    CREATE INDEX IX_FriendRequests_Requester_Status ON dbo.FriendRequests(RequesterId, Status);

    PRINT 'Created FriendRequests table';
END
ELSE
    PRINT 'FriendRequests table already exists';
GO
