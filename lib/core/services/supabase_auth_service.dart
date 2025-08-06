import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:tailorapp/core/models/user_model.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/core/repositories/user_repository.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/services/auth_service.dart';
import 'package:tailorapp/supabase_options.dart';

/// Supabase authentication service for TailorApp
///
/// Provides comprehensive authentication functionality including:
/// - Email/password authentication
/// - Phone-based authentication with PIN
/// - OAuth providers (Google, Apple, etc.)
/// - User profile management
/// - Role-based access control
class SupabaseAuthService implements AuthService {
  final supabase.SupabaseClient _supabase;
  final UserRepository _userRepository;

  SupabaseAuthService({
    supabase.SupabaseClient? supabaseClient,
    required UserRepository userRepository,
  })  : _supabase = supabaseClient ?? supabase.Supabase.instance.client,
        _userRepository = userRepository;

  @override
  Stream<supabase.User?> get authStateChanges => _supabase.auth.onAuthStateChange.map((data) => data.session?.user);

  @override
  supabase.User? get currentUser => _supabase.auth.currentUser;

  @override
  bool get isAuthenticated => currentUser != null;

  @override
  Future<AuthResult> signInWithEmailAndPin(
    String email,
    String pin,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: pin,
      );

      if (response.user != null) {
        return AuthResult.success(response.user);
      } else {
        return AuthResult.failure(AuthError.unknown('Sign in failed'));
      }
    } on supabase.AuthException catch (e) {
      return AuthResult.failure(_mapSupabaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPin(
    String email,
    String pin,
    String name,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: pin,
        data: {'name': name},
      );

      if (response.user != null) {
        // Create user profile with customer role
        final userProfile = UserModel.customer(
          id: response.user!.id,
          name: name,
          email: email,
          phone: response.user!.phone ?? '',
          isVerified: response.user!.emailConfirmedAt != null,
        );

        await _userRepository.createUser(userProfile);

        return AuthResult.success(response.user);
      }

      return AuthResult.failure(AuthError.unknown('Failed to create user'));
    } on supabase.AuthException catch (e) {
      return AuthResult.failure(_mapSupabaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        supabase.OAuthProvider.google,
        redirectTo: SupabaseConfig.redirectUrl,
      );

      // Wait for auth state change
      final user = _supabase.auth.currentUser;
      if (user != null) {
        return AuthResult.success(user);
      } else {
        return AuthResult.failure(AuthError.unknown('Google sign-in failed'));
      }
    } on supabase.AuthException catch (e) {
      return AuthResult.failure(_mapSupabaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult> signInAnonymously() async {
    try {
      final response = await _supabase.auth.signInAnonymously();
      return AuthResult.success(response.user);
    } on supabase.AuthException catch (e) {
      return AuthResult.failure(_mapSupabaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      // Delete user profile first
      await _userRepository.deleteUser(user.id);

      // Supabase doesn't have direct user deletion from client
      // This would typically be handled by a server-side function
      // For now, we'll just sign out
      await signOut();
    }
  }

  @override
  Future<PhoneAuthResult> verifyPhoneNumber(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phoneNumber);
      return PhoneAuthResult.success('otp_sent');
    } catch (e) {
      return PhoneAuthResult.failure(
        AuthError.unknown('Phone verification failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AuthResult> signInWithPhoneAndPin(
    String phoneNumber,
    String pin,
  ) async {
    try {
      // For Supabase, phone authentication with PIN would need custom implementation
      // This is a simplified version that creates a phone-based email
      final phoneEmail = '${phoneNumber.replaceAll('+', '')}@phone.auth';

      return await signInWithEmailAndPin(phoneEmail, pin);
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<bool> checkUserExistsByPhone(String phoneNumber) async {
    try {
      final user = await _userRepository.getUserByPhone(phoneNumber);
      return user != null;
    } catch (e) {
      DebugLogger.auth('Error checking user existence: $e');
      return false;
    }
  }

  @override
  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      return await _userRepository.getUserByPhone(phoneNumber);
    } catch (e) {
      DebugLogger.auth('Error getting user by phone: $e');
      return null;
    }
  }

  @override
  Future<AuthResult> signInWithPhoneAndPinDirect(
    String phoneNumber,
    String pin,
  ) async {
    try {
      // Get user from database first to verify they exist
      final userProfile = await _userRepository.getUserByPhone(phoneNumber);
      if (userProfile == null) {
        return AuthResult.failure(
          const AuthError(
            type: AuthErrorType.userNotFound,
            message: 'User not found with this phone number',
          ),
        );
      }

      // Use phone number as email for Supabase Auth
      final phoneEmail = '${phoneNumber.replaceAll('+', '')}@phone.auth';

      final response = await _supabase.auth.signInWithPassword(
        email: phoneEmail,
        password: pin,
      );

      if (response.user != null) {
        DebugLogger.auth('Direct phone sign-in successful for: $phoneNumber');
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.failure(
          const AuthError(
            type: AuthErrorType.unknown,
            message: 'Authentication failed',
          ),
        );
      }
    } on supabase.AuthException catch (e) {
      DebugLogger.auth('Direct phone sign-in error: ${e.message}');
      return AuthResult.failure(_mapSupabaseError(e));
    } catch (e) {
      DebugLogger.auth('Unexpected error during direct phone sign-in: $e');
      return AuthResult.failure(
        AuthError(
          type: AuthErrorType.unknown,
          message: 'Authentication failed: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<AuthResult> createUserWithPhoneAndPin({
    required String phoneNumber,
    required String name,
    required String email,
    required String pin,
    required UserRole role,
  }) async {
    try {
      // For simplified auth, use phone number as email
      final phoneEmail = '${phoneNumber.replaceAll('+', '')}@phone.auth';

      final response = await _supabase.auth.signUp(
        email: phoneEmail,
        password: pin,
        data: {'name': name, 'phone': phoneNumber},
      );

      if (response.user != null) {
        // Create user profile based on role
        UserModel userProfile;

        switch (role) {
          case UserRole.customer:
            userProfile = UserModel.customer(
              id: response.user!.id,
              name: name,
              email: email,
              phone: phoneNumber,
              isVerified: true, // Phone authenticated
            );
            break;
          case UserRole.tailor:
            userProfile = UserModel.tailor(
              id: response.user!.id,
              name: name,
              email: email,
              phone: phoneNumber,
              isVerified: true, // Phone authenticated
            );
            break;
          case UserRole.admin:
            userProfile = UserModel.admin(
              id: response.user!.id,
              name: name,
              email: email,
              phone: phoneNumber,
              isVerified: true, // Phone authenticated
            );
            break;
        }

        await _userRepository.createUser(userProfile);

        // Set user role (TODO: implement properly with RLS policies)
        await setUserRole(response.user!.id, role);

        return AuthResult.success(response.user);
      }

      return AuthResult.failure(AuthError.unknown('Failed to create user'));
    } on supabase.AuthException catch (e) {
      return AuthResult.failure(_mapSupabaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<void> sendPinResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePin(String newPin) async {
    final user = currentUser;
    if (user != null) {
      await _supabase.auth.updateUser(supabase.UserAttributes(password: newPin));
    } else {
      throw Exception('No authenticated user');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null && user.emailConfirmedAt == null) {
      await _supabase.auth.resend(
        type: supabase.OtpType.signup,
        email: user.email,
      );
    }
  }

  @override
  Future<void> reloadUser() async {
    // Supabase handles user state automatically
    // You can manually refresh session if needed
    await _supabase.auth.refreshSession();
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    final user = currentUser;
    if (user != null) {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['name'] = displayName;
      if (photoURL != null) updates['avatar_url'] = photoURL;

      if (updates.isNotEmpty) {
        await _supabase.auth.updateUser(supabase.UserAttributes(data: updates));
      }
    }
  }

  @override
  Future<UserRole> getUserRole(String uid) async {
    try {
      final user = await _userRepository.getUser(uid);
      return user?.role ?? UserRole.customer;
    } catch (e) {
      // Default to customer on error
      return UserRole.customer;
    }
  }

  @override
  Future<void> setUserRole(String uid, UserRole role) async {
    try {
      // This would typically be implemented via RLS policies in Supabase
      // For now, we'll update the user document
      final user = await _userRepository.getUser(uid);
      if (user != null) {
        final updatedUser = user.copyWith(role: role);
        await _userRepository.updateUser(updatedUser);
      }
      DebugLogger.auth('Setting user role to ${role.value} for user $uid');
    } catch (e) {
      throw Exception('Failed to set user role: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user != null) {
      try {
        return await _userRepository.getUser(user.id);
      } catch (e) {
        DebugLogger.auth('Error getting user profile: $e');
      }
    }
    return null;
  }

  @override
  Future<void> updateUserProfile(UserModel userProfile) async {
    try {
      await _userRepository.updateUser(userProfile);
    } catch (e) {
      DebugLogger.user('Failed to update user profile: $e');
      rethrow;
    }
  }

  AuthError _mapSupabaseError(supabase.AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return AuthError.wrongPassword();
      case 'User not found':
        return AuthError.userNotFound();
      case 'Email already registered':
        return AuthError.emailAlreadyInUse();
      case 'Invalid email':
        return AuthError.invalidEmail();
      case 'Weak password':
        return AuthError.weakPassword();
      case 'Too many requests':
        return AuthError.tooManyRequests();
      default:
        return AuthError.unknown(e.message);
    }
  }
}
