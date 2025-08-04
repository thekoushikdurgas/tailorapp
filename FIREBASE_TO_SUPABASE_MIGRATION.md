# Firebase to Supabase Migration Guide

## Overview

This document outlines the complete migration from Firebase to Supabase for the TailorApp Flutter application.

## Migration Summary

### ✅ Completed Tasks

1. **Dependencies Updated**
   - Removed Firebase dependencies: `firebase_core`, `cloud_firestore`, `firebase_storage`, `firebase_auth`
   - Added Supabase dependency: `supabase_flutter: ^2.9.1`

2. **Configuration Files**
   - Created `lib/supabase_options.dart` with Supabase configuration
   - Removed Firebase configuration files (`firebase.json`, `firestore.rules`, etc.)

3. **Authentication Service Migration**
   - Created `lib/core/services/supabase_auth_service.dart`
   - Migrated all authentication methods to use Supabase Auth
   - Maintained the same interface as the original Firebase auth service

4. **Repository Migration**
   - Created Supabase repository implementations for all entities:
     - `lib/core/repositories/supabase_user_repository.dart`
     - `lib/core/repositories/supabase_customer_repository.dart`
     - `lib/core/repositories/supabase_tailor_repository.dart`
     - `lib/core/repositories/supabase_admin_repository.dart`
     - `lib/core/repositories/supabase_order_repository.dart`
     - `lib/core/repositories/supabase_garment_repository.dart`

5. **Service Locator Updates**
   - Updated dependency injection to use Supabase implementations
   - Replaced Firebase Auth with Supabase client

6. **Database Schema & Security**
   - Created comprehensive PostgreSQL schema (`supabase_schema.sql`)
   - Implemented Row Level Security policies (`supabase_rls_policies.sql`)

## Setup Instructions

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note down your project URL and anon key

### 2. Configure Supabase in Flutter App

Update `lib/supabase_options.dart`:

```dart
static const String supabaseUrl = 'YOUR_ACTUAL_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_ACTUAL_SUPABASE_ANON_KEY';
```

### 3. Setup Database Schema

1. In your Supabase dashboard, go to the SQL Editor
2. Run the schema creation script: `supabase_schema.sql`
3. Run the RLS policies script: `supabase_rls_policies.sql`

### 4. Configure Storage

1. In Supabase dashboard, go to Storage
2. The schema script already creates the 'avatars' bucket
3. Verify the bucket policies are applied correctly

### 5. Authentication Setup

1. In Supabase dashboard, go to Authentication
2. Configure your authentication providers (email, Google, etc.)
3. Set up email templates if needed
4. Configure redirect URLs for OAuth

## Key Changes Made

### Database Structure

- **Firebase Collections** → **Supabase Tables**
  - `users` → `users` table with JSONB fields for role-specific data
  - `customers` → `customers` table
  - `tailors` → `tailors` table  
  - `admins` → `admins` table
  - `orders` → `orders` table
  - `garments` → `garments` table
  - `fabrics` → `fabrics` table
  - `patterns` → `patterns` table
  - `ai_suggestions` → `ai_suggestions` table
  - `measurements` → `measurements` table
  - `chats` → `chats` table + `chat_messages` table
  - `notifications` → `notifications` table

### Authentication Changes

- **Firebase Auth** → **Supabase Auth**
- Custom PIN authentication maintained
- Phone authentication using email conversion method
- OAuth integration simplified
- User roles managed through database instead of custom claims

### Security Rules Migration

- **Firestore Rules** → **PostgreSQL RLS Policies**
- User can access own data
- Role-based access control maintained
- Public read access for fabrics and patterns
- Admin-only access for admin functions

### Real-time Features

- Firestore real-time listeners → Supabase real-time subscriptions
- Real-time order updates maintained
- Chat functionality converted to real-time subscriptions

### File Storage

- Firebase Storage → Supabase Storage
- Profile images stored in 'avatars' bucket
- Public URL generation for images
- User-based folder structure maintained

## Migration Benefits

1. **Cost Efficiency**: Supabase typically offers better pricing than Firebase
2. **PostgreSQL**: More powerful querying capabilities with SQL
3. **Real-time**: Built-in real-time subscriptions
4. **Open Source**: Supabase is open source and can be self-hosted
5. **Developer Experience**: Better tooling and dashboard
6. **Familiar SQL**: Use standard SQL instead of Firestore queries

## Potential Issues & Solutions

### 1. Data Type Differences

- **Issue**: Firebase uses different data types than PostgreSQL
- **Solution**: JSONB fields used for complex objects, proper type conversion in repositories

### 2. Query Differences

- **Issue**: Firestore queries vs SQL queries
- **Solution**: Repository pattern abstracts the differences, SQL provides more flexibility

### 3. Real-time Subscriptions

- **Issue**: Different real-time APIs
- **Solution**: Maintained same interface, updated implementation to use Supabase channels

### 4. Authentication Flow

- **Issue**: Different auth providers and flows
- **Solution**: Custom PIN auth maintained using email conversion, OAuth simplified

## Testing Checklist

- [ ] User registration and login
- [ ] Profile management (customer, tailor, admin)
- [ ] Order creation and management
- [ ] Real-time updates (orders, chats)
- [ ] File uploads (profile images)
- [ ] Search functionality
- [ ] Role-based access control
- [ ] Offline functionality (if applicable)

## Environment Variables

Add these to your environment configuration:

```txt
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Next Steps

1. Set up Supabase project with provided configuration
2. Run database schema and RLS policies
3. Update Supabase configuration in Flutter app
4. Test all functionality thoroughly
5. Deploy and monitor for any issues

## Rollback Plan

If issues arise, you can temporarily:

1. Keep Firebase dependencies in `pubspec.yaml`
2. Switch service locator back to Firebase implementations
3. Revert main.dart to use Firebase initialization
4. Address issues and re-attempt migration

## Support

For any issues during migration:

1. Check Supabase documentation: <https://supabase.com/docs>
2. Review Flutter Supabase guide: <https://supabase.com/docs/guides/getting-started/quickstarts/flutter>
3. Test database queries in Supabase SQL Editor
4. Verify RLS policies are working correctly
