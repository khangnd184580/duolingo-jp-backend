-- =========================================================
-- DEMO SQL SEED - JLPT N4
-- Tác dụng:
--   1) Tạo bộ bảng demo riêng để tránh đụng schema project hiện tại
--   2) Seed đầy đủ dữ liệu N4 theo khung yêu cầu
--   3) Có sẵn đáp án đúng trong bảng DemoJLPT_QuestionOptions (IsCorrect = 1)
--
-- Số liệu seed:
--   - 1 Level (N4)
--   - 3 Topics
--   - 9 Lessons
--   - 45 Questions
--   - 180 Options
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
    (1, N'N4', N'JLPT N4', 1);

    INSERT INTO dbo.DemoJLPT_Topics (TopicId, LevelId, TopicCode, TopicName, SortOrder)
    VALUES
    (1, 1, N'VOCAB_N4', N'Từ vựng sơ trung cấp', 1),
    (2, 1, N'GRAMMAR_N4', N'Ngữ pháp sơ trung cấp', 2),
    (3, 1, N'KANJI_N4', N'Kanji sơ trung cấp', 3);

    INSERT INTO dbo.DemoJLPT_Lessons (LessonId, TopicId, LessonCode, LessonName, Description, SortOrder)
    VALUES
    (1, 1, N'N4_VOCAB_1', N'Sinh hoạt hằng ngày', N'Từ vựng N4 chủ đề sinh hoạt hằng ngày với 5 câu trắc nghiệm.', 1),
    (2, 1, N'N4_VOCAB_2', N'Di chuyển và đi lại', N'Từ vựng N4 chủ đề di chuyển và đi lại với 5 câu trắc nghiệm.', 2),
    (3, 2, N'N4_GRAMMAR_1', N'Mẫu câu 〜たことがある', N'Ngữ pháp N4: Mẫu câu diễn tả đã từng làm gì với 5 câu trắc nghiệm.', 1),
    (4, 2, N'N4_GRAMMAR_2', N'Mẫu câu 〜ながら', N'Ngữ pháp N4: Mẫu câu diễn tả hai hành động đồng thời với 5 câu trắc nghiệm.', 2),
    (5, 3, N'N4_KANJI_1', N'Kanji 駅', N'Kanji N4: Kanji 駅 với 5 câu trắc nghiệm.', 1),
    (6, 3, N'N4_KANJI_2', N'Kanji 電', N'Kanji N4: Kanji 電 với 5 câu trắc nghiệm.', 2),
    (7, 3, N'N4_KANJI_3', N'Kanji 旅', N'Kanji N4: Kanji 旅 với 5 câu trắc nghiệm.', 3),
    (8, 3, N'N4_KANJI_4', N'Kanji 勉', N'Kanji N4: Kanji 勉 với 5 câu trắc nghiệm.', 4),
    (9, 3, N'N4_KANJI_5', N'Kanji 業', N'Kanji N4: Kanji 業 với 5 câu trắc nghiệm.', 5);

    INSERT INTO dbo.DemoJLPT_Questions (QuestionId, LessonId, QuestionText, QuestionType, Explanation, SortOrder)
    VALUES
    (1, 1, N'Từ "朝ごはん" có nghĩa là gì?', N'MCQ', N'朝ごはん nghĩa là bữa sáng.', 1),
    (2, 1, N'Chọn từ tiếng Nhật đúng với nghĩa "giặt quần áo".', N'MCQ', N'洗濯 nghĩa là giặt quần áo / giặt giũ.', 2),
    (3, 1, N'Từ "掃除" có nghĩa là gì?', N'MCQ', N'掃除 nghĩa là dọn dẹp, lau chùi.', 3),
    (4, 1, N'Chọn từ tiếng Nhật đúng với nghĩa "bài tập về nhà".', N'MCQ', N'宿題 nghĩa là bài tập về nhà.', 4),
    (5, 1, N'Từ "休憩" có nghĩa là gì?', N'MCQ', N'休憩 nghĩa là nghỉ giải lao.', 5),
    (6, 2, N'Từ "地下鉄" có nghĩa là gì?', N'MCQ', N'地下鉄 nghĩa là tàu điện ngầm.', 1),
    (7, 2, N'Chọn từ tiếng Nhật đúng với nghĩa "vé tàu / vé xe".', N'MCQ', N'切符 nghĩa là vé tàu / vé xe.', 2),
    (8, 2, N'Từ "交差点" có nghĩa là gì?', N'MCQ', N'交差点 nghĩa là ngã tư / giao lộ.', 3),
    (9, 2, N'Chọn từ tiếng Nhật đúng với nghĩa "du lịch".', N'MCQ', N'旅行 nghĩa là du lịch, chuyến đi.', 4),
    (10, 2, N'Từ "駅" có nghĩa là gì?', N'MCQ', N'駅 nghĩa là nhà ga.', 5),
    (11, 3, N'Điền vào chỗ trống: 私は日本へ行ったことが ___。', N'MCQ', N'Mẫu 〜たことがある dùng để nói đã từng làm gì, ở đây cần あります.', 1),
    (12, 3, N'Mẫu câu "〜たことがある" dùng để diễn tả ý nào?', N'MCQ', N'〜たことがある diễn tả kinh nghiệm đã từng làm gì trong quá khứ.', 2),
    (13, 3, N'Câu nào đúng về mặt ngữ pháp?', N'MCQ', N'Cấu trúc đúng: động từ thể た + ことがある.', 3),
    (14, 3, N'Điền vào chỗ trống: この本を読んだことが ___ か。', N'MCQ', N'Trong câu hỏi với mẫu này, dạng đúng là ありますか.', 4),
    (15, 3, N'Câu "私はスキーをしたことがありません" có nghĩa gần đúng là gì?', N'MCQ', N'ありません ở đây diễn tả chưa từng có kinh nghiệm làm việc đó.', 5),
    (16, 4, N'Điền vào chỗ trống: 音楽を聞き ___ 勉強します。', N'MCQ', N'〜ながら dùng để diễn tả vừa làm A vừa làm B.', 1),
    (17, 4, N'Mẫu câu "〜ながら" dùng để diễn tả ý nào?', N'MCQ', N'〜ながら diễn tả hai hành động diễn ra cùng lúc.', 2),
    (18, 4, N'Câu nào dùng "〜ながら" đúng?', N'MCQ', N'Động từ đứng trước ながら thường ở dạng gốc bỏ ます.', 3),
    (19, 4, N'Điền vào chỗ trống: 彼は歩き ___ 電話しています。', N'MCQ', N'Với động từ 歩きます, bỏ ます thành 歩き rồi thêm ながら.', 4),
    (20, 4, N'Câu "コーヒーを飲みながら本を読みます" có nghĩa là gì?', N'MCQ', N'Câu này có nghĩa là vừa uống cà phê vừa đọc sách.', 5),
    (21, 5, N'Kanji "駅" có nghĩa là gì?', N'MCQ', N'駅 nghĩa là nhà ga.', 1),
    (22, 5, N'Cách đọc đúng của kanji "駅" là gì?', N'MCQ', N'駅 được đọc là えき.', 2),
    (23, 5, N'Từ nào dưới đây có chứa kanji "駅"?', N'MCQ', N'駅前 là từ có chứa kanji 駅.', 3),
    (24, 5, N'Chọn kanji đúng cho từ "えき".', N'MCQ', N'Từ えき được viết bằng kanji là 駅.', 4),
    (25, 5, N'Câu "駅で友だちを待ちます" có nghĩa gần đúng là gì?', N'MCQ', N'Câu này nghĩa là đợi bạn ở nhà ga.', 5),
    (26, 6, N'Kanji "電" có nghĩa gần đúng là gì?', N'MCQ', N'電 thường liên quan đến điện.', 1),
    (27, 6, N'Cách đọc đúng của kanji "電" trong từ 電車 là gì?', N'MCQ', N'Trong 電車, 電 được đọc là でん.', 2),
    (28, 6, N'Từ nào dưới đây có chứa kanji "電"?', N'MCQ', N'電話 là từ có chứa kanji 電.', 3),
    (29, 6, N'Chọn cách viết đúng của từ "でんわ".', N'MCQ', N'Từ でんわ được viết là 電話.', 4),
    (30, 6, N'Câu "電車で会社へ行きます" có nghĩa gần đúng là gì?', N'MCQ', N'Câu này nghĩa là đi đến công ty bằng tàu điện.', 5),
    (31, 7, N'Kanji "旅" có nghĩa là gì?', N'MCQ', N'旅 nghĩa là chuyến đi / du lịch.', 1),
    (32, 7, N'Cách đọc đúng của kanji "旅" là gì?', N'MCQ', N'旅 thường đọc là たび.', 2),
    (33, 7, N'Từ nào dưới đây có chứa kanji "旅"?', N'MCQ', N'旅行 và 旅館 đều có 旅, ở đây chọn 旅行.', 3),
    (34, 7, N'Chọn kanji đúng cho từ "たび".', N'MCQ', N'Từ たび được viết là 旅.', 4),
    (35, 7, N'Câu "旅が好きです" có nghĩa gần đúng là gì?', N'MCQ', N'Câu này nghĩa là thích du lịch / những chuyến đi.', 5),
    (36, 8, N'Kanji "勉" thường xuất hiện trong từ nào?', N'MCQ', N'勉 thường xuất hiện trong từ 勉強.', 1),
    (37, 8, N'Cách đọc đúng của kanji "勉" là gì?', N'MCQ', N'勉 được đọc là べん trong từ 勉強.', 2),
    (38, 8, N'Kanji "勉" liên quan gần nhất đến ý nào?', N'MCQ', N'勉 thường gắn với cố gắng, học tập.', 3),
    (39, 8, N'Chọn cách viết đúng của từ "べんきょう".', N'MCQ', N'Từ べんきょう được viết là 勉強.', 4),
    (40, 8, N'Câu "日本語を勉強しています" có nghĩa gần đúng là gì?', N'MCQ', N'Câu này nghĩa là đang học tiếng Nhật.', 5),
    (41, 9, N'Kanji "業" có nghĩa gần đúng là gì?', N'MCQ', N'業 thường liên quan đến nghề nghiệp, công việc, ngành.', 1),
    (42, 9, N'Cách đọc đúng của kanji "業" trong từ 授業 là gì?', N'MCQ', N'Trong từ 授業, 業 được đọc là ぎょう.', 2),
    (43, 9, N'Từ nào dưới đây có chứa kanji "業"?', N'MCQ', N'授業 là từ có chứa kanji 業.', 3),
    (44, 9, N'Chọn kanji đúng cho phần còn thiếu: 授___', N'MCQ', N'Từ 授業 được viết với kanji 業 ở phía sau.', 4),
    (45, 9, N'Câu "午後の授業は二時からです" có nghĩa gần đúng là gì?', N'MCQ', N'Câu này nghĩa là tiết học buổi chiều bắt đầu từ 2 giờ.', 5);

    INSERT INTO dbo.DemoJLPT_QuestionOptions (OptionId, QuestionId, OptionLabel, OptionText, IsCorrect, SortOrder)
    VALUES
    (1, 1, N'A', N'Bữa sáng', 1, 1),
    (2, 1, N'B', N'Bữa tối', 0, 2),
    (3, 1, N'C', N'Phòng ngủ', 0, 3),
    (4, 1, N'D', N'Trường học', 0, 4),
    (5, 2, N'A', N'料理', 0, 1),
    (6, 2, N'B', N'洗濯', 1, 2),
    (7, 2, N'C', N'運転', 0, 3),
    (8, 2, N'D', N'約束', 0, 4),
    (9, 3, N'A', N'Nghỉ ngơi', 0, 1),
    (10, 3, N'B', N'Làm việc', 0, 2),
    (11, 3, N'C', N'Dọn dẹp', 1, 3),
    (12, 3, N'D', N'Mua sắm', 0, 4),
    (13, 4, N'A', N'宿題', 1, 1),
    (14, 4, N'B', N'天気', 0, 2),
    (15, 4, N'C', N'手紙', 0, 3),
    (16, 4, N'D', N'病院', 0, 4),
    (17, 5, N'A', N'Đi bộ', 0, 1),
    (18, 5, N'B', N'Nghỉ giải lao', 1, 2),
    (19, 5, N'C', N'Nấu ăn', 0, 3),
    (20, 5, N'D', N'Chụp ảnh', 0, 4),
    (21, 6, N'A', N'Xe buýt', 0, 1),
    (22, 6, N'B', N'Máy bay', 0, 2),
    (23, 6, N'C', N'Tàu điện ngầm', 1, 3),
    (24, 6, N'D', N'Xe đạp', 0, 4),
    (25, 7, N'A', N'切符', 1, 1),
    (26, 7, N'B', N'荷物', 0, 2),
    (27, 7, N'C', N'財布', 0, 3),
    (28, 7, N'D', N'時間', 0, 4),
    (29, 8, N'A', N'Nhà ga', 0, 1),
    (30, 8, N'B', N'Giao lộ', 1, 2),
    (31, 8, N'C', N'Công viên', 0, 3),
    (32, 8, N'D', N'Khách sạn', 0, 4),
    (33, 9, N'A', N'運動', 0, 1),
    (34, 9, N'B', N'旅行', 1, 2),
    (35, 9, N'C', N'料理', 0, 3),
    (36, 9, N'D', N'試験', 0, 4),
    (37, 10, N'A', N'Nhà ga', 1, 1),
    (38, 10, N'B', N'Sân bay', 0, 2),
    (39, 10, N'C', N'Thư viện', 0, 3),
    (40, 10, N'D', N'Bệnh viện', 0, 4),
    (41, 11, N'A', N'します', 0, 1),
    (42, 11, N'B', N'あります', 1, 2),
    (43, 11, N'C', N'なります', 0, 3),
    (44, 11, N'D', N'いきます', 0, 4),
    (45, 12, N'A', N'Đang làm gì', 0, 1),
    (46, 12, N'B', N'Muốn làm gì', 0, 2),
    (47, 12, N'C', N'Đã từng làm gì', 1, 3),
    (48, 12, N'D', N'Không được làm gì', 0, 4),
    (49, 13, N'A', N'私は sushi を 食べることがある yesterday.', 0, 1),
    (50, 13, N'B', N'私は富士山を登ったことがある。', 1, 2),
    (51, 13, N'C', N'私は行くたことがある。', 0, 3),
    (52, 13, N'D', N'私は映画を見ながらことがある。', 0, 4),
    (53, 14, N'A', N'あります', 0, 1),
    (54, 14, N'B', N'ありますか', 1, 2),
    (55, 14, N'C', N'でした', 0, 3),
    (56, 14, N'D', N'ませんか', 0, 4),
    (57, 15, N'A', N'Tôi đã từng trượt tuyết nhiều lần', 0, 1),
    (58, 15, N'B', N'Tôi đang trượt tuyết', 0, 2),
    (59, 15, N'C', N'Tôi chưa từng trượt tuyết', 1, 3),
    (60, 15, N'D', N'Tôi muốn đi trượt tuyết', 0, 4),
    (61, 16, N'A', N'だけ', 0, 1),
    (62, 16, N'B', N'ので', 0, 2),
    (63, 16, N'C', N'ながら', 1, 3),
    (64, 16, N'D', N'まで', 0, 4),
    (65, 17, N'A', N'So sánh hai người', 0, 1),
    (66, 17, N'B', N'Hai hành động đồng thời', 1, 2),
    (67, 17, N'C', N'Nguyên nhân kết quả', 0, 3),
    (68, 17, N'D', N'Cấm đoán', 0, 4),
    (69, 18, N'A', N'テレビを見ながらご飯を食べます。', 1, 1),
    (70, 18, N'B', N'テレビを見ますながらご飯を食べます。', 0, 2),
    (71, 18, N'C', N'テレビを見たながらご飯を食べます。', 0, 3),
    (72, 18, N'D', N'テレビを見でながらご飯を食べます。', 0, 4),
    (73, 19, N'A', N'まで', 0, 1),
    (74, 19, N'B', N'しか', 0, 2),
    (75, 19, N'C', N'ながら', 1, 3),
    (76, 19, N'D', N'でも', 0, 4),
    (77, 20, N'A', N'Uống cà phê sau khi đọc sách', 0, 1),
    (78, 20, N'B', N'Vừa uống cà phê vừa đọc sách', 1, 2),
    (79, 20, N'C', N'Đọc sách trong quán cà phê ngày mai', 0, 3),
    (80, 20, N'D', N'Muốn uống cà phê và mua sách', 0, 4),
    (81, 21, N'A', N'Nhà ga', 1, 1),
    (82, 21, N'B', N'Con đường', 0, 2),
    (83, 21, N'C', N'Cầu', 0, 3),
    (84, 21, N'D', N'Thị trấn', 0, 4),
    (85, 22, N'A', N'えき', 1, 1),
    (86, 22, N'B', N'でん', 0, 2),
    (87, 22, N'C', N'たび', 0, 3),
    (88, 22, N'D', N'ぎょう', 0, 4),
    (89, 23, N'A', N'電話', 0, 1),
    (90, 23, N'B', N'駅前', 1, 2),
    (91, 23, N'C', N'旅行', 0, 3),
    (92, 23, N'D', N'勉強', 0, 4),
    (93, 24, N'A', N'業', 0, 1),
    (94, 24, N'B', N'電', 0, 2),
    (95, 24, N'C', N'駅', 1, 3),
    (96, 24, N'D', N'旅', 0, 4),
    (97, 25, N'A', N'Tôi đi học bằng tàu', 0, 1),
    (98, 25, N'B', N'Tôi mua vé ở nhà ga', 0, 2),
    (99, 25, N'C', N'Tôi gặp giáo viên ở lớp', 0, 3),
    (100, 25, N'D', N'Tôi đợi bạn ở nhà ga', 1, 4),
    (101, 26, N'A', N'Điện', 1, 1),
    (102, 26, N'B', N'Núi', 0, 2),
    (103, 26, N'C', N'Mưa', 0, 3),
    (104, 26, N'D', N'Sách', 0, 4),
    (105, 27, N'A', N'えき', 0, 1),
    (106, 27, N'B', N'べん', 0, 2),
    (107, 27, N'C', N'でん', 1, 3),
    (108, 27, N'D', N'たび', 0, 4),
    (109, 28, N'A', N'宿題', 0, 1),
    (110, 28, N'B', N'電話', 1, 2),
    (111, 28, N'C', N'交差点', 0, 3),
    (112, 28, N'D', N'掃除', 0, 4),
    (113, 29, N'A', N'電話', 1, 1),
    (114, 29, N'B', N'電車', 0, 2),
    (115, 29, N'C', N'駅話', 0, 3),
    (116, 29, N'D', N'旅話', 0, 4),
    (117, 30, N'A', N'Tôi về nhà bằng xe buýt', 0, 1),
    (118, 30, N'B', N'Tôi đến công ty bằng tàu điện', 1, 2),
    (119, 30, N'C', N'Tôi gọi điện cho công ty', 0, 3),
    (120, 30, N'D', N'Tôi nghỉ ở công ty', 0, 4),
    (121, 31, N'A', N'Âm nhạc', 0, 1),
    (122, 31, N'B', N'Du lịch / chuyến đi', 1, 2),
    (123, 31, N'C', N'Bài học', 0, 3),
    (124, 31, N'D', N'Nhà ga', 0, 4),
    (125, 32, N'A', N'たび', 1, 1),
    (126, 32, N'B', N'えき', 0, 2),
    (127, 32, N'C', N'でん', 0, 3),
    (128, 32, N'D', N'べん', 0, 4),
    (129, 33, N'A', N'勉強', 0, 1),
    (130, 33, N'B', N'交差点', 0, 2),
    (131, 33, N'C', N'旅行', 1, 3),
    (132, 33, N'D', N'宿題', 0, 4),
    (133, 34, N'A', N'旅', 1, 1),
    (134, 34, N'B', N'駅', 0, 2),
    (135, 34, N'C', N'業', 0, 3),
    (136, 34, N'D', N'勉', 0, 4),
    (137, 35, N'A', N'Tôi thích học bài', 0, 1),
    (138, 35, N'B', N'Tôi thích du lịch', 1, 2),
    (139, 35, N'C', N'Tôi thích nhà ga', 0, 3),
    (140, 35, N'D', N'Tôi thích công việc', 0, 4),
    (141, 36, N'A', N'勉強', 1, 1),
    (142, 36, N'B', N'駅前', 0, 2),
    (143, 36, N'C', N'旅行', 0, 3),
    (144, 36, N'D', N'電話', 0, 4),
    (145, 37, N'A', N'ぎょう', 0, 1),
    (146, 37, N'B', N'べん', 1, 2),
    (147, 37, N'C', N'えき', 0, 3),
    (148, 37, N'D', N'でん', 0, 4),
    (149, 38, N'A', N'Ăn uống', 0, 1),
    (150, 38, N'B', N'Học tập / cố gắng', 1, 2),
    (151, 38, N'C', N'Đi lại', 0, 3),
    (152, 38, N'D', N'Thời tiết', 0, 4),
    (153, 39, N'A', N'勉強', 1, 1),
    (154, 39, N'B', N'電強', 0, 2),
    (155, 39, N'C', N'駅強', 0, 3),
    (156, 39, N'D', N'旅強', 0, 4),
    (157, 40, N'A', N'Tôi đang dạy tiếng Nhật', 0, 1),
    (158, 40, N'B', N'Tôi đang nói tiếng Nhật', 0, 2),
    (159, 40, N'C', N'Tôi đang học tiếng Nhật', 1, 3),
    (160, 40, N'D', N'Tôi đang đọc truyện Nhật', 0, 4),
    (161, 41, N'A', N'Cây cối', 0, 1),
    (162, 41, N'B', N'Nghề nghiệp / công việc / ngành', 1, 2),
    (163, 41, N'C', N'Thức ăn', 0, 3),
    (164, 41, N'D', N'Nhà cửa', 0, 4),
    (165, 42, N'A', N'ぎょう', 1, 1),
    (166, 42, N'B', N'べん', 0, 2),
    (167, 42, N'C', N'たび', 0, 3),
    (168, 42, N'D', N'でん', 0, 4),
    (169, 43, N'A', N'休憩', 0, 1),
    (170, 43, N'B', N'地下鉄', 0, 2),
    (171, 43, N'C', N'授業', 1, 3),
    (172, 43, N'D', N'洗濯', 0, 4),
    (173, 44, N'A', N'駅', 0, 1),
    (174, 44, N'B', N'旅', 0, 2),
    (175, 44, N'C', N'業', 1, 3),
    (176, 44, N'D', N'電', 0, 4),
    (177, 45, N'A', N'Buổi học chiều bắt đầu từ 2 giờ', 1, 1),
    (178, 45, N'B', N'Tôi tan học lúc 2 giờ', 0, 2),
    (179, 45, N'C', N'Tôi học 2 môn vào buổi chiều', 0, 3),
    (180, 45, N'D', N'Lớp học ngày mai bị hủy', 0, 4);

    -------------------------------------------------------------------------
    -- Map DEMO data into current project schema (EF-compatible)
    -- Keeps ALL question/option text exactly as seeded above (Unicode via N'...')
    -------------------------------------------------------------------------

    PRINT N'--- Mapping DemoJLPT_* (N4) -> current schema tables ---';

    -- 1) Ensure Level N4 exists
    IF NOT EXISTS (SELECT 1 FROM dbo.[Level] WHERE LevelName = N'N4')
    BEGIN
        INSERT INTO dbo.[Level] (LevelName) VALUES (N'N4');
    END

    DECLARE @LevelN4_Id INT = (SELECT TOP 1 LevelId FROM dbo.[Level] WHERE LevelName = N'N4');

    -- 2) Upsert Topics (by name within level)
    MERGE dbo.[Topic] AS tgt
    USING (
        SELECT DISTINCT TopicName
        FROM dbo.DemoJLPT_Topics
    ) AS src
    ON tgt.LevelId = @LevelN4_Id AND tgt.TopicName = src.TopicName
    WHEN NOT MATCHED THEN
        INSERT (TopicName, LevelId) VALUES (src.TopicName, @LevelN4_Id);

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
        INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN4_Id AND t.TopicName = d.TopicName
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
        INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN4_Id AND t.TopicName = dt.TopicName
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
            INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN4_Id AND t.TopicName = dt.TopicName
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
        (SELECT COUNT(*) FROM dbo.[Topic] WHERE LevelId = @LevelN4_Id) AS TopicCount_CurrentSchema_N4,
        (SELECT COUNT(*) FROM dbo.Lessons l INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN4_Id) AS LessonCount_CurrentSchema_N4,
        (SELECT COUNT(*) FROM dbo.Questions q INNER JOIN dbo.Lessons l ON l.LessonId = q.LessonId INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN4_Id) AS QuestionCount_CurrentSchema_N4,
        (SELECT COUNT(*) FROM dbo.QuestionOptions o INNER JOIN dbo.Questions q ON q.QuestionId = o.QuestionId INNER JOIN dbo.Lessons l ON l.LessonId = q.LessonId INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN4_Id) AS OptionCount_CurrentSchema_N4;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;

-- Kiểm tra nhanh sau khi seed
SELECT COUNT(*) AS LevelCount FROM dbo.DemoJLPT_Levels;
SELECT COUNT(*) AS TopicCount FROM dbo.DemoJLPT_Topics;
SELECT COUNT(*) AS LessonCount FROM dbo.DemoJLPT_Lessons;
SELECT COUNT(*) AS QuestionCount FROM dbo.DemoJLPT_Questions;
SELECT COUNT(*) AS OptionCount FROM dbo.DemoJLPT_QuestionOptions;