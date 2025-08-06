-- Verification script to check if the schema fix worked
-- Run this after applying the fix_database_schema.sql

-- 1. Check if the users table has all required columns
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'users'
    AND COLUMN_NAME IN ('address', 'customer_data', 'tailor_data', 'admin_data', 'full_name', 'email', 'phone')
ORDER BY
    ORDINAL_POSITION;

-- 2. Test inserting a sample user (this should now work without errors)
-- Note: Replace with actual user data for testing
INSERT INTO USERS (
    FULL_NAME,
    EMAIL,
    PHONE,
    ROLE,
    ADDRESS,
    CUSTOMER_DATA,
    EMAIL_VERIFIED,
    IS_ACTIVE
) VALUES (
    'Test User',
    'test@example.com',
    '+1234567890',
    'customer',
    '{"street": "123 Test St", "city": "Test City", "country": "Test Country"}',
    '{"preferences": "test"}',
    FALSE,
    TRUE
) ON CONFLICT (
    EMAIL
) DO NOTHING;

-- 3. Verify the insert worked and retrieve the user
SELECT
    ID,
    FULL_NAME,
    EMAIL,
    PHONE,
    ROLE,
    ADDRESS,
    CUSTOMER_DATA,
    CREATED_AT
FROM
    USERS
WHERE
    EMAIL = 'test@example.com';

-- 4. Clean up test data
DELETE FROM USERS
WHERE
    EMAIL = 'test@example.com';