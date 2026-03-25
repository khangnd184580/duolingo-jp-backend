-- ============================================
-- QUICK SEED SCRIPT FOR POSTGRESQL
-- Seeds: Levels, Topics, Lessons, Questions, Shop Items, Achievements
-- ============================================

DO $$
DECLARE
    level_n5_id INT;
    topic_hiragana_id INT;
    topic_vocab_id INT;
    topic_grammar_id INT;
    lesson1_id INT;
    q1_id INT;
    q2_id INT;
    q3_id INT;
BEGIN
    -- 1) SEED LEVELS
    INSERT INTO "Level" ("LevelName") VALUES
        ('N5'), ('N4'), ('N3'), ('N2'), ('N1')
    ON CONFLICT DO NOTHING;
    
    SELECT "LevelId" INTO level_n5_id FROM "Level" WHERE "LevelName" = 'N5';
    
    -- 2) SEED TOPICS
    INSERT INTO "Topic" ("TopicName", "LevelId") VALUES
        ('Hiragana & Katakana', level_n5_id),
        ('Từ vựng cơ bản', level_n5_id),
        ('Ngữ pháp cơ bản', level_n5_id)
    ON CONFLICT DO NOTHING;
    
    SELECT "TopicId" INTO topic_hiragana_id FROM "Topic" WHERE "TopicName" = 'Hiragana & Katakana';
    SELECT "TopicId" INTO topic_vocab_id FROM "Topic" WHERE "TopicName" = 'Từ vựng cơ bản';
    SELECT "TopicId" INTO topic_grammar_id FROM "Topic" WHERE "TopicName" = 'Ngữ pháp cơ bản';
    
    -- 3) SEED LESSONS
    INSERT INTO "Lessons" ("LessonName", "TopicId", "BaseXP") VALUES
        ('Hiragana cơ bản', topic_hiragana_id, 10),
        ('Katakana cơ bản', topic_hiragana_id, 10),
        ('Luyện đọc bảng chữ cái', topic_hiragana_id, 12),
        ('Từ vựng gia đình', topic_vocab_id, 12),
        ('Từ vựng trường học', topic_vocab_id, 12),
        ('Từ vựng số đếm', topic_vocab_id, 12),
        ('Cấu trúc AはBです', topic_grammar_id, 15),
        ('Trợ từ は và が', topic_grammar_id, 15),
        ('Thì hiện tại và phủ định', topic_grammar_id, 15)
    ON CONFLICT DO NOTHING;
    
    SELECT "LessonId" INTO lesson1_id FROM "Lessons" WHERE "LessonName" = 'Hiragana cơ bản';
    
    -- 4) SEED QUESTIONS FOR LESSON 1
    INSERT INTO "Questions" ("LessonId", "Content", "OrderIndex") VALUES
        (lesson1_id, 'Chữ あ đọc là gì?', 1),
        (lesson1_id, 'Chữ い đọc là gì?', 2),
        (lesson1_id, 'Chữ う đọc là gì?', 3),
        (lesson1_id, 'Chữ え đọc là gì?', 4),
        (lesson1_id, 'Chữ お đọc là gì?', 5)
    ON CONFLICT DO NOTHING;
    
    -- Get Question IDs
    SELECT "QuestionId" INTO q1_id FROM "Questions" WHERE "LessonId" = lesson1_id AND "OrderIndex" = 1;
    SELECT "QuestionId" INTO q2_id FROM "Questions" WHERE "LessonId" = lesson1_id AND "OrderIndex" = 2;
    SELECT "QuestionId" INTO q3_id FROM "Questions" WHERE "LessonId" = lesson1_id AND "OrderIndex" = 3;
    
    -- 5) SEED QUESTION OPTIONS
    INSERT INTO "QuestionOptions" ("QuestionId", "OptionText", "IsCorrect") VALUES
        -- Q1: あ
        (q1_id, 'a', true),
        (q1_id, 'i', false),
        (q1_id, 'u', false),
        (q1_id, 'e', false),
        -- Q2: い
        (q2_id, 'a', false),
        (q2_id, 'i', true),
        (q2_id, 'u', false),
        (q2_id, 'o', false),
        -- Q3: う
        (q3_id, 'a', false),
        (q3_id, 'i', false),
        (q3_id, 'u', true),
        (q3_id, 'e', false)
    ON CONFLICT DO NOTHING;
    
    -- 6) SEED SHOP ITEMS
    INSERT INTO "Items" ("Name", "Description", "Price", "Category", "ImageUrl", "IsActive") VALUES
        ('Streak Freeze', 'Bảo vệ streak 1 ngày nếu bạn quên luyện tập', 200, 'PowerUp', '/images/items/streak-freeze.png', true),
        ('Heart Refill', 'Phục hồi toàn bộ hearts ngay lập tức', 350, 'PowerUp', '/images/items/heart-refill.png', true),
        ('Double XP Boost', 'Nhận 2x XP trong 15 phút', 150, 'PowerUp', '/images/items/double-xp.png', true),
        ('Golden Owl Avatar', 'Avatar cao cấp', 500, 'Cosmetic', '/images/items/golden-owl.png', true),
        ('Cherry Blossom Theme', 'Giao diện hoa anh đào đẹp mắt', 800, 'Cosmetic', '/images/items/sakura-theme.png', true),
        ('Samurai Avatar', 'Avatar samurai truyền thống', 600, 'Cosmetic', '/images/items/samurai-avatar.png', true)
    ON CONFLICT DO NOTHING;
    
    -- 7) SEED ACHIEVEMENTS
    INSERT INTO "Achievements" ("Name", "Description", "IconUrl", "RequiredValue", "AchievementType") VALUES
        ('First Steps', 'Hoàn thành bài học đầu tiên', '/icons/first-lesson.png', 1, 'LessonsCompleted'),
        ('Scholar', 'Hoàn thành 10 bài học', '/icons/scholar.png', 10, 'LessonsCompleted'),
        ('XP Warrior', 'Đạt 100 XP', '/icons/xp-100.png', 100, 'TotalXP'),
        ('Streak Master', 'Duy trì streak 7 ngày', '/icons/streak-7.png', 7, 'Streak'),
        ('Perfect Score', 'Đạt điểm tuyệt đối trong 5 bài', '/icons/perfect-5.png', 5, 'PerfectLessons')
    ON CONFLICT DO NOTHING;
    
    -- 8) SEED DAILY TASKS
    INSERT INTO "Tasks" ("TaskName", "TaskType", "TargetValue", "RewardXP", "RewardGems", "IsDaily") VALUES
        ('Earn 20 XP', 'EarnXP', 20, 10, 5, true),
        ('Complete 1 lesson', 'CompleteLesson', 1, 15, 10, true),
        ('Practice 10 minutes', 'PracticeTime', 10, 20, 15, true)
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Database seeded successfully!';
END $$;

-- Verify data
SELECT 'Levels:' as "Table", COUNT(*) as "Count" FROM "Level"
UNION ALL
SELECT 'Topics:', COUNT(*) FROM "Topic"
UNION ALL
SELECT 'Lessons:', COUNT(*) FROM "Lessons"
UNION ALL
SELECT 'Questions:', COUNT(*) FROM "Questions"
UNION ALL
SELECT 'Question Options:', COUNT(*) FROM "QuestionOptions"
UNION ALL
SELECT 'Shop Items:', COUNT(*) FROM "Items"
UNION ALL
SELECT 'Achievements:', COUNT(*) FROM "Achievements"
UNION ALL
SELECT 'Tasks:', COUNT(*) FROM "Tasks";
