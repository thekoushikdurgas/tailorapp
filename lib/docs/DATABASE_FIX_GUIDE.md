# Database Schema Fix Guide

## Issue Description

Your TailorApp is encountering a `PostgrestException` error:

```txt
Could not find the 'address' column of 'users' in the schema cache
```

This error occurs because your Supabase database is missing the `address` column in the `users` table that your application code expects.

## Root Cause

- Your application code (UserModel, UserRepository) expects an `address` column in the `users` table
- Your current Supabase database schema doesn't have this column
- There's a mismatch between `supabase_schema.sql` (has address) and `supabase_database_schema.sql` (uses separate USER_ADDRESSES table)

## Solution Options

### Option 1: Quick Fix - Add Missing Column (Recommended)

This is the fastest solution that requires minimal code changes.

#### Step 1: Connect to your Supabase Database

1. Go to your Supabase Dashboard
2. Navigate to SQL Editor
3. Run the following SQL script:

```sql
-- Add the missing ADDRESS column to the USERS table
ALTER TABLE USERS
ADD COLUMN IF NOT EXISTS ADDRESS JSONB;

-- Also ensure all other required columns exist for compatibility
ALTER TABLE USERS
ADD COLUMN IF NOT EXISTS CUSTOMER_DATA JSONB,
ADD COLUMN IF NOT EXISTS TAILOR_DATA JSONB,
ADD COLUMN IF NOT EXISTS ADMIN_DATA JSONB;

-- Update existing rows to have empty JSON objects for the new JSONB columns
UPDATE USERS
SET
    ADDRESS = COALESCE(ADDRESS, '{}'),
    CUSTOMER_DATA = COALESCE(CUSTOMER_DATA, '{}'),
    TAILOR_DATA = COALESCE(TAILOR_DATA, '{}'),
    ADMIN_DATA = COALESCE(ADMIN_DATA, '{}')
WHERE
    ADDRESS IS NULL
    OR CUSTOMER_DATA IS NULL
    OR TAILOR_DATA IS NULL
    OR ADMIN_DATA IS NULL;
```

#### Step 2: Verify the Fix

Run the verification script to ensure everything works:

```sql
-- Check if the users table has all required columns
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'users'
AND column_name IN ('address', 'customer_data', 'tailor_data', 'admin_data', 'name', 'email', 'phone')
ORDER BY ordinal_position;
```

#### Step 3: Test Your App

1. Restart your Flutter app
2. Try the user creation flow again
3. The error should be resolved

### Option 2: Comprehensive Schema Update

If you want to use the more advanced schema with separate address tables:

1. **Backup your data first**
2. Apply the complete `supabase_database_schema.sql`
3. Update your application code to work with the new schema structure
4. This requires more development work but provides better data normalization

## Files Created for This Fix

- `fix_database_schema.sql` - The fix script to add missing columns
- `verify_schema_fix.sql` - Verification and testing script
- `DATABASE_FIX_GUIDE.md` - This comprehensive guide

## Testing

After applying the fix, test these scenarios:

1. User registration/creation
2. User profile updates
3. Address management
4. Role-based user creation (customer, tailor, admin)

## Prevention

To avoid similar issues in the future:

1. Keep your database schema files in sync
2. Use database migrations instead of multiple schema files
3. Consider using a single source of truth for your database schema
4. Test schema changes in a development environment first

## Support

If you encounter any issues with this fix:

1. Check the Supabase logs for detailed error messages
2. Verify the column was added successfully using the verification script
3. Ensure your Supabase client is using the latest schema cache

## Schema Column Details

The `address` column should be:

- **Type**: JSONB
- **Nullable**: Yes
- **Default**: NULL or '{}'
- **Purpose**: Store user address information as JSON

Example address JSON structure:

```json
{
  "street": "123 Main St",
  "city": "New York",
  "state": "NY",
  "postal_code": "10001",
  "country": "USA"
}
```

## Important Note About Column Names

After running the fix, I discovered your database uses different column names than expected:

- **Database column**: `full_name`
- **Application expects**: `name`

You may need to update your UserModel mapping in `lib/core/models/user_model.dart` to use `full_name` instead of `name` when interacting with the database.

## Additional Database Columns Found

Your users table includes these Supabase auth columns:

- `id`, `email`, `phone` (as expected)
- `full_name` (instead of `name`)
- `role` (USER-DEFINED type)
- `email_verified`, `phone_verified`
- `is_active`
- `address`, `customer_data`, `tailor_data`, `admin_data` (added by the fix)
- Plus many Supabase auth-specific columns
