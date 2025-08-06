-- Fix for the missing 'address' column in users table
-- This script adds the missing column to match the application expectations

-- Add the missing ADDRESS column to the USERS table
ALTER TABLE USERS
    ADD COLUMN IF NOT EXISTS ADDRESS JSONB;

-- Also ensure all other required columns exist for compatibility
ALTER TABLE USERS
    ADD COLUMN IF NOT EXISTS CUSTOMER_DATA JSONB, ADD COLUMN IF NOT EXISTS TAILOR_DATA JSONB, ADD COLUMN IF NOT EXISTS ADMIN_DATA JSONB;

-- Update existing rows to have empty JSON objects for the new JSONB columns
UPDATE USERS
SET
    ADDRESS = COALESCE(
        ADDRESS,
        '{}'
    ),
    CUSTOMER_DATA = COALESCE(
        CUSTOMER_DATA,
        '{}'
    ),
    TAILOR_DATA = COALESCE(
        TAILOR_DATA,
        '{}'
    ),
    ADMIN_DATA = COALESCE(
        ADMIN_DATA,
        '{}'
    )
WHERE
    ADDRESS IS NULL
    OR CUSTOMER_DATA IS NULL
    OR TAILOR_DATA IS NULL
    OR ADMIN_DATA IS NULL;

-- Verify the table structure
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'users'
ORDER BY
    ORDINAL_POSITION;