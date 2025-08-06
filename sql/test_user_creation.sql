-- Complete test script for user creation after applying the database fix
-- Run this in your Supabase SQL Editor to test the full flow

-- 1. First verify that all required columns exist
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'users'
    AND COLUMN_NAME IN ('address', 'customer_data', 'tailor_data', 'admin_data', 'full_name', 'email', 'phone')
ORDER BY
    ORDINAL_POSITION;

-- 2. Test user insertion with the correct column names
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
    'Test User Fix',
    'testfix@example.com',
    '+1234567890',
    'customer',
    '{"street": "123 Fix St", "city": "Test City", "country": "Test Country"}',
    '{"preferences": "test_preferences", "style": "modern"}',
    FALSE,
    TRUE
) ON CONFLICT (
    EMAIL
) DO UPDATE SET FULL_NAME = EXCLUDED.FULL_NAME,
PHONE = EXCLUDED.PHONE,
ADDRESS = EXCLUDED.ADDRESS,
CUSTOMER_DATA = EXCLUDED.CUSTOMER_DATA,
UPDATED_AT = NOW(
);

-- 3. Verify the insert worked and data is correctly formatted
SELECT
    ID,
    FULL_NAME,
    EMAIL,
    PHONE,
    ROLE,
    ADDRESS,
    CUSTOMER_DATA,
    EMAIL_VERIFIED,
    IS_ACTIVE,
    CREATED_AT,
    UPDATED_AT
FROM
    USERS
WHERE
    EMAIL = 'testfix@example.com';

-- 4. Test that the JSON data is valid and can be queried
SELECT
    EMAIL,
    ADDRESS->>'street' AS STREET,
    ADDRESS->>'city' AS CITY,
    CUSTOMER_DATA->>'preferences' AS PREFERENCES
FROM
    USERS
WHERE
    EMAIL = 'testfix@example.com';

-- 5. Clean up test data when done
-- Uncomment the line below to clean up the test user
-- DELETE FROM users WHERE email = 'testfix@example.com';