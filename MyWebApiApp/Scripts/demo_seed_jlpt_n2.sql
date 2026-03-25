-- =========================================================
-- DEMO SQL SEED - JLPT N2
-- Tác dụng:
--   1) Tạo bộ bảng demo riêng để tránh đụng schema project hiện tại
--   2) Seed đầy đủ dữ liệu N2 theo khung yêu cầu
--   3) Có sẵn đáp án đúng trong bảng DemoJLPT_QuestionOptions (IsCorrect = 1)
--
-- Số liệu seed:
--   - 1 Level (N2)
--   - 1 Topics
--   - 5 Lessons
--   - 25 Questions
--   - 100 Options
--
-- Gợi ý mapping về project thật:
--   DemoJLPT_Levels          -> Levels
--   DemoJLPT_Topics          -> Topics
--   DemoJLPT_Lessons         -> Lessons
--   DemoJLPT_Questions       -> Questions
--   DemoJLPT_QuestionOptions -> QuestionOptions / Answers
-- =========================================================

USE [DuolingoJP];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.DemoJLPT_QuestionOptions', N'U') IS NOT NULL DROP TABLE dbo.DemoJLPT_QuestionOptions;
    IF OBJECT_ID(N'dbo.DemoJLPT_Questions', N'U') IS NOT NULL DROP TABLE dbo.DemoJLPT_Questions;
    IF OBJECT_ID(N'dbo.DemoJLPT_Lessons', N'U') IS NOT NULL DROP TABLE dbo.DemoJLPT_Lessons;
    IF OBJECT_ID(N'dbo.DemoJLPT_Topics', N'U') IS NOT NULL DROP TABLE dbo.DemoJLPT_Topics;
    IF OBJECT_ID(N'dbo.DemoJLPT_Levels', N'U') IS NOT NULL DROP TABLE dbo.DemoJLPT_Levels;

    CREATE TABLE dbo.DemoJLPT_Levels
    (
        LevelId     INT            NOT NULL PRIMARY KEY,
        LevelCode   NVARCHAR(20)   NOT NULL,
        LevelName   NVARCHAR(100)  NOT NULL,
        SortOrder   INT            NOT NULL
    );

    CREATE TABLE dbo.DemoJLPT_Topics
    (
        TopicId      INT            NOT NULL PRIMARY KEY,
        LevelId      INT            NOT NULL,
        TopicCode    NVARCHAR(50)   NOT NULL,
        TopicName    NVARCHAR(200)  NOT NULL,
        SortOrder    INT            NOT NULL,
        CONSTRAINT FK_DemoJLPT_Topics_Levels
            FOREIGN KEY (LevelId) REFERENCES dbo.DemoJLPT_Levels(LevelId)
    );

    CREATE TABLE dbo.DemoJLPT_Lessons
    (
        LessonId      INT             NOT NULL PRIMARY KEY,
        TopicId       INT             NOT NULL,
        LessonCode    NVARCHAR(50)    NOT NULL,
        LessonName    NVARCHAR(200)   NOT NULL,
        Description   NVARCHAR(500)   NULL,
        SortOrder     INT             NOT NULL,
        CONSTRAINT FK_DemoJLPT_Lessons_Topics
            FOREIGN KEY (TopicId) REFERENCES dbo.DemoJLPT_Topics(TopicId)
    );

    CREATE TABLE dbo.DemoJLPT_Questions
    (
        QuestionId     INT              NOT NULL PRIMARY KEY,
        LessonId       INT              NOT NULL,
        QuestionText   NVARCHAR(1000)   NOT NULL,
        QuestionType   NVARCHAR(50)     NOT NULL DEFAULT N'MCQ',
        Explanation    NVARCHAR(1000)   NULL,
        SortOrder      INT              NOT NULL,
        CONSTRAINT FK_DemoJLPT_Questions_Lessons
            FOREIGN KEY (LessonId) REFERENCES dbo.DemoJLPT_Lessons(LessonId)
    );

    CREATE TABLE dbo.DemoJLPT_QuestionOptions
    (
        OptionId       INT              NOT NULL PRIMARY KEY,
        QuestionId     INT              NOT NULL,
        OptionLabel    NVARCHAR(5)      NOT NULL,
        OptionText     NVARCHAR(500)    NOT NULL,
        IsCorrect      BIT              NOT NULL,
        SortOrder      INT              NOT NULL,
        CONSTRAINT FK_DemoJLPT_Options_Questions
            FOREIGN KEY (QuestionId) REFERENCES dbo.DemoJLPT_Questions(QuestionId)
    );

    INSERT INTO dbo.DemoJLPT_Levels (LevelId, LevelCode, LevelName, SortOrder)
    VALUES
    (1, N'N2', N'JLPT N2', 1);

    INSERT INTO dbo.DemoJLPT_Topics (TopicId, LevelId, TopicCode, TopicName, SortOrder)
    VALUES
    (1, 1, N'KANJI_N2', N'Kanji thượng trung cấp', 1);

    INSERT INTO dbo.DemoJLPT_Lessons (LessonId, TopicId, LessonCode, LessonName, Description, SortOrder)
    VALUES
    (1, 1, N'N2_KANJI_1', N'Kanji N2 - 準', N'Ôn tập kanji N2: 準 (じゅん) - chuẩn, bán-, semi. Mỗi kanji có 5 câu trắc nghiệm.', 1),
    (2, 1, N'N2_KANJI_2', N'Kanji N2 - 維', N'Ôn tập kanji N2: 維 (い) - duy trì. Mỗi kanji có 5 câu trắc nghiệm.', 2),
    (3, 1, N'N2_KANJI_3', N'Kanji N2 - 測', N'Ôn tập kanji N2: 測 (そく) - đo lường. Mỗi kanji có 5 câu trắc nghiệm.', 3),
    (4, 1, N'N2_KANJI_4', N'Kanji N2 - 率', N'Ôn tập kanji N2: 率 (りつ) - tỉ lệ, hiệu suất. Mỗi kanji có 5 câu trắc nghiệm.', 4),
    (5, 1, N'N2_KANJI_5', N'Kanji N2 - 務', N'Ôn tập kanji N2: 務 (む) - nhiệm vụ, nghĩa vụ. Mỗi kanji có 5 câu trắc nghiệm.', 5);

    INSERT INTO dbo.DemoJLPT_Questions (QuestionId, LessonId, QuestionText, QuestionType, Explanation, SortOrder)
    VALUES
    (1, 1, N'Kanji nào đọc là じゅん?', N'MCQ', N'Kanji 準 thường đọc là じゅん.', 1),
    (2, 1, N'Ý nghĩa gần đúng của 準 là gì?', N'MCQ', N'準 mang nghĩa chuẩn hoặc bán-.', 2),
    (3, 1, N'Từ nào dùng đúng kanji 準?', N'MCQ', N'準備 nghĩa là chuẩn bị.', 3),
    (4, 1, N'Cách đọc của từ 準備 là gì?', N'MCQ', N'準備 đọc là じゅんび.', 4),
    (5, 1, N'Câu nào dùng 準 đúng nghĩa?', N'MCQ', N'準備 được dùng trong nghĩa chuẩn bị cho cuộc họp.', 5),
    (6, 2, N'Kanji nào đọc là い trong từ duy trì?', N'MCQ', N'維 trong 維持 đọc là い.', 1),
    (7, 2, N'Từ 維持 có nghĩa là gì?', N'MCQ', N'維持 nghĩa là duy trì.', 2),
    (8, 2, N'Cách đọc của 維持 là gì?', N'MCQ', N'維持 đọc là いじ.', 3),
    (9, 2, N'Từ nào chứa kanji 維?', N'MCQ', N'維持 là từ thông dụng chứa 維.', 4),
    (10, 2, N'Câu nào đúng với nghĩa của 維持?', N'MCQ', N'Giữ gìn sức khỏe là 健康を維持する.', 5),
    (11, 3, N'Kanji nào đọc là そく trong từ đo lường?', N'MCQ', N'測 trong 測定 đọc là そく.', 1),
    (12, 3, N'Từ 測定 nghĩa là gì?', N'MCQ', N'測定 là đo lường.', 2),
    (13, 3, N'Cách đọc của 測定 là gì?', N'MCQ', N'測定 đọc là そくてい.', 3),
    (14, 3, N'Từ nào dùng đúng kanji 測?', N'MCQ', N'測定 dùng kanji 測.', 4),
    (15, 3, N'Câu nào dùng 測 đúng?', N'MCQ', N'Đo nhiệt độ là 温度を測定する.', 5),
    (16, 4, N'Kanji nào đọc là りつ?', N'MCQ', N'率 thường đọc là りつ.', 1),
    (17, 4, N'Từ 効率 có nghĩa là gì?', N'MCQ', N'効率 nghĩa là hiệu suất.', 2),
    (18, 4, N'Cách đọc của 効率 là gì?', N'MCQ', N'効率 đọc là こうりつ.', 3),
    (19, 4, N'Từ nào chứa kanji 率?', N'MCQ', N'効率 là từ thường gặp chứa 率.', 4),
    (20, 4, N'Câu nào đúng?', N'MCQ', N'Nâng hiệu suất công việc là 仕事の効率を上げる.', 5),
    (21, 5, N'Kanji nào đọc là む trong từ nghĩa vụ?', N'MCQ', N'務 trong 義務 đọc là む.', 1),
    (22, 5, N'Từ 義務 nghĩa là gì?', N'MCQ', N'義務 là nghĩa vụ.', 2),
    (23, 5, N'Cách đọc của 義務 là gì?', N'MCQ', N'義務 đọc là ぎむ.', 3),
    (24, 5, N'Từ nào dùng đúng kanji 務?', N'MCQ', N'義務 chứa kanji 務.', 4),
    (25, 5, N'Câu nào dùng 義務 đúng?', N'MCQ', N'Nộp thuế là nghĩa vụ của công dân.', 5);

    INSERT INTO dbo.DemoJLPT_QuestionOptions (OptionId, QuestionId, OptionLabel, OptionText, IsCorrect, SortOrder)
    VALUES
    (1, 1, N'A', N'準', 1, 1),
    (2, 1, N'B', N'備', 0, 2),
    (3, 1, N'C', N'機', 0, 3),
    (4, 1, N'D', N'験', 0, 4),
    (5, 2, N'A', N'chuẩn, bán-, semi', 1, 1),
    (6, 2, N'B', N'biến mất', 0, 2),
    (7, 2, N'C', N'phỏng vấn', 0, 3),
    (8, 2, N'D', N'nộp đơn', 0, 4),
    (9, 3, N'A', N'準備', 1, 1),
    (10, 3, N'B', N'機会', 0, 2),
    (11, 3, N'C', N'経験', 0, 3),
    (12, 3, N'D', N'提出', 0, 4),
    (13, 4, N'A', N'じゅんび', 1, 1),
    (14, 4, N'B', N'けいけん', 0, 2),
    (15, 4, N'C', N'ていしゅつ', 0, 3),
    (16, 4, N'D', N'きかい', 0, 4),
    (17, 5, N'A', N'会議の準備をします。', 1, 1),
    (18, 5, N'B', N'空が準いです。', 0, 2),
    (19, 5, N'C', N'準で泳ぎます。', 0, 3),
    (20, 5, N'D', N'駅を準べます。', 0, 4),
    (21, 6, N'A', N'維', 1, 1),
    (22, 6, N'B', N'雑', 0, 2),
    (23, 6, N'C', N'測', 0, 3),
    (24, 6, N'D', N'率', 0, 4),
    (25, 7, N'A', N'duy trì', 1, 1),
    (26, 7, N'B', N'đo lường', 0, 2),
    (27, 7, N'C', N'tỉ lệ', 0, 3),
    (28, 7, N'D', N'hỗn tạp', 0, 4),
    (29, 8, N'A', N'いじ', 1, 1),
    (30, 8, N'B', N'そくてい', 0, 2),
    (31, 8, N'C', N'ざつ', 0, 3),
    (32, 8, N'D', N'りつ', 0, 4),
    (33, 9, N'A', N'維持', 1, 1),
    (34, 9, N'B', N'効率', 0, 2),
    (35, 9, N'C', N'雑誌', 0, 3),
    (36, 9, N'D', N'測定', 0, 4),
    (37, 10, N'A', N'健康を維持したいです。', 1, 1),
    (38, 10, N'B', N'本を維いています。', 0, 2),
    (39, 10, N'C', N'道を維ります。', 0, 3),
    (40, 10, N'D', N'電車を維ました。', 0, 4),
    (41, 11, N'A', N'測', 1, 1),
    (42, 11, N'B', N'率', 0, 2),
    (43, 11, N'C', N'務', 0, 3),
    (44, 11, N'D', N'導', 0, 4),
    (45, 12, N'A', N'đo lường', 1, 1),
    (46, 12, N'B', N'hướng dẫn', 0, 2),
    (47, 12, N'C', N'nghĩa vụ', 0, 3),
    (48, 12, N'D', N'tỉ lệ', 0, 4),
    (49, 13, N'A', N'そくてい', 1, 1),
    (50, 13, N'B', N'どうにゅう', 0, 2),
    (51, 13, N'C', N'む', 0, 3),
    (52, 13, N'D', N'りつ', 0, 4),
    (53, 14, N'A', N'測定', 1, 1),
    (54, 14, N'B', N'義務', 0, 2),
    (55, 14, N'C', N'導入', 0, 3),
    (56, 14, N'D', N'効率', 0, 4),
    (57, 15, N'A', N'温度を測定します。', 1, 1),
    (58, 15, N'B', N'駅を測びます。', 0, 2),
    (59, 15, N'C', N'本を測います。', 0, 3),
    (60, 15, N'D', N'空が測いです。', 0, 4),
    (61, 16, N'A', N'率', 1, 1),
    (62, 16, N'B', N'務', 0, 2),
    (63, 16, N'C', N'営', 0, 3),
    (64, 16, N'D', N'導', 0, 4),
    (65, 17, N'A', N'hiệu suất', 1, 1),
    (66, 17, N'B', N'kinh doanh', 0, 2),
    (67, 17, N'C', N'hướng dẫn', 0, 3),
    (68, 17, N'D', N'nghĩa vụ', 0, 4),
    (69, 18, N'A', N'こうりつ', 1, 1),
    (70, 18, N'B', N'えいぎょう', 0, 2),
    (71, 18, N'C', N'ぎむ', 0, 3),
    (72, 18, N'D', N'どうにゅう', 0, 4),
    (73, 19, N'A', N'効率', 1, 1),
    (74, 19, N'B', N'営業', 0, 2),
    (75, 19, N'C', N'義務', 0, 3),
    (76, 19, N'D', N'導入', 0, 4),
    (77, 20, N'A', N'仕事の効率を上げます。', 1, 1),
    (78, 20, N'B', N'電車を率べます。', 0, 2),
    (79, 20, N'C', N'水を率みます。', 0, 3),
    (80, 20, N'D', N'部屋が率いです。', 0, 4),
    (81, 21, N'A', N'務', 1, 1),
    (82, 21, N'B', N'営', 0, 2),
    (83, 21, N'C', N'導', 0, 3),
    (84, 21, N'D', N'準', 0, 4),
    (85, 22, N'A', N'nghĩa vụ', 1, 1),
    (86, 22, N'B', N'đo lường', 0, 2),
    (87, 22, N'C', N'duy trì', 0, 3),
    (88, 22, N'D', N'hướng dẫn', 0, 4),
    (89, 23, N'A', N'ぎむ', 1, 1),
    (90, 23, N'B', N'どうにゅう', 0, 2),
    (91, 23, N'C', N'そくてい', 0, 3),
    (92, 23, N'D', N'いじ', 0, 4),
    (93, 24, N'A', N'義務', 1, 1),
    (94, 24, N'B', N'営業', 0, 2),
    (95, 24, N'C', N'導入', 0, 3),
    (96, 24, N'D', N'準備', 0, 4),
    (97, 25, N'A', N'税金を払うのは国民の義務です。', 1, 1),
    (98, 25, N'B', N'義務で泳ぎます。', 0, 2),
    (99, 25, N'C', N'机を義務します。', 0, 3),
    (100, 25, N'D', N'空が義務いです。', 0, 4);

    -------------------------------------------------------------------------
    -- Map DEMO data into current project schema (EF-compatible)
    -- Keeps ALL question/option text exactly as seeded above (Unicode via N'...')
    -------------------------------------------------------------------------

    PRINT N'--- Mapping DemoJLPT_* (N2) -> current schema tables ---';

    -- 1) Ensure Level N2 exists
    IF NOT EXISTS (SELECT 1 FROM dbo.[Level] WHERE LevelName = N'N2')
    BEGIN
        INSERT INTO dbo.[Level] (LevelName) VALUES (N'N2');
    END

    DECLARE @LevelN2_Id INT = (SELECT TOP 1 LevelId FROM dbo.[Level] WHERE LevelName = N'N2');

    -- 2) Upsert Topics (by name within level)
    MERGE dbo.[Topic] AS tgt
    USING (
        SELECT DISTINCT TopicName
        FROM dbo.DemoJLPT_Topics
    ) AS src
    ON tgt.LevelId = @LevelN2_Id AND tgt.TopicName = src.TopicName
    WHEN NOT MATCHED THEN
        INSERT (TopicName, LevelId) VALUES (src.TopicName, @LevelN2_Id);

    -- 3) Upsert Lessons (by (TopicName, LessonName))
    ;WITH DemoLessons AS
    (
        SELECT
            dl.LessonId AS DemoLessonId,
            dt.TopicName,
            dl.LessonName
        FROM dbo.DemoJLPT_Lessons dl
        INNER JOIN dbo.DemoJLPT_Topics dt ON dt.TopicId = dl.TopicId
    )
    MERGE dbo.Lessons AS tgt
    USING (
        SELECT
            DemoLessonId,
            TopicId = t.TopicId,
            LessonName
        FROM DemoLessons d
        INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN2_Id AND t.TopicName = d.TopicName
    ) AS src
    ON tgt.TopicId = src.TopicId AND tgt.LessonName = src.LessonName
    WHEN NOT MATCHED THEN
        INSERT (LessonName, TopicId, BaseXP) VALUES (src.LessonName, src.TopicId, 10);

    -- 4) Insert Questions + map DemoQuestionId -> QuestionId
    IF OBJECT_ID(N'tempdb..#QuestionMap', N'U') IS NOT NULL DROP TABLE #QuestionMap;
    CREATE TABLE #QuestionMap
    (
        DemoQuestionId INT NOT NULL PRIMARY KEY,
        QuestionId INT NOT NULL
    );

    ;WITH LessonMap AS
    (
        SELECT
            dl.LessonId AS DemoLessonId,
            l.LessonId AS LessonId
        FROM dbo.DemoJLPT_Lessons dl
        INNER JOIN dbo.DemoJLPT_Topics dt ON dt.TopicId = dl.TopicId
        INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN2_Id AND t.TopicName = dt.TopicName
        INNER JOIN dbo.Lessons l ON l.TopicId = t.TopicId AND l.LessonName = dl.LessonName
    ),
    DemoQuestions AS
    (
        SELECT
            q.QuestionId AS DemoQuestionId,
            lm.LessonId,
            q.QuestionText AS Content,
            q.SortOrder AS OrderIndex
        FROM dbo.DemoJLPT_Questions q
        INNER JOIN LessonMap lm ON lm.DemoLessonId = q.LessonId
    )
    MERGE dbo.Questions AS tgt
    USING DemoQuestions AS src
    ON tgt.LessonId = src.LessonId
       AND tgt.OrderIndex = src.OrderIndex
       AND tgt.Content = src.Content
    WHEN NOT MATCHED THEN
        INSERT (LessonId, Content, OrderIndex) VALUES (src.LessonId, src.Content, src.OrderIndex)
    OUTPUT src.DemoQuestionId, inserted.QuestionId INTO #QuestionMap (DemoQuestionId, QuestionId);

    -- For questions that already existed (matched), add them to the map as well
    INSERT INTO #QuestionMap (DemoQuestionId, QuestionId)
    SELECT
        src.DemoQuestionId,
        q2.QuestionId
    FROM (
        SELECT
            q.QuestionId AS DemoQuestionId,
            lm.LessonId,
            q.QuestionText AS Content,
            q.SortOrder AS OrderIndex
        FROM dbo.DemoJLPT_Questions q
        INNER JOIN (
            SELECT
                dl.LessonId AS DemoLessonId,
                l.LessonId AS LessonId
            FROM dbo.DemoJLPT_Lessons dl
            INNER JOIN dbo.DemoJLPT_Topics dt ON dt.TopicId = dl.TopicId
            INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN2_Id AND t.TopicName = dt.TopicName
            INNER JOIN dbo.Lessons l ON l.TopicId = t.TopicId AND l.LessonName = dl.LessonName
        ) lm ON lm.DemoLessonId = q.LessonId
    ) AS src
    INNER JOIN dbo.Questions q2
        ON q2.LessonId = src.LessonId AND q2.OrderIndex = src.OrderIndex AND q2.Content = src.Content
    WHERE NOT EXISTS (SELECT 1 FROM #QuestionMap qm WHERE qm.DemoQuestionId = src.DemoQuestionId);

    -- 5) Upsert QuestionOptions (by (QuestionId, OptionText, IsCorrect))
    ;WITH DemoOptions AS
    (
        SELECT
            qm.QuestionId,
            o.OptionText,
            o.IsCorrect
        FROM dbo.DemoJLPT_QuestionOptions o
        INNER JOIN #QuestionMap qm ON qm.DemoQuestionId = o.QuestionId
    )
    MERGE dbo.QuestionOptions AS tgt
    USING DemoOptions AS src
    ON tgt.QuestionId = src.QuestionId
       AND tgt.OptionText = src.OptionText
       AND tgt.IsCorrect = src.IsCorrect
    WHEN NOT MATCHED THEN
        INSERT (QuestionId, OptionText, IsCorrect) VALUES (src.QuestionId, src.OptionText, src.IsCorrect);

    PRINT N'Mapping finished.';

    SELECT
        (SELECT COUNT(*) FROM dbo.[Topic] WHERE LevelId = @LevelN2_Id) AS TopicCount_CurrentSchema_N2,
        (SELECT COUNT(*) FROM dbo.Lessons l INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN2_Id) AS LessonCount_CurrentSchema_N2,
        (SELECT COUNT(*) FROM dbo.Questions q INNER JOIN dbo.Lessons l ON l.LessonId = q.LessonId INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN2_Id) AS QuestionCount_CurrentSchema_N2,
        (SELECT COUNT(*) FROM dbo.QuestionOptions o INNER JOIN dbo.Questions q ON q.QuestionId = o.QuestionId INNER JOIN dbo.Lessons l ON l.LessonId = q.LessonId INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN2_Id) AS OptionCount_CurrentSchema_N2;

    COMMIT TRANSACTION;
    PRINT N'Seed dữ liệu thành công.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorNumber INT = ERROR_NUMBER();

    PRINT N'Lỗi khi seed dữ liệu: ' + @ErrorMessage;
    RAISERROR(N'Seed thất bại. Error %d, Line %d: %s', 16, 1, @ErrorNumber, @ErrorLine, @ErrorMessage);
END CATCH;
