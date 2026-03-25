-- ============================================
-- Seed Level / Topic / Lessons / Questions / Options
-- Matches EF models: Lesson (TopicId, LessonName), Question (Content, OrderIndex)
-- ============================================
USE DuolingoJP;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    -- 1) Seed Levels
    IF NOT EXISTS (SELECT 1 FROM [Level] WHERE LevelName = N'N5')
    BEGIN
        INSERT INTO [Level] (LevelName) VALUES (N'N5'), (N'N4'), (N'N3'), (N'N2'), (N'N1');
    END

    -- 2) Seed Topics
    DECLARE @LevelN5 INT = (SELECT LevelId FROM [Level] WHERE LevelName = N'N5');
    
    IF NOT EXISTS (SELECT 1 FROM [Topic] WHERE TopicName = N'Hiragana & Katakana')
    BEGIN
        INSERT INTO [Topic] (TopicName, LevelId) VALUES
        (N'Hiragana & Katakana', @LevelN5),
        (N'Từ vựng cơ bản', @LevelN5),
        (N'Ngữ pháp cơ bản', @LevelN5);
    END

    -- 3) Seed Lessons
    DECLARE @TopicHiragana INT = (SELECT TopicId FROM [Topic] WHERE TopicName = N'Hiragana & Katakana');
    DECLARE @TopicVocab INT = (SELECT TopicId FROM [Topic] WHERE TopicName = N'Từ vựng cơ bản');
    DECLARE @TopicGrammar INT = (SELECT TopicId FROM [Topic] WHERE TopicName = N'Ngữ pháp cơ bản');

    IF NOT EXISTS (SELECT 1 FROM Lessons)
    BEGIN
        INSERT INTO Lessons (LessonName, TopicId, BaseXP) VALUES
        -- Hiragana & Katakana
        (N'Hiragana cơ bản', @TopicHiragana, 10),
        (N'Katakana cơ bản', @TopicHiragana, 10),
        (N'Luyện đọc bảng chữ cái', @TopicHiragana, 12),
        
        -- Từ vựng cơ bản
        (N'Từ vựng gia đình', @TopicVocab, 12),
        (N'Từ vựng trường học', @TopicVocab, 12),
        (N'Từ vựng số đếm', @TopicVocab, 12),
        
        -- Ngữ pháp cơ bản
        (N'Cấu trúc AはBです', @TopicGrammar, 15),
        (N'Trợ từ は và が', @TopicGrammar, 15),
        (N'Thì hiện tại và phủ định', @TopicGrammar, 15);
    END

    -- 4) Seed Questions for Lesson 1: Hiragana cơ bản
    DECLARE @Lesson1 INT = (SELECT LessonId FROM Lessons WHERE LessonName = N'Hiragana cơ bản');

    IF @Lesson1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Questions WHERE LessonId = @Lesson1)
    BEGIN
        INSERT INTO Questions (LessonId, Content, OrderIndex) VALUES
        (@Lesson1, N'Chữ あ đọc là gì?', 1),
        (@Lesson1, N'Chữ い đọc là gì?', 2),
        (@Lesson1, N'Chữ う đọc là gì?', 3),
        (@Lesson1, N'Chữ え đọc là gì?', 4),
        (@Lesson1, N'Chữ お đọc là gì?', 5),
        (@Lesson1, N'Trong bảng Hiragana, あ thuộc hàng nào?', 6),
        (@Lesson1, N'あ, い, う, え, お thuộc bảng chữ nào?', 7),
        (@Lesson1, N'Phát âm đúng của う là gì?', 8),
        (@Lesson1, N'Thứ tự đúng của hàng A là gì?', 9),
        (@Lesson1, N'Chữ い và え khác nhau ở điểm nào?', 10);

        -- Get QuestionIds
        DECLARE @Q1 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 1);
        DECLARE @Q2 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 2);
        DECLARE @Q3 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 3);
        DECLARE @Q4 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 4);
        DECLARE @Q5 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 5);
        DECLARE @Q6 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 6);
        DECLARE @Q7 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 7);
        DECLARE @Q8 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 8);
        DECLARE @Q9 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 9);
        DECLARE @Q10 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson1 AND OrderIndex = 10);

        -- Insert Options for Q1: あ
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q1, N'a', 1),
        (@Q1, N'i', 0),
        (@Q1, N'u', 0),
        (@Q1, N'e', 0);

        -- Insert Options for Q2: い
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q2, N'a', 0),
        (@Q2, N'i', 1),
        (@Q2, N'u', 0),
        (@Q2, N'o', 0);

        -- Insert Options for Q3: う
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q3, N'a', 0),
        (@Q3, N'i', 0),
        (@Q3, N'u', 1),
        (@Q3, N'e', 0);

        -- Insert Options for Q4: え
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q4, N'o', 0),
        (@Q4, N'e', 1),
        (@Q4, N'u', 0),
        (@Q4, N'i', 0);

        -- Insert Options for Q5: お
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q5, N'o', 1),
        (@Q5, N'e', 0),
        (@Q5, N'a', 0),
        (@Q5, N'i', 0);

        -- Insert Options for Q6: hàng A
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q6, N'Hàng A', 1),
        (@Q6, N'Hàng KA', 0),
        (@Q6, N'Hàng SA', 0),
        (@Q6, N'Hàng TA', 0);

        -- Insert Options for Q7: bảng chữ
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q7, N'Hiragana', 1),
        (@Q7, N'Katakana', 0),
        (@Q7, N'Kanji', 0),
        (@Q7, N'Romaji', 0);

        -- Insert Options for Q8: phát âm う
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q8, N'u (giống âm u trong tiếng Việt)', 1),
        (@Q8, N'o', 0),
        (@Q8, N'i', 0),
        (@Q8, N'e', 0);

        -- Insert Options for Q9: thứ tự hàng A
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q9, N'あ い う え お', 1),
        (@Q9, N'あ う い え お', 0),
        (@Q9, N'い あ う え お', 0),
        (@Q9, N'あ い え う お', 0);

        -- Insert Options for Q10: khác nhau
        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q10, N'Số nét viết', 1),
        (@Q10, N'Không khác gì', 0),
        (@Q10, N'Cách phát âm giống nhau', 0),
        (@Q10, N'Cùng nghĩa', 0);
    END

    -- 5) Seed Questions for Lesson 2: Katakana
    DECLARE @Lesson2 INT = (SELECT LessonId FROM Lessons WHERE LessonName = N'Katakana cơ bản');

    IF @Lesson2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Questions WHERE LessonId = @Lesson2)
    BEGIN
        INSERT INTO Questions (LessonId, Content, OrderIndex) VALUES
        (@Lesson2, N'Chữ カ đọc là gì?', 1),
        (@Lesson2, N'Chữ キ đọc là gì?', 2),
        (@Lesson2, N'Chữ ク đọc là gì?', 3),
        (@Lesson2, N'Chữ ケ đọc là gì?', 4),
        (@Lesson2, N'Chữ コ đọc là gì?', 5);

        DECLARE @Q11 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson2 AND OrderIndex = 1);
        DECLARE @Q12 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson2 AND OrderIndex = 2);
        DECLARE @Q13 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson2 AND OrderIndex = 3);
        DECLARE @Q14 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson2 AND OrderIndex = 4);
        DECLARE @Q15 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson2 AND OrderIndex = 5);

        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q11, 'ka', 1), (@Q11, 'ki', 0), (@Q11, 'ku', 0), (@Q11, 'ko', 0),
        (@Q12, 'ka', 0), (@Q12, 'ki', 1), (@Q12, 'ke', 0), (@Q12, 'ko', 0),
        (@Q13, 'ku', 1), (@Q13, 'ka', 0), (@Q13, 'ki', 0), (@Q13, 'ke', 0),
        (@Q14, 'ke', 1), (@Q14, 'ko', 0), (@Q14, 'ka', 0), (@Q14, 'ku', 0),
        (@Q15, 'ko', 1), (@Q15, 'ke', 0), (@Q15, 'ki', 0), (@Q15, 'ka', 0);
    END

    -- 6) Seed Questions for Lesson 3: Luyện đọc
    DECLARE @Lesson3 INT = (SELECT LessonId FROM Lessons WHERE LessonName = N'Luyện đọc bảng chữ cái');

    IF @Lesson3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Questions WHERE LessonId = @Lesson3)
    BEGIN
        INSERT INTO Questions (LessonId, Content, OrderIndex) VALUES
        (@Lesson3, N'Chữ さ đọc là gì?', 1),
        (@Lesson3, N'Chữ し đọc là gì?', 2),
        (@Lesson3, N'Chữ す đọc là gì?', 3);

        DECLARE @Q16 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson3 AND OrderIndex = 1);
        DECLARE @Q17 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson3 AND OrderIndex = 2);
        DECLARE @Q18 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson3 AND OrderIndex = 3);

        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q16, 'sa', 1), (@Q16, 'shi', 0), (@Q16, 'su', 0), (@Q16, 'se', 0),
        (@Q17, 'sa', 0), (@Q17, 'shi', 1), (@Q17, 'su', 0), (@Q17, 'so', 0),
        (@Q18, 'su', 1), (@Q18, 'shi', 0), (@Q18, 'sa', 0), (@Q18, 'se', 0);
    END

    -- 7) Seed Questions for Lesson 4: Từ vựng gia đình
    DECLARE @Lesson4 INT = (SELECT LessonId FROM Lessons WHERE LessonName = N'Từ vựng gia đình');

    IF @Lesson4 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Questions WHERE LessonId = @Lesson4)
    BEGIN
        INSERT INTO Questions (LessonId, Content, OrderIndex) VALUES
        (@Lesson4, N'お母さん nghĩa là gì?', 1),
        (@Lesson4, N'お父さん nghĩa là gì?', 2),
        (@Lesson4, N'兄 nghĩa là gì?', 3);

        DECLARE @Q19 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson4 AND OrderIndex = 1);
        DECLARE @Q20 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson4 AND OrderIndex = 2);
        DECLARE @Q21 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson4 AND OrderIndex = 3);

        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q19, N'mẹ', 1), (@Q19, N'bố', 0), (@Q19, N'anh trai', 0), (@Q19, N'chị gái', 0),
        (@Q20, N'bố', 1), (@Q20, N'mẹ', 0), (@Q20, N'em trai', 0), (@Q20, N'chị gái', 0),
        (@Q21, N'anh trai', 1), (@Q21, N'em trai', 0), (@Q21, N'bố', 0), (@Q21, N'mẹ', 0);
    END

    -- 8) Seed Questions for Lesson 5: Từ vựng trường học
    DECLARE @Lesson5 INT = (SELECT LessonId FROM Lessons WHERE LessonName = N'Từ vựng trường học');

    IF @Lesson5 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Questions WHERE LessonId = @Lesson5)
    BEGIN
        INSERT INTO Questions (LessonId, Content, OrderIndex) VALUES
        (@Lesson5, N'先生 nghĩa là gì?', 1),
        (@Lesson5, N'学生 nghĩa là gì?', 2),
        (@Lesson5, N'学校 nghĩa là gì?', 3);

        DECLARE @Q22 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson5 AND OrderIndex = 1);
        DECLARE @Q23 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson5 AND OrderIndex = 2);
        DECLARE @Q24 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson5 AND OrderIndex = 3);

        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q22, N'giáo viên', 1), (@Q22, N'học sinh', 0), (@Q22, N'trường học', 0), (@Q22, N'bạn bè', 0),
        (@Q23, N'học sinh', 1), (@Q23, N'giáo viên', 0), (@Q23, N'trường', 0), (@Q23, N'lớp học', 0),
        (@Q24, N'trường học', 1), (@Q24, N'giáo viên', 0), (@Q24, N'học sinh', 0), (@Q24, N'bàn học', 0);
    END

    -- 9) Seed Questions for Lesson 6: Từ vựng số đếm
    DECLARE @Lesson6 INT = (SELECT LessonId FROM Lessons WHERE LessonName = N'Từ vựng số đếm');

    IF @Lesson6 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Questions WHERE LessonId = @Lesson6)
    BEGIN
        INSERT INTO Questions (LessonId, Content, OrderIndex) VALUES
        (@Lesson6, N'一 nghĩa là gì?', 1),
        (@Lesson6, N'二 nghĩa là gì?', 2),
        (@Lesson6, N'三 nghĩa là gì?', 3);

        DECLARE @Q25 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson6 AND OrderIndex = 1);
        DECLARE @Q26 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson6 AND OrderIndex = 2);
        DECLARE @Q27 INT = (SELECT QuestionId FROM Questions WHERE LessonId = @Lesson6 AND OrderIndex = 3);

        INSERT INTO QuestionOptions (QuestionId, OptionText, IsCorrect) VALUES
        (@Q25, '1', 1), (@Q25, '2', 0), (@Q25, '3', 0), (@Q25, '4', 0),
        (@Q26, '2', 1), (@Q26, '1', 0), (@Q26, '3', 0), (@Q26, '5', 0),
        (@Q27, '3', 1), (@Q27, '1', 0), (@Q27, '2', 0), (@Q27, '6', 0);
    END

    COMMIT TRAN;
    
    PRINT 'Data seeded successfully!';
    
    -- Show summary
    SELECT 'Levels' AS TableName, COUNT(*) AS Count FROM [Level]
    UNION ALL SELECT 'Topics', COUNT(*) FROM [Topic]
    UNION ALL SELECT 'Lessons', COUNT(*) FROM Lessons
    UNION ALL SELECT 'Questions', COUNT(*) FROM Questions
    UNION ALL SELECT 'QuestionOptions', COUNT(*) FROM QuestionOptions;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    
    PRINT 'Error occurred:';
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;
END CATCH;
