// Supabase configuration for TailorApp
// Replace these with your actual Supabase project URL and anon key
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuration class for Supabase connection
class SupabaseConfig {
  // Supabase project URL
  static const String supabaseUrl = 'https://qpyrgcqpqxoaarifogfx.supabase.co';

  // Supabase anon key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFweXJnY3FwcXhvYWFyaWZvZ2Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4NjYxMjgsImV4cCI6MjA2ODQ0MjEyOH0.g9sF7Dz6i9jmcpTpzj8mzOIixNpJ_ZTJ7ExjEpT1hco';

  /// Deep link configuration for authentication redirects
  static String get redirectUrl {
    if (kIsWeb) {
      return 'https://your-app-domain.com/auth/callback';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'com.durgas.tailorapp://auth/callback';
      case TargetPlatform.iOS:
        return 'com.durgas.tailorapp://auth/callback';
      case TargetPlatform.macOS:
        return 'com.durgas.tailorapp://auth/callback';
      case TargetPlatform.windows:
        return 'com.durgas.tailorapp://auth/callback';
      case TargetPlatform.linux:
        throw UnsupportedError(
          'SupabaseConfig has not been configured for linux - '
          'you can configure this based on your app requirements.',
        );
      default:
        throw UnsupportedError(
          'SupabaseConfig is not supported for this platform.',
        );
    }
  }
}
