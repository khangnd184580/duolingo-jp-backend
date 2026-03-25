-- ============================================
-- IMPORTANT: Run this FIRST to get your UserId
-- ============================================
-- This script shows you the UserId from AspNetUsers table
-- Copy this UserId and use it in the InsertSimple.sql script

SELECT 
    Id as UserId,
    UserName,
    Email
FROM AspNetUsers;

-- If no users exist, create a test user first via:
-- POST /api/account/register in Swagger/Postman
-- OR run this SQL:

/*
-- Example: Create a test user (you need to hash the password first)
-- Easier way: Use the API /api/account/register to create user
-- Then come back and run the SELECT query above
*/

PRINT '===================================';
PRINT 'Copy the UserId from the result above';
PRINT 'Then update InsertSimpleWithUserId.sql';
PRINT '===================================';
