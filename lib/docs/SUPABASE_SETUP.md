# Supabase Setup Guide for TailorApp

This guide will help you set up Supabase as the backend database for the AI-powered tailoring platform.

## 🚀 Quick Start

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new account
2. Click "New Project"
3. Choose your organization
4. Set project name: `tailor-app`
5. Set database password (save this securely)
6. Choose your region (closest to your users)
7. Click "Create new project"

### 2. Get Project Credentials

1. Go to Project Settings → API
2. Copy your Project URL
3. Copy your `anon` `public` key
4. Update `lib/supabase_options.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
  static const String redirectUrl = 'com.durgas.tailorapp://auth/callback';
}
```

### 3. Setup Database Schema

1. Go to SQL Editor in your Supabase dashboard
2. Run the schema creation script from `supabase_schema.sql`
3. Run the RLS policies from `supabase_rls_policies.sql`

### 4. Configure Authentication

1. Go to Authentication → Settings
2. Set Site URL: `com.durgas.tailorapp://auth/callback`
3. Add Redirect URLs:
   - `com.durgas.tailorapp://auth/callback`
   - `http://localhost:3000` (for development)

### 5. Setup OAuth Providers (Optional)

#### Google OAuth

1. Go to Authentication → Providers → Google
2. Enable Google provider
3. Add your Google OAuth credentials:
   - Client ID (from Google Cloud Console)
   - Client Secret (from Google Cloud Console)

#### Apple OAuth

1. Go to Authentication → Providers → Apple
2. Enable Apple provider
3. Add your Apple OAuth credentials

### 6. Configure Storage

1. Go to Storage in Supabase dashboard
2. The `avatars` bucket is already created by the schema
3. Verify RLS policies are active for secure file access

## 📱 App Configuration

### Deep Links Setup

The app is already configured for deep links:

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="com.durgas.tailorapp" />
</intent-filter>
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.durgas.tailorapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.durgas.tailorapp</string>
        </array>
    </dict>
</array>
```

## 🏗️ Architecture Overview

### Database Tables

- **users** - Main user authentication and profile data
- **customers** - Customer-specific data and preferences
- **tailors** - Tailor profiles and business information
- **admins** - Admin accounts and permissions
- **orders** - Order management and tracking
- **garments** - Garment designs and specifications
- **fabrics** - Fabric library and properties
- **patterns** - Design patterns and templates
- **ai_suggestions** - AI-generated design recommendations
- **measurements** - Customer body measurements
- **chats** - Customer-tailor communications
- **chat_messages** - Individual chat messages
- **notifications** - User notifications
- **admin_activity_logs** - Admin action audit trail

### Authentication Features

- ✅ Email/password authentication
- ✅ Phone-based authentication with PIN
- ✅ Google OAuth
- ✅ Apple OAuth (iOS)
- ✅ User roles (customer, tailor, admin)
- ✅ Profile management
- ✅ Password reset

### Security Features

- ✅ Row Level Security (RLS) policies
- ✅ Role-based access control
- ✅ Secure file storage
- ✅ API key protection
- ✅ Deep link security

## 🧪 Testing Your Setup

### 1. Run the App

```bash
flutter clean
flutter pub get
flutter run
```

### 2. Test Authentication

- [ ] Register new user with email/PIN
- [ ] Login with existing credentials
- [ ] Test Google OAuth (if configured)
- [ ] Test password reset
- [ ] Test phone authentication

### 3. Test Database Operations

- [ ] Create user profile
- [ ] Update profile information
- [ ] Create order
- [ ] Upload profile image

### 4. Test Real-time Features

- [ ] Real-time order updates
- [ ] Chat messaging
- [ ] Notifications

## 🔧 Development Tips

### Environment Setup

Create a `.env` file for sensitive data:

```env
SUPABASE_URL=your_url_here
SUPABASE_ANON_KEY=your_key_here
```

### Database Debugging

- Use Supabase SQL Editor for direct queries
- Check RLS policies if access is denied
- Monitor real-time subscriptions in dashboard

### Authentication Debugging

- Check redirect URLs are exact matches
- Verify OAuth provider credentials
- Test deep links with `adb shell am start`

## 📚 Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [OAuth Setup](https://supabase.com/docs/guides/auth/social-login)

## 🆘 Common Issues

### Authentication Issues

- **Issue**: OAuth redirect not working
- **Solution**: Check redirect URLs in Supabase settings match exactly

### Database Issues

- **Issue**: RLS policy blocking access
- **Solution**: Check user role and policy conditions

### Connection Issues

- **Issue**: Cannot connect to Supabase
- **Solution**: Verify URL and API key are correct

## 🚀 Production Deployment

### Environment Variables

Set these in your production environment:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Security Checklist

- [ ] Update default passwords
- [ ] Review RLS policies
- [ ] Enable 2FA for Supabase account
- [ ] Monitor usage and logs
- [ ] Set up backup policies

---

Your TailorApp is now ready with Supabase as a modern, scalable backend! 🎉
