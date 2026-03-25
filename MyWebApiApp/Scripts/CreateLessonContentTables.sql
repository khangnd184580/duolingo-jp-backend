-- ============================================
-- DEPRECATED — do not run
-- This file targeted an old schema (QuestionText, LessonAttempts with AttemptId, etc.)
-- that does not match MyWebApiApp EF models.
--
-- Use instead:
--   FixDatabaseForCurrentBackend.sql  (UserItems / shop alignment)
--   dotnet ef database update            (create or update schema from migrations)
-- ============================================
PRINT 'CreateLessonContentTables.sql is deprecated. See header comments in this file.';
