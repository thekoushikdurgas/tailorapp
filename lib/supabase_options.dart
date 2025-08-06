// Supabase configuration for TailorApp
// Database-only configuration without authentication

/// Configuration class for Supabase database connection
///
/// To set up your Supabase project:
/// 1. Go to https://supabase.com and create a new project
/// 2. Get your project URL and anon key from Settings > API
/// 3. Replace the values below with your actual credentials
/// 4. Run the SQL schema from supabase_database_schema.sql
class SupabaseConfig {
  // TODO: Replace with your actual Supabase project URL
  static const String supabaseUrl = 'https://qpyrgcqpqxoaarifogfx.supabase.co';

  // TODO: Replace with your actual Supabase anon key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFweXJnY3FwcXhvYWFyaWZvZ2Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4NjYxMjgsImV4cCI6MjA2ODQ0MjEyOH0.g9sF7Dz6i9jmcpTpzj8mzOIixNpJ_ZTJ7ExjEpT1hco';

  // Database configuration
  static const String defaultSchema = 'public';

  // Storage bucket names
  static const String avatarsBucket = 'avatars';
  static const String garmentImagesBucket = 'garment-images';
  static const String fabricSamplesBucket = 'fabric-samples';
  static const String patternFilesBucket = 'pattern-files';
  static const String orderDocumentsBucket = 'order-documents';
  static const String chatAttachmentsBucket = 'chat-attachments';
}
