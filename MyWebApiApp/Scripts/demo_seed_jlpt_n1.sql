-- =========================================================
-- DEMO SQL SEED - JLPT N1
-- Tác dụng:
--   1) Tạo bộ bảng demo riêng để tránh đụng schema project hiện tại
--   2) Seed đầy đủ dữ liệu N1 theo khung yêu cầu
--   3) Có sẵn đáp án đúng trong bảng DemoJLPT_QuestionOptions (IsCorrect = 1)
--
-- Số liệu seed:
--   - 1 Level (N1)
--   - 2 Topics
--   - 6 Lessons
--   - 40 Questions
--   - 160 Options
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
    (1, N'N1', N'JLPT N1', 1);

    INSERT INTO dbo.DemoJLPT_Topics (TopicId, LevelId, TopicCode, TopicName, SortOrder)
    VALUES
    (1, 1, N'KANJI_N1', N'Kanji cao cấp', 1),
    (2, 1, N'MIXED_TEST', N'Luyện đề tổng hợp', 2);

    INSERT INTO dbo.DemoJLPT_Lessons (LessonId, TopicId, LessonCode, LessonName, Description, SortOrder)
    VALUES
    (1, 1, N'N1_KANJI_1', N'Kanji N1 - 顕', N'Ôn tập kanji N1: 顕 (けん) - rõ ràng, hiển hiện. Mỗi kanji có 5 câu trắc nghiệm.', 1),
    (2, 1, N'N1_KANJI_2', N'Kanji N1 - 懸', N'Ôn tập kanji N1: 懸 (けん) - treo, liên quan, lo lắng/sống chết. Mỗi kanji có 5 câu trắc nghiệm.', 2),
    (3, 1, N'N1_KANJI_3', N'Kanji N1 - 譲', N'Ôn tập kanji N1: 譲 (じょう) - nhường, chuyển nhượng. Mỗi kanji có 5 câu trắc nghiệm.', 3),
    (4, 1, N'N1_KANJI_4', N'Kanji N1 - 覆', N'Ôn tập kanji N1: 覆 (ふく) - phủ, lật đổ. Mỗi kanji có 5 câu trắc nghiệm.', 4),
    (5, 1, N'N1_KANJI_5', N'Kanji N1 - 措', N'Ôn tập kanji N1: 措 (そ) - đặt ra, áp dụng biện pháp. Mỗi kanji có 5 câu trắc nghiệm.', 5),
    (6, 2, N'N1_MIXED_DEMO_TEST', N'Luyện đề tổng hợp demo', N'Đề demo 15 câu: mỗi 3 câu tương ứng một level N5, N4, N3, N2, N1; mỗi level có 1 câu từ vựng, 1 câu kanji, 1 câu ngữ pháp.', 1);

    INSERT INTO dbo.DemoJLPT_Questions (QuestionId, LessonId, QuestionText, QuestionType, Explanation, SortOrder)
    VALUES
    (1, 1, N'Kanji nào đọc là けん trong từ hiển hiện?', N'MCQ', N'顕 trong 顕著 đọc là けん.', 1),
    (2, 1, N'Từ 顕著 có nghĩa là gì?', N'MCQ', N'顕著 nghĩa là nổi bật, rõ rệt.', 2),
    (3, 1, N'Cách đọc của 顕著 là gì?', N'MCQ', N'顕著 đọc là けんちょ.', 3),
    (4, 1, N'Từ nào chứa kanji 顕?', N'MCQ', N'顕著 là từ phổ biến chứa 顕.', 4),
    (5, 1, N'Câu nào dùng 顕著 đúng?', N'MCQ', N'顕著に現れる = xuất hiện rõ rệt.', 5),
    (6, 2, N'Kanji nào dùng trong từ 懸命?', N'MCQ', N'懸命 chứa kanji 懸.', 1),
    (7, 2, N'一生懸命 có nghĩa gần nhất là gì?', N'MCQ', N'一生懸命 nghĩa là cố gắng hết sức.', 2),
    (8, 2, N'Cách đọc của 一生懸命 là gì?', N'MCQ', N'Một cách đọc rất thông dụng ở trình độ cao.', 3),
    (9, 2, N'Từ nào chứa kanji 懸?', N'MCQ', N'懸念 là lo ngại.', 4),
    (10, 2, N'Câu nào dùng đúng?', N'MCQ', N'一生懸命に勉強する = học hết sức.', 5),
    (11, 3, N'Kanji nào đọc là じょう trong từ nhường bộ?', N'MCQ', N'譲歩 đọc là じょうほ.', 1),
    (12, 3, N'譲歩 có nghĩa là gì?', N'MCQ', N'譲歩 nghĩa là nhượng bộ.', 2),
    (13, 3, N'Cách đọc của 譲る là gì?', N'MCQ', N'譲る đọc là ゆずる.', 3),
    (14, 3, N'Từ nào chứa kanji 譲?', N'MCQ', N'譲歩 dùng kanji 譲.', 4),
    (15, 3, N'Câu nào đúng?', N'MCQ', N'Nhường chỗ ngồi là 席を譲る.', 5),
    (16, 4, N'Kanji nào dùng trong từ 覆う?', N'MCQ', N'覆う dùng kanji 覆.', 1),
    (17, 4, N'覆う có nghĩa là gì?', N'MCQ', N'覆う nghĩa là che phủ.', 2),
    (18, 4, N'Cách đọc của 覆面 là gì?', N'MCQ', N'覆面 đọc là ふくめん.', 3),
    (19, 4, N'Từ nào chứa kanji 覆?', N'MCQ', N'覆面 là từ chứa 覆.', 4),
    (20, 4, N'Câu nào đúng?', N'MCQ', N'Mây che kín bầu trời = 雲が空を覆う.', 5),
    (21, 5, N'Kanji nào đọc là そ trong từ biện pháp?', N'MCQ', N'措 trong 措置 đọc là そ.', 1),
    (22, 5, N'措置 có nghĩa là gì?', N'MCQ', N'措置 nghĩa là biện pháp hoặc xử lý.', 2),
    (23, 5, N'Cách đọc của 措置 là gì?', N'MCQ', N'措置 đọc là そち.', 3),
    (24, 5, N'Từ nào dùng đúng kanji 措?', N'MCQ', N'措置 là từ phổ biến nhất với 措.', 4),
    (25, 5, N'Câu nào đúng?', N'MCQ', N'取る + 措置 là collocation rất thường gặp.', 5),
    (26, 6, N'[N5 - Từ vựng] Từ みず có nghĩa là gì?', N'MCQ', N'みず là nước.', 1),
    (27, 6, N'[N5 - Kanji] Kanji nào có nghĩa là ''người''?', N'MCQ', N'人 nghĩa là người.', 2),
    (28, 6, N'[N5 - Ngữ pháp] Chọn trợ từ đúng: わたし___がくせいです。', N'MCQ', N'Cấu trúc giới thiệu dùng は.', 3),
    (29, 6, N'[N4 - Từ vựng] しゅみ nghĩa là gì?', N'MCQ', N'趣味 = sở thích.', 4),
    (30, 6, N'[N4 - Kanji] Kanji nào đọc là えき?', N'MCQ', N'駅 đọc là えき.', 5),
    (31, 6, N'[N4 - Ngữ pháp] Mẫu ～なければなりません dùng để diễn tả gì?', N'MCQ', N'～なければなりません = phải.', 6),
    (32, 6, N'[N3 - Từ vựng] けいけん nghĩa là gì?', N'MCQ', N'経験 = kinh nghiệm.', 7),
    (33, 6, N'[N3 - Kanji] Kanji nào đọc là じゅん trong từ 準備?', N'MCQ', N'準備 đọc là じゅんび.', 8),
    (34, 6, N'[N3 - Ngữ pháp] Mẫu ～ことになっている thường dùng để diễn tả gì?', N'MCQ', N'～ことになっている = theo quy định/đã được quyết định.', 9),
    (35, 6, N'[N2 - Từ vựng] 効率 có nghĩa là gì?', N'MCQ', N'効率 = hiệu suất.', 10),
    (36, 6, N'[N2 - Kanji] Kanji nào dùng trong từ 義務?', N'MCQ', N'義務 chứa kanji 務.', 11),
    (37, 6, N'[N2 - Ngữ pháp] Mẫu ～わけではない diễn tả ý gì?', N'MCQ', N'～わけではない = không hẳn/không phải là hoàn toàn.', 12),
    (38, 6, N'[N1 - Từ vựng] 顕著 có nghĩa là gì?', N'MCQ', N'顕著 = rõ ràng, nổi bật.', 13),
    (39, 6, N'[N1 - Kanji] Kanji nào đọc là そ trong từ 措置?', N'MCQ', N'措置 đọc là そち.', 14),
    (40, 6, N'[N1 - Ngữ pháp] Mẫu ～ざるを得ない có nghĩa gần nhất là gì?', N'MCQ', N'～ざるを得ない = không còn cách nào khác ngoài việc phải làm.', 15);

    INSERT INTO dbo.DemoJLPT_QuestionOptions (OptionId, QuestionId, OptionLabel, OptionText, IsCorrect, SortOrder)
    VALUES
    (1, 1, N'A', N'顕', 1, 1),
    (2, 1, N'B', N'懸', 0, 2),
    (3, 1, N'C', N'譲', 0, 3),
    (4, 1, N'D', N'騰', 0, 4),
    (5, 2, N'A', N'rõ ràng, nổi bật', 1, 1),
    (6, 2, N'B', N'tăng giá', 0, 2),
    (7, 2, N'C', N'nhường', 0, 3),
    (8, 2, N'D', N'treo', 0, 4),
    (9, 3, N'A', N'けんちょ', 1, 1),
    (10, 3, N'B', N'じょうとう', 0, 2),
    (11, 3, N'C', N'けんじょ', 0, 3),
    (12, 3, N'D', N'ゆずる', 0, 4),
    (13, 4, N'A', N'顕著', 1, 1),
    (14, 4, N'B', N'譲歩', 0, 2),
    (15, 4, N'C', N'騰貴', 0, 3),
    (16, 4, N'D', N'懸命', 0, 4),
    (17, 5, N'A', N'効果が顕著に現れた。', 1, 1),
    (18, 5, N'B', N'駅を顕べます。', 0, 2),
    (19, 5, N'C', N'水を顕みます。', 0, 3),
    (20, 5, N'D', N'部屋が顕いです。', 0, 4),
    (21, 6, N'A', N'懸', 1, 1),
    (22, 6, N'B', N'顕', 0, 2),
    (23, 6, N'C', N'措', 0, 3),
    (24, 6, N'D', N'覆', 0, 4),
    (25, 7, N'A', N'hết sức, chăm chỉ', 1, 1),
    (26, 7, N'B', N'che phủ hoàn toàn', 0, 2),
    (27, 7, N'C', N'bố trí', 0, 3),
    (28, 7, N'D', N'rõ ràng', 0, 4),
    (29, 8, N'A', N'いっしょうけんめい', 1, 1),
    (30, 8, N'B', N'いっしょうけんちょ', 0, 2),
    (31, 8, N'C', N'いっしょうふくめい', 0, 3),
    (32, 8, N'D', N'いっしょうそち', 0, 4),
    (33, 9, N'A', N'懸念', 1, 1),
    (34, 9, N'B', N'顕著', 0, 2),
    (35, 9, N'C', N'措置', 0, 3),
    (36, 9, N'D', N'覆面', 0, 4),
    (37, 10, N'A', N'彼は一生懸命に勉強した。', 1, 1),
    (38, 10, N'B', N'本を懸みました。', 0, 2),
    (39, 10, N'C', N'電車を懸しました。', 0, 3),
    (40, 10, N'D', N'空が懸いです。', 0, 4),
    (41, 11, N'A', N'譲', 1, 1),
    (42, 11, N'B', N'騰', 0, 2),
    (43, 11, N'C', N'顕', 0, 3),
    (44, 11, N'D', N'覆', 0, 4),
    (45, 12, N'A', N'nhượng bộ', 1, 1),
    (46, 12, N'B', N'tăng vọt', 0, 2),
    (47, 12, N'C', N'rõ rệt', 0, 3),
    (48, 12, N'D', N'bao phủ', 0, 4),
    (49, 13, N'A', N'ゆずる', 1, 1),
    (50, 13, N'B', N'おおう', 0, 2),
    (51, 13, N'C', N'たかまる', 0, 3),
    (52, 13, N'D', N'あらわれる', 0, 4),
    (53, 14, N'A', N'譲歩', 1, 1),
    (54, 14, N'B', N'騰落', 0, 2),
    (55, 14, N'C', N'顕著', 0, 3),
    (56, 14, N'D', N'覆面', 0, 4),
    (57, 15, N'A', N'席をお年寄りに譲った。', 1, 1),
    (58, 15, N'B', N'席を顕った。', 0, 2),
    (59, 15, N'C', N'水を譲んだ。', 0, 3),
    (60, 15, N'D', N'空が譲いです。', 0, 4),
    (61, 16, N'A', N'覆', 1, 1),
    (62, 16, N'B', N'措', 0, 2),
    (63, 16, N'C', N'懸', 0, 3),
    (64, 16, N'D', N'譲', 0, 4),
    (65, 17, N'A', N'che phủ', 1, 1),
    (66, 17, N'B', N'nhượng bộ', 0, 2),
    (67, 17, N'C', N'bố trí', 0, 3),
    (68, 17, N'D', N'lo ngại', 0, 4),
    (69, 18, N'A', N'ふくめん', 1, 1),
    (70, 18, N'B', N'そちめん', 0, 2),
    (71, 18, N'C', N'けんめん', 0, 3),
    (72, 18, N'D', N'じょうめん', 0, 4),
    (73, 19, N'A', N'覆面', 1, 1),
    (74, 19, N'B', N'措置', 0, 2),
    (75, 19, N'C', N'譲歩', 0, 3),
    (76, 19, N'D', N'顕著', 0, 4),
    (77, 20, N'A', N'雲が空を覆っている。', 1, 1),
    (78, 20, N'B', N'本を覆りました。', 0, 2),
    (79, 20, N'C', N'駅を覆べます。', 0, 3),
    (80, 20, N'D', N'空が覆しいです。', 0, 4),
    (81, 21, N'A', N'措', 1, 1),
    (82, 21, N'B', N'顕', 0, 2),
    (83, 21, N'C', N'懸', 0, 3),
    (84, 21, N'D', N'騰', 0, 4),
    (85, 22, N'A', N'biện pháp, xử lý', 1, 1),
    (86, 22, N'B', N'nhượng bộ', 0, 2),
    (87, 22, N'C', N'tăng giá', 0, 3),
    (88, 22, N'D', N'rõ ràng', 0, 4),
    (89, 23, N'A', N'そち', 1, 1),
    (90, 23, N'B', N'けんち', 0, 2),
    (91, 23, N'C', N'じょうち', 0, 3),
    (92, 23, N'D', N'ふくち', 0, 4),
    (93, 24, N'A', N'措置', 1, 1),
    (94, 24, N'B', N'顕著', 0, 2),
    (95, 24, N'C', N'懸念', 0, 3),
    (96, 24, N'D', N'覆面', 0, 4),
    (97, 25, N'A', N'安全のために必要な措置を取る。', 1, 1),
    (98, 25, N'B', N'駅を措みます。', 0, 2),
    (99, 25, N'C', N'空が措いです。', 0, 3),
    (100, 25, N'D', N'水を措りました。', 0, 4),
    (101, 26, N'A', N'nước', 1, 1),
    (102, 26, N'B', N'lửa', 0, 2),
    (103, 26, N'C', N'gió', 0, 3),
    (104, 26, N'D', N'đất', 0, 4),
    (105, 27, N'A', N'人', 1, 1),
    (106, 27, N'B', N'山', 0, 2),
    (107, 27, N'C', N'川', 0, 3),
    (108, 27, N'D', N'口', 0, 4),
    (109, 28, N'A', N'は', 1, 1),
    (110, 28, N'B', N'を', 0, 2),
    (111, 28, N'C', N'に', 0, 3),
    (112, 28, N'D', N'で', 0, 4),
    (113, 29, N'A', N'sở thích', 1, 1),
    (114, 29, N'B', N'bài tập', 0, 2),
    (115, 29, N'C', N'thời tiết', 0, 3),
    (116, 29, N'D', N'công việc', 0, 4),
    (117, 30, N'A', N'駅', 1, 1),
    (118, 30, N'B', N'院', 0, 2),
    (119, 30, N'C', N'旅', 0, 3),
    (120, 30, N'D', N'問', 0, 4),
    (121, 31, N'A', N'phải làm', 1, 1),
    (122, 31, N'B', N'đã làm rồi', 0, 2),
    (123, 31, N'C', N'muốn làm', 0, 3),
    (124, 31, N'D', N'được phép làm', 0, 4),
    (125, 32, N'A', N'kinh nghiệm', 1, 1),
    (126, 32, N'B', N'môi trường', 0, 2),
    (127, 32, N'C', N'sự chuẩn bị', 0, 3),
    (128, 32, N'D', N'cuộc họp', 0, 4),
    (129, 33, N'A', N'準', 1, 1),
    (130, 33, N'B', N'雑', 0, 2),
    (131, 33, N'C', N'件', 0, 3),
    (132, 33, N'D', N'局', 0, 4),
    (133, 34, N'A', N'quy định/đã được quyết định', 1, 1),
    (134, 34, N'B', N'so sánh hơn', 0, 2),
    (135, 34, N'C', N'mong muốn cá nhân', 0, 3),
    (136, 34, N'D', N'điều kiện giả định', 0, 4),
    (137, 35, N'A', N'hiệu suất', 1, 1),
    (138, 35, N'B', N'nghĩa vụ', 0, 2),
    (139, 35, N'C', N'đo lường', 0, 3),
    (140, 35, N'D', N'duy trì', 0, 4),
    (141, 36, N'A', N'務', 1, 1),
    (142, 36, N'B', N'率', 0, 2),
    (143, 36, N'C', N'導', 0, 3),
    (144, 36, N'D', N'営', 0, 4),
    (145, 37, N'A', N'không hẳn là...', 1, 1),
    (146, 37, N'B', N'nhất định phải', 0, 2),
    (147, 37, N'C', N'vừa mới', 0, 3),
    (148, 37, N'D', N'đang tiếp diễn', 0, 4),
    (149, 38, N'A', N'rõ ràng, nổi bật', 1, 1),
    (150, 38, N'B', N'nhượng bộ', 0, 2),
    (151, 38, N'C', N'biện pháp', 0, 3),
    (152, 38, N'D', N'lo ngại', 0, 4),
    (153, 39, N'A', N'措', 1, 1),
    (154, 39, N'B', N'覆', 0, 2),
    (155, 39, N'C', N'譲', 0, 3),
    (156, 39, N'D', N'顕', 0, 4),
    (157, 40, N'A', N'buộc phải', 1, 1),
    (158, 40, N'B', N'đã quen với', 0, 2),
    (159, 40, N'C', N'được phép', 0, 3),
    (160, 40, N'D', N'thử làm xem', 0, 4);

    -------------------------------------------------------------------------
    -- Map DEMO data into current project schema (EF-compatible)
    -- Keeps ALL question/option text exactly as seeded above (Unicode via N'...')
    -------------------------------------------------------------------------

    PRINT N'--- Mapping DemoJLPT_* (N1) -> current schema tables ---';

    -- 1) Ensure Level N1 exists
    IF NOT EXISTS (SELECT 1 FROM dbo.[Level] WHERE LevelName = N'N1')
    BEGIN
        INSERT INTO dbo.[Level] (LevelName) VALUES (N'N1');
    END

    DECLARE @LevelN1_Id INT = (SELECT TOP 1 LevelId FROM dbo.[Level] WHERE LevelName = N'N1');

    -- 2) Upsert Topics (by name within level)
    MERGE dbo.[Topic] AS tgt
    USING (
        SELECT DISTINCT TopicName
        FROM dbo.DemoJLPT_Topics
    ) AS src
    ON tgt.LevelId = @LevelN1_Id AND tgt.TopicName = src.TopicName
    WHEN NOT MATCHED THEN
        INSERT (TopicName, LevelId) VALUES (src.TopicName, @LevelN1_Id);

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
        INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN1_Id AND t.TopicName = d.TopicName
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
        INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN1_Id AND t.TopicName = dt.TopicName
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
            INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN1_Id AND t.TopicName = dt.TopicName
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
        (SELECT COUNT(*) FROM dbo.[Topic] WHERE LevelId = @LevelN1_Id) AS TopicCount_CurrentSchema_N1,
        (SELECT COUNT(*) FROM dbo.Lessons l INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN1_Id) AS LessonCount_CurrentSchema_N1,
        (SELECT COUNT(*) FROM dbo.Questions q INNER JOIN dbo.Lessons l ON l.LessonId = q.LessonId INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN1_Id) AS QuestionCount_CurrentSchema_N1,
        (SELECT COUNT(*) FROM dbo.QuestionOptions o INNER JOIN dbo.Questions q ON q.QuestionId = o.QuestionId INNER JOIN dbo.Lessons l ON l.LessonId = q.LessonId INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN1_Id) AS OptionCount_CurrentSchema_N1;

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
