-- =========================================================
-- DEMO SQL SEED - JLPT N3
-- Tác dụng:
--   1) Tạo bộ bảng demo riêng để tránh đụng schema project hiện tại
--   2) Seed đầy đủ dữ liệu N3 theo khung yêu cầu
--   3) Có sẵn đáp án đúng trong bảng DemoJLPT_QuestionOptions (IsCorrect = 1)
--
-- Số liệu seed:
--   - 1 Level (N3)
--   - 5 Topics
--   - 11 Lessons
--   - 47 Questions
--   - 188 Options
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
        Description   NVARCHAR(1000)  NULL,
        SortOrder     INT             NOT NULL,
        CONSTRAINT FK_DemoJLPT_Lessons_Topics
            FOREIGN KEY (TopicId) REFERENCES dbo.DemoJLPT_Topics(TopicId)
    );

    CREATE TABLE dbo.DemoJLPT_Questions
    (
        QuestionId     INT              NOT NULL PRIMARY KEY,
        LessonId       INT              NOT NULL,
        QuestionText   NVARCHAR(MAX)    NOT NULL,
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
    (1, N'N3', N'JLPT N3', 1);

    INSERT INTO dbo.DemoJLPT_Topics (TopicId, LevelId, TopicCode, TopicName, SortOrder)
    VALUES
    (1, 1, N'READING_N3', N'Đọc hiểu trình độ N5-N4', 1),
    (2, 1, N'DIALOGUE_N3', N'Hội thoại trình độ N5-N4', 2),
    (3, 1, N'VOCAB_N3', N'Từ vựng trung cấp', 3),
    (4, 1, N'GRAMMAR_N3', N'Ngữ pháp trung cấp', 4),
    (5, 1, N'KANJI_N3', N'Kanji trung cấp', 5);

    INSERT INTO dbo.DemoJLPT_Lessons (LessonId, TopicId, LessonCode, LessonName, Description, SortOrder)
    VALUES
    (1, 1, N'N3_READING_1', N'Đọc đoạn văn ngắn', N'Đọc một đoạn văn ngắn trình độ N5-N4 và trả lời 3 câu hỏi trắc nghiệm.', 1),
    (2, 1, N'N3_READING_2', N'Đọc email đơn giản', N'Đọc một email ngắn trình độ N5-N4 và trả lời 3 câu hỏi trắc nghiệm.', 2),
    (3, 2, N'N3_DIALOGUE_1', N'Hội thoại tại nhà hàng', N'Đọc hội thoại ngắn tại nhà hàng và trả lời 3 câu hỏi trắc nghiệm.', 1),
    (4, 2, N'N3_DIALOGUE_2', N'Hội thoại nơi công sở', N'Đọc hội thoại ngắn nơi công sở và trả lời 3 câu hỏi trắc nghiệm.', 2),
    (5, 3, N'N3_VOCAB_1', N'Chủ đề công việc và văn phòng', N'Từ vựng N3 chủ đề công việc và văn phòng với 5 câu trắc nghiệm.', 1),
    (6, 4, N'N3_GRAMMAR_1', N'Mẫu câu 〜ようにする', N'Ngữ pháp N3: mẫu câu diễn tả cố gắng hình thành thói quen hoặc nỗ lực thực hiện điều gì, gồm 5 câu trắc nghiệm.', 1),
    (7, 5, N'N3_KANJI_1', N'Kanji 意', N'Kanji N3: 意 với 5 câu trắc nghiệm.', 1),
    (8, 5, N'N3_KANJI_2', N'Kanji 味', N'Kanji N3: 味 với 5 câu trắc nghiệm.', 2),
    (9, 5, N'N3_KANJI_3', N'Kanji 経', N'Kanji N3: 経 với 5 câu trắc nghiệm.', 3),
    (10, 5, N'N3_KANJI_4', N'Kanji 予', N'Kanji N3: 予 với 5 câu trắc nghiệm.', 4),
    (11, 5, N'N3_KANJI_5', N'Kanji 定', N'Kanji N3: 定 với 5 câu trắc nghiệm.', 5);

    INSERT INTO dbo.DemoJLPT_Questions (QuestionId, LessonId, QuestionText, QuestionType, Explanation, SortOrder)
    VALUES
    (1, 1, N'Đọc đoạn văn sau và trả lời câu hỏi.

Maiさんは毎朝6時に起きて、7時のバスで会社へ行きます。会社では日本語でメールを書いたり、資料を作ったりします。昼休みには同僚と食堂でご飯を食べます。最近、仕事が忙しいので、夜は早く帰って寝るようにしています。

Maiさんは会社で何をしますか?', N'MCQ', N'Trong đoạn văn nói Mai viết email và làm tài liệu ở công ty.', 1),
    (2, 1, N'Đọc đoạn văn sau và trả lời câu hỏi.

Maiさんは毎朝6時に起きて、7時のバスで会社へ行きます。会社では日本語でメールを書いたり、資料を作ったりします。昼休みには同僚と食堂でご飯を食べます。最近、仕事が忙しいので、夜は早く帰って寝るようにしています。

昼休みに、Maiさんはたいてい何をしますか?', N'MCQ', N'Mai thường ăn cơm với đồng nghiệp vào giờ nghỉ trưa.', 2),
    (3, 1, N'Đọc đoạn văn sau và trả lời câu hỏi.

Maiさんは毎朝6時に起きて、7時のバスで会社へ行きます。会社では日本語でメールを書いたり、資料を作ったりします。昼休みには同僚と食堂でご飯を食べます。最近、仕事が忙しいので、夜は早く帰って寝るようにしています。

最近、Maiさんはなぜ夜早く寝るようにしていますか?', N'MCQ', N'Lý do là công việc gần đây bận.', 3),
    (4, 2, N'Đọc email sau và trả lời câu hỏi.

件名：明日の会議について

田中さん

お疲れさまです。明日の会議は午前10時から3階の会議室で行います。新しい商品の説明資料を使いますので、会議の前に目を通しておいてください。もし来られない場合は、今日の午後5時までに私に連絡してください。

山本

会議はいつありますか?', N'MCQ', N'Email ghi rõ cuộc họp diễn ra lúc 10 giờ sáng ngày mai.', 1),
    (5, 2, N'Đọc email sau và trả lời câu hỏi.

件名：明日の会議について

田中さん

お疲れさまです。明日の会議は午前10時から3階の会議室で行います。新しい商品の説明資料を使いますので、会議の前に目を通しておいてください。もし来られない場合は、今日の午後5時までに私に連絡してください。

山本

田中さんは会議の前に何をしなければなりませんか?', N'MCQ', N'Tanaka cần xem qua tài liệu giải thích sản phẩm mới trước cuộc họp.', 2),
    (6, 2, N'Đọc email sau và trả lời câu hỏi.

件名：明日の会議について

田中さん

お疲れさまです。明日の会議は午前10時から3階の会議室で行います。新しい商品の説明資料を使いますので、会議の前に目を通しておいてください。もし来られない場合は、今日の午後5時までに私に連絡してください。

山本

もし会議に出られない場合、どうしますか?', N'MCQ', N'Nếu không thể đến họp thì phải liên lạc trước 5 giờ chiều hôm nay.', 3),
    (7, 3, N'Đọc hội thoại sau và trả lời câu hỏi.

店員：いらっしゃいませ。何名様ですか。
客：2人です。
店員：こちらの席へどうぞ。ご注文はお決まりですか。
客：私はみそラーメン、友だちはチャーハンをお願いします。それと、水を2つください。
店員：かしこまりました。

客は何人ですか?', N'MCQ', N'Khách nói rõ là 2 người.', 1),
    (8, 3, N'Đọc hội thoại sau và trả lời câu hỏi.

店員：いらっしゃいませ。何名様ですか。
客：2人です。
店員：こちらの席へどうぞ。ご注文はお決まりですか。
客：私はみそラーメン、友だちはチャーハンをお願いします。それと、水を2つください。
店員：かしこまりました。

客は何を注文しましたか?', N'MCQ', N'Một người gọi mì miso ramen, bạn gọi cơm rang, và xin 2 ly nước.', 2),
    (9, 3, N'Đọc hội thoại sau và trả lời câu hỏi.

店員：いらっしゃいませ。何名様ですか。
客：2人です。
店員：こちらの席へどうぞ。ご注文はお決まりですか。
客：私はみそラーメン、友だちはチャーハンをお願いします。それと、水を2つください。
店員：かしこまりました。

店員は最初に何を聞きましたか?', N'MCQ', N'Nhân viên hỏi trước tiên là có mấy người.', 3),
    (10, 4, N'Đọc hội thoại sau và trả lời câu hỏi.

山田：すみません、この書類はもう確認しましたか。
佐藤：はい、さっき確認しました。でも、1ページ目の日付が違っていました。
山田：本当ですか。では、すぐに直してから部長に送ります。
佐藤：お願いします。部長は午後2時の会議で使うそうです。

書類のどこに問題がありましたか?', N'MCQ', N'Vấn đề nằm ở ngày tháng trên trang đầu tiên.', 1),
    (11, 4, N'Đọc hội thoại sau và trả lời câu hỏi.

山田：すみません、この書類はもう確認しましたか。
佐藤：はい、さっき確認しました。でも、1ページ目の日付が違っていました。
山田：本当ですか。では、すぐに直してから部長に送ります。
佐藤：お願いします。部長は午後2時の会議で使うそうです。

山田さんは次に何をしますか?', N'MCQ', N'Yamada sẽ sửa lại rồi gửi cho trưởng phòng.', 2),
    (12, 4, N'Đọc hội thoại sau và trả lời câu hỏi.

山田：すみません、この書類はもう確認しましたか。
佐藤：はい、さっき確認しました。でも、1ページ目の日付が違っていました。
山田：本当ですか。では、すぐに直してから部長に送ります。
佐藤：お願いします。部長は午後2時の会議で使うそうです。

部長はその書類を何のために使いますか?', N'MCQ', N'Trưởng phòng sẽ dùng trong cuộc họp lúc 2 giờ chiều.', 3),
    (13, 5, N'Từ "会議" có nghĩa là gì?', N'MCQ', N'会議 nghĩa là cuộc họp.', 1),
    (14, 5, N'Chọn từ tiếng Nhật đúng với nghĩa "tài liệu / tư liệu".', N'MCQ', N'資料 nghĩa là tài liệu / tư liệu.', 2),
    (15, 5, N'Từ "連絡" có nghĩa là gì?', N'MCQ', N'連絡 nghĩa là liên lạc / thông báo.', 3),
    (16, 5, N'Chọn từ tiếng Nhật đúng với nghĩa "ý kiến".', N'MCQ', N'意見 nghĩa là ý kiến.', 4),
    (17, 5, N'Từ "予定" có nghĩa là gì?', N'MCQ', N'予定 nghĩa là dự định / kế hoạch / lịch dự kiến.', 5),
    (18, 6, N'Chọn câu đúng với mẫu ngữ pháp "〜ようにする" mang nghĩa cố gắng tạo thói quen.

___', N'MCQ', N'〜ようにする dùng để diễn tả cố gắng làm sao đó thành thói quen.', 1),
    (19, 6, N'Câu "夜はコーヒーを飲まないようにしています" có nghĩa gần đúng là gì?', N'MCQ', N'Câu này nghĩa là tôi cố gắng không uống cà phê vào buổi tối.', 2),
    (20, 6, N'Điền vào chỗ trống: 健康のために、毎朝歩く___。', N'MCQ', N'Đúng là 歩くようにしています。', 3),
    (21, 6, N'Mẫu "〜ようにする" phù hợp nhất trong câu nào sau đây?', N'MCQ', N'Mẫu này hợp khi nói về nỗ lực duy trì hành vi / thói quen.', 4),
    (22, 6, N'Chọn cách dịch đúng cho câu: 忘れないように、メモします。', N'MCQ', N'Câu này nghĩa là tôi ghi chú để khỏi quên.', 5),
    (23, 7, N'Kanji "意" trong từ "意見" thường liên quan đến nghĩa nào?', N'MCQ', N'意 thường liên quan đến ý nghĩ, ý định, ý kiến.', 1),
    (24, 7, N'Cách đọc đúng của "意見" là gì?', N'MCQ', N'意見 đọc là いけん.', 2),
    (25, 7, N'Chọn từ có chứa kanji "意".', N'MCQ', N'意見 là từ chứa kanji 意.', 3),
    (26, 7, N'Kanji nào còn thiếu trong từ sau: ___見', N'MCQ', N'Từ đúng là 意見.', 4),
    (27, 7, N'Câu nào dùng đúng từ "意見"?', N'MCQ', N'意見 nghĩa là ý kiến.', 5),
    (28, 8, N'Kanji "味" trong từ "意味" có mặt trong đáp án nào?', N'MCQ', N'意味 là từ có chứa kanji 味.', 1),
    (29, 8, N'Cách đọc đúng của "意味" là gì?', N'MCQ', N'意味 đọc là いみ.', 2),
    (30, 8, N'Từ "意味" có nghĩa là gì?', N'MCQ', N'意味 nghĩa là ý nghĩa.', 3),
    (31, 8, N'Kanji nào còn thiếu trong từ sau: 意___', N'MCQ', N'Từ đúng là 意味.', 4),
    (32, 8, N'Chọn câu dùng đúng từ "意味".', N'MCQ', N'Câu hỏi về nghĩa của từ dùng 意味.', 5),
    (33, 9, N'Kanji "経" xuất hiện trong từ nào?', N'MCQ', N'経験 là từ có chứa kanji 経.', 1),
    (34, 9, N'Cách đọc đúng của "経験" là gì?', N'MCQ', N'経験 đọc là けいけん.', 2),
    (35, 9, N'Từ "経験" có nghĩa là gì?', N'MCQ', N'経験 nghĩa là kinh nghiệm.', 3),
    (36, 9, N'Kanji nào còn thiếu trong từ sau: ___験', N'MCQ', N'Từ đúng là 経験.', 4),
    (37, 9, N'Chọn câu dùng đúng từ "経験".', N'MCQ', N'Dùng 経験 khi nói về kinh nghiệm đã có.', 5),
    (38, 10, N'Kanji "予" xuất hiện trong từ nào?', N'MCQ', N'予定 là từ có chứa kanji 予.', 1),
    (39, 10, N'Cách đọc đúng của "予定" là gì?', N'MCQ', N'予定 đọc là よてい.', 2),
    (40, 10, N'Từ "予定" có nghĩa là gì?', N'MCQ', N'予定 nghĩa là dự định / lịch dự kiến.', 3),
    (41, 10, N'Kanji nào còn thiếu trong từ sau: ___定', N'MCQ', N'Từ đúng là 予定.', 4),
    (42, 10, N'Chọn câu dùng đúng từ "予定".', N'MCQ', N'予定 dùng để nói kế hoạch hay lịch dự kiến.', 5),
    (43, 11, N'Kanji "定" xuất hiện trong từ nào sau đây?', N'MCQ', N'予定 có chứa kanji 定.', 1),
    (44, 11, N'Cách đọc đúng của chữ "定" trong từ "予定" là gì?', N'MCQ', N'Trong 予定, 定 đọc là てい.', 2),
    (45, 11, N'Chọn từ có liên quan đến nghĩa "quyết định / xác định / thiết lập".', N'MCQ', N'定 thường mang sắc thái xác định, quyết định, cố định.', 3),
    (46, 11, N'Kanji nào còn thiếu trong từ sau: 予___', N'MCQ', N'Từ đúng là 予定.', 4),
    (47, 11, N'Câu nào dùng từ có chữ "定" đúng?', N'MCQ', N'予定 là từ đúng và tự nhiên trong ngữ cảnh lịch trình.', 5);

    INSERT INTO dbo.DemoJLPT_QuestionOptions (OptionId, QuestionId, OptionLabel, OptionText, IsCorrect, SortOrder)
    VALUES
    (1, 1, N'A', N'Lái xe đến công ty', 0, 1),
    (2, 1, N'B', N'Viết email và làm tài liệu', 1, 2),
    (3, 1, N'C', N'Dạy tiếng Nhật', 0, 3),
    (4, 1, N'D', N'Bán đồ ăn ở căn tin', 0, 4),
    (5, 2, N'A', N'Đi mua sắm một mình', 0, 1),
    (6, 2, N'B', N'Ngủ ở văn phòng', 0, 2),
    (7, 2, N'C', N'Ăn trưa với đồng nghiệp', 1, 3),
    (8, 2, N'D', N'Về nhà ăn cơm', 0, 4),
    (9, 3, N'A', N'Vì muốn dậy tập thể dục', 0, 1),
    (10, 3, N'B', N'Vì công việc gần đây bận', 1, 2),
    (11, 3, N'C', N'Vì xe buýt tối nghỉ sớm', 0, 3),
    (12, 3, N'D', N'Vì không thích xem TV', 0, 4),
    (13, 4, N'A', N'Hôm nay lúc 5 giờ chiều', 0, 1),
    (14, 4, N'B', N'Ngày mai lúc 10 giờ sáng', 1, 2),
    (15, 4, N'C', N'Ngày mai lúc 3 giờ chiều', 0, 3),
    (16, 4, N'D', N'Tuần sau lúc 10 giờ sáng', 0, 4),
    (17, 5, N'A', N'Gọi cho khách hàng', 0, 1),
    (18, 5, N'B', N'Chuẩn bị cà phê cho mọi người', 0, 2),
    (19, 5, N'C', N'Xem trước tài liệu giải thích sản phẩm mới', 1, 3),
    (20, 5, N'D', N'Dọn dẹp phòng họp', 0, 4),
    (21, 6, N'A', N'Không cần làm gì cả', 0, 1),
    (22, 6, N'B', N'Gửi tài liệu cho 山本', 0, 2),
    (23, 6, N'C', N'Liên lạc với 山本 trước 5 giờ chiều hôm nay', 1, 3),
    (24, 6, N'D', N'Đến thẳng phòng họp vào ngày mai', 0, 4),
    (25, 7, N'A', N'1 người', 0, 1),
    (26, 7, N'B', N'2 người', 1, 2),
    (27, 7, N'C', N'3 người', 0, 3),
    (28, 7, N'D', N'4 người', 0, 4),
    (29, 8, N'A', N'Hai bát ramen giống nhau', 0, 1),
    (30, 8, N'B', N'Mì udon và cơm cà ri', 0, 2),
    (31, 8, N'C', N'Mì miso ramen, cơm rang và 2 ly nước', 1, 3),
    (32, 8, N'D', N'Chỉ gọi nước', 0, 4),
    (33, 9, N'A', N'Muốn ngồi gần cửa sổ không', 0, 1),
    (34, 9, N'B', N'Đã quyết định gọi món chưa', 0, 2),
    (35, 9, N'C', N'Có mấy người', 1, 3),
    (36, 9, N'D', N'Thanh toán bằng tiền mặt hay thẻ', 0, 4),
    (37, 10, N'A', N'Thiếu chữ ký ở trang cuối', 0, 1),
    (38, 10, N'B', N'Sai ngày tháng ở trang đầu', 1, 2),
    (39, 10, N'C', N'Không có tiêu đề', 0, 3),
    (40, 10, N'D', N'Bị mất trang thứ hai', 0, 4),
    (41, 11, N'A', N'In lại toàn bộ tài liệu ngày mai', 0, 1),
    (42, 11, N'B', N'Hủy cuộc họp', 0, 2),
    (43, 11, N'C', N'Sửa tài liệu rồi gửi cho trưởng phòng', 1, 3),
    (44, 11, N'D', N'Mang tài liệu về nhà', 0, 4),
    (45, 12, N'A', N'Để nộp cho khách hàng vào sáng mai', 0, 1),
    (46, 12, N'B', N'Để dùng trong cuộc họp lúc 2 giờ chiều', 1, 2),
    (47, 12, N'C', N'Để dán lên bảng thông báo', 0, 3),
    (48, 12, N'D', N'Để gửi cho nhà hàng', 0, 4),
    (49, 13, N'A', N'Cuộc họp', 1, 1),
    (50, 13, N'B', N'Kỳ nghỉ', 0, 2),
    (51, 13, N'C', N'Bản đồ', 0, 3),
    (52, 13, N'D', N'Tài khoản', 0, 4),
    (53, 14, N'A', N'予定', 0, 1),
    (54, 14, N'B', N'資料', 1, 2),
    (55, 14, N'C', N'連絡', 0, 3),
    (56, 14, N'D', N'意見', 0, 4),
    (57, 15, N'A', N'Kinh nghiệm', 0, 1),
    (58, 15, N'B', N'Liên lạc / thông báo', 1, 2),
    (59, 15, N'C', N'Lịch hẹn', 0, 3),
    (60, 15, N'D', N'Tiền lương', 0, 4),
    (61, 16, N'A', N'意見', 1, 1),
    (62, 16, N'B', N'用事', 0, 2),
    (63, 16, N'C', N'準備', 0, 3),
    (64, 16, N'D', N'都合', 0, 4),
    (65, 17, N'A', N'Cuộc thi', 0, 1),
    (66, 17, N'B', N'Dự định / kế hoạch', 1, 2),
    (67, 17, N'C', N'Bản hợp đồng', 0, 3),
    (68, 17, N'D', N'Tin nhắn', 0, 4),
    (69, 18, N'A', N'毎日、日本語を読むようにしています。', 1, 1),
    (70, 18, N'B', N'毎日、日本語を読むでしょう。', 0, 2),
    (71, 18, N'C', N'毎日、日本語を読むことがあります。', 0, 3),
    (72, 18, N'D', N'毎日、日本語を読むしかありません。', 0, 4),
    (73, 19, N'A', N'Tôi bắt buộc phải uống cà phê buổi tối', 0, 1),
    (74, 19, N'B', N'Tôi định uống cà phê vào buổi tối', 0, 2),
    (75, 19, N'C', N'Tôi cố gắng không uống cà phê vào buổi tối', 1, 3),
    (76, 19, N'D', N'Tôi vừa uống cà phê buổi tối xong', 0, 4),
    (77, 20, N'A', N'ことにしました', 0, 1),
    (78, 20, N'B', N'ようにしています', 1, 2),
    (79, 20, N'C', N'たいです', 0, 3),
    (80, 20, N'D', N'はずです', 0, 4),
    (81, 21, N'A', N'毎日早く寝るようにしています。', 1, 1),
    (82, 21, N'B', N'昨日早く寝るようにしました。', 0, 2),
    (83, 21, N'C', N'早く寝たことがあります。', 0, 3),
    (84, 21, N'D', N'早く寝たいですか。', 0, 4),
    (85, 22, N'A', N'Tôi ghi chú vì đã quên rồi', 0, 1),
    (86, 22, N'B', N'Tôi ghi chú để không quên', 1, 2),
    (87, 22, N'C', N'Tôi không thích ghi chú', 0, 3),
    (88, 22, N'D', N'Tôi muốn ai đó ghi chú giúp', 0, 4),
    (89, 23, N'A', N'Ý nghĩ / ý kiến', 1, 1),
    (90, 23, N'B', N'Màu sắc', 0, 2),
    (91, 23, N'C', N'Thời tiết', 0, 3),
    (92, 23, N'D', N'Phương hướng', 0, 4),
    (93, 24, N'A', N'いけん', 1, 1),
    (94, 24, N'B', N'いみ', 0, 2),
    (95, 24, N'C', N'けいけん', 0, 3),
    (96, 24, N'D', N'よてい', 0, 4),
    (97, 25, N'A', N'予定', 0, 1),
    (98, 25, N'B', N'意味', 0, 2),
    (99, 25, N'C', N'意見', 1, 3),
    (100, 25, N'D', N'経験', 0, 4),
    (101, 26, N'A', N'予', 0, 1),
    (102, 26, N'B', N'経', 0, 2),
    (103, 26, N'C', N'味', 0, 3),
    (104, 26, N'D', N'意', 1, 4),
    (105, 27, N'A', N'会議で自分の意見を言いました。', 1, 1),
    (106, 27, N'B', N'意見を食べました。', 0, 2),
    (107, 27, N'C', N'駅まで意見で行きました。', 0, 3),
    (108, 27, N'D', N'意見はおいしいです。', 0, 4),
    (109, 28, N'A', N'意味', 1, 1),
    (110, 28, N'B', N'予定', 0, 2),
    (111, 28, N'C', N'経験', 0, 3),
    (112, 28, N'D', N'定食', 0, 4),
    (113, 29, N'A', N'いけん', 0, 1),
    (114, 29, N'B', N'いみ', 1, 2),
    (115, 29, N'C', N'よてい', 0, 3),
    (116, 29, N'D', N'けいみ', 0, 4),
    (117, 30, N'A', N'Mùi vị', 0, 1),
    (118, 30, N'B', N'Kế hoạch', 0, 2),
    (119, 30, N'C', N'Ý nghĩa', 1, 3),
    (120, 30, N'D', N'Cuộc họp', 0, 4),
    (121, 31, N'A', N'経', 0, 1),
    (122, 31, N'B', N'味', 1, 2),
    (123, 31, N'C', N'定', 0, 3),
    (124, 31, N'D', N'予', 0, 4),
    (125, 32, N'A', N'この言葉の意味がわかりません。', 1, 1),
    (126, 32, N'B', N'意味で昼ご飯を食べます。', 0, 2),
    (127, 32, N'C', N'駅の意味へ行きます。', 0, 3),
    (128, 32, N'D', N'意味を予約しました。', 0, 4),
    (129, 33, N'A', N'意見', 0, 1),
    (130, 33, N'B', N'予定', 0, 2),
    (131, 33, N'C', N'経験', 1, 3),
    (132, 33, N'D', N'意味', 0, 4),
    (133, 34, N'A', N'けいけん', 1, 1),
    (134, 34, N'B', N'きょうけん', 0, 2),
    (135, 34, N'C', N'けんけい', 0, 3),
    (136, 34, N'D', N'いけん', 0, 4),
    (137, 35, N'A', N'Lời hứa', 0, 1),
    (138, 35, N'B', N'Kinh nghiệm', 1, 2),
    (139, 35, N'C', N'Lịch trình', 0, 3),
    (140, 35, N'D', N'Ý nghĩa', 0, 4),
    (141, 36, N'A', N'定', 0, 1),
    (142, 36, N'B', N'味', 0, 2),
    (143, 36, N'C', N'経', 1, 3),
    (144, 36, N'D', N'予', 0, 4),
    (145, 37, N'A', N'日本で働いた経験があります。', 1, 1),
    (146, 37, N'B', N'経験を食べました。', 0, 2),
    (147, 37, N'C', N'経験は青いです。', 0, 3),
    (148, 37, N'D', N'経験で寝ます。', 0, 4),
    (149, 38, N'A', N'意味', 0, 1),
    (150, 38, N'B', N'予定', 1, 2),
    (151, 38, N'C', N'経験', 0, 3),
    (152, 38, N'D', N'意見', 0, 4),
    (153, 39, N'A', N'よてい', 1, 1),
    (154, 39, N'B', N'よみ', 0, 2),
    (155, 39, N'C', N'いけん', 0, 3),
    (156, 39, N'D', N'けいてい', 0, 4),
    (157, 40, N'A', N'Kinh nghiệm', 0, 1),
    (158, 40, N'B', N'Dự định / lịch dự kiến', 1, 2),
    (159, 40, N'C', N'Ý kiến', 0, 3),
    (160, 40, N'D', N'Mùi vị', 0, 4),
    (161, 41, N'A', N'予', 1, 1),
    (162, 41, N'B', N'意', 0, 2),
    (163, 41, N'C', N'味', 0, 3),
    (164, 41, N'D', N'経', 0, 4),
    (165, 42, N'A', N'明日の予定を教えてください。', 1, 1),
    (166, 42, N'B', N'予定を飲みました。', 0, 2),
    (167, 42, N'C', N'予定は高いです。', 0, 3),
    (168, 42, N'D', N'予定で走りました。', 0, 4),
    (169, 43, N'A', N'意見', 0, 1),
    (170, 43, N'B', N'予定', 1, 2),
    (171, 43, N'C', N'経験', 0, 3),
    (172, 43, N'D', N'意味', 0, 4),
    (173, 44, N'A', N'てい', 1, 1),
    (174, 44, N'B', N'み', 0, 2),
    (175, 44, N'C', N'けん', 0, 3),
    (176, 44, N'D', N'よ', 0, 4),
    (177, 45, N'A', N'定', 1, 1),
    (178, 45, N'B', N'味', 0, 2),
    (179, 45, N'C', N'意', 0, 3),
    (180, 45, N'D', N'駅', 0, 4),
    (181, 46, N'A', N'経', 0, 1),
    (182, 46, N'B', N'味', 0, 2),
    (183, 46, N'C', N'定', 1, 3),
    (184, 46, N'D', N'意', 0, 4),
    (185, 47, N'A', N'午後の予定はまだ決まっていません。', 1, 1),
    (186, 47, N'B', N'定を三つ食べました。', 0, 2),
    (187, 47, N'C', N'私は毎日定へ行きます。', 0, 3),
    (188, 47, N'D', N'定は日本語の先生です。', 0, 4);

    -------------------------------------------------------------------------
    -- Map DEMO data into current project schema (EF-compatible)
    -- Keeps ALL question/option text exactly as seeded above (Unicode via N'...')
    -------------------------------------------------------------------------

    PRINT N'--- Mapping DemoJLPT_* (N3) -> current schema tables ---';

    -- 1) Ensure Level N3 exists
    IF NOT EXISTS (SELECT 1 FROM dbo.[Level] WHERE LevelName = N'N3')
    BEGIN
        INSERT INTO dbo.[Level] (LevelName) VALUES (N'N3');
    END

    DECLARE @LevelN3_Id INT = (SELECT TOP 1 LevelId FROM dbo.[Level] WHERE LevelName = N'N3');

    -- 2) Upsert Topics (by name within level)
    MERGE dbo.[Topic] AS tgt
    USING (
        SELECT DISTINCT TopicName
        FROM dbo.DemoJLPT_Topics
    ) AS src
    ON tgt.LevelId = @LevelN3_Id AND tgt.TopicName = src.TopicName
    WHEN NOT MATCHED THEN
        INSERT (TopicName, LevelId) VALUES (src.TopicName, @LevelN3_Id);

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
        INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN3_Id AND t.TopicName = d.TopicName
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
        INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN3_Id AND t.TopicName = dt.TopicName
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
            INNER JOIN dbo.[Topic] t ON t.LevelId = @LevelN3_Id AND t.TopicName = dt.TopicName
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
        (SELECT COUNT(*) FROM dbo.[Topic] WHERE LevelId = @LevelN3_Id) AS TopicCount_CurrentSchema_N3,
        (SELECT COUNT(*) FROM dbo.Lessons l INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN3_Id) AS LessonCount_CurrentSchema_N3,
        (SELECT COUNT(*) FROM dbo.Questions q INNER JOIN dbo.Lessons l ON l.LessonId = q.LessonId INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN3_Id) AS QuestionCount_CurrentSchema_N3,
        (SELECT COUNT(*) FROM dbo.QuestionOptions o INNER JOIN dbo.Questions q ON q.QuestionId = o.QuestionId INNER JOIN dbo.Lessons l ON l.LessonId = q.LessonId INNER JOIN dbo.[Topic] t ON t.TopicId = l.TopicId WHERE t.LevelId = @LevelN3_Id) AS OptionCount_CurrentSchema_N3;

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
