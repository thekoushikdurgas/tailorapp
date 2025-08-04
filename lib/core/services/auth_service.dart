import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorapp/core/models/user_model.dart';
import 'package:tailorapp/core/models/user_role.dart';

abstract class AuthService {
  // Auth state
  Stream<User?> get authStateChanges;
  User? get currentUser;
  bool get isAuthenticated;

  // Authentication methods
  Future<AuthResult> signInWithEmailAndPin(String email, String pin);
  Future<AuthResult> createUserWithEmailAndPin(
    String email,
    String pin,
    String name,
  );
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInAnonymously();
  Future<void> signOut();
  Future<void> deleteAccount();

  // Phone authentication methods
  Future<PhoneAuthResult> verifyPhoneNumber(String phoneNumber);
  Future<AuthResult> signInWithPhoneAndPin(String phoneNumber, String pin);

  // User existence check
  Future<bool> checkUserExistsByPhone(String phoneNumber);

  // Simplified phone authentication (no OTP)
  Future<UserModel?> getUserByPhone(String phoneNumber);
  Future<AuthResult> signInWithPhoneAndPinDirect(
    String phoneNumber,
    String pin,
  );

  // User creation with phone
  Future<AuthResult> createUserWithPhoneAndPin({
    required String phoneNumber,
    required String name,
    required String email,
    required String pin,
    required UserRole role,
  });

  // PIN management
  Future<void> sendPinResetEmail(String email);
  Future<void> updatePin(String newPin);

  // Email verification
  Future<void> sendEmailVerification();
  Future<void> reloadUser();

  // Profile management
  Future<void> updateProfile({String? displayName, String? photoURL});

  // User profile management
  Future<UserModel?> getCurrentUserProfile();
  Future<void> updateUserProfile(UserModel userProfile);

  // Role management
  Future<UserRole> getUserRole(String uid);
  Future<void> setUserRole(String uid, UserRole role);
}

// Result classes for authentication operations
class AuthResult {
  final bool isSuccess;
  final User? user;
  final AuthError? error;

  AuthResult._({required this.isSuccess, this.user, this.error});

  factory AuthResult.success(User? user) =>
      AuthResult._(isSuccess: true, user: user);
  factory AuthResult.failure(AuthError error) =>
      AuthResult._(isSuccess: false, error: error);
}

class PhoneAuthResult {
  final bool isSuccess;
  final String? verificationId;
  final AuthError? error;

  PhoneAuthResult._({required this.isSuccess, this.verificationId, this.error});

  factory PhoneAuthResult.success(String verificationId) =>
      PhoneAuthResult._(isSuccess: true, verificationId: verificationId);
  factory PhoneAuthResult.failure(AuthError error) =>
      PhoneAuthResult._(isSuccess: false, error: error);
}

// Exception classes for authentication operations
class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => 'AuthServiceException: $message';
}

// Error handling classes
enum AuthErrorType {
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  userDisabled,
  tooManyRequests,
  operationNotAllowed,
  requiresRecentLogin,
  notImplemented,
  unknown,
}

class AuthError {
  final AuthErrorType type;
  final String message;

  const AuthError({required this.type, required this.message});

  factory AuthError.userNotFound() {
    return const AuthError(
      type: AuthErrorType.userNotFound,
      message: 'No user found with this email address.',
    );
  }

  factory AuthError.wrongPassword() {
    return const AuthError(
      type: AuthErrorType.wrongPassword,
      message: 'Incorrect PIN. Please try again.',
    );
  }

  factory AuthError.emailAlreadyInUse() {
    return const AuthError(
      type: AuthErrorType.emailAlreadyInUse,
      message: 'An account already exists with this email address.',
    );
  }

  factory AuthError.weakPassword() {
    return const AuthError(
      type: AuthErrorType.weakPassword,
      message: 'PIN is too weak. Please choose a stronger PIN.',
    );
  }

  factory AuthError.invalidEmail() {
    return const AuthError(
      type: AuthErrorType.invalidEmail,
      message: 'Please enter a valid email address.',
    );
  }

  factory AuthError.userDisabled() {
    return const AuthError(
      type: AuthErrorType.userDisabled,
      message: 'This account has been disabled.',
    );
  }

  factory AuthError.tooManyRequests() {
    return const AuthError(
      type: AuthErrorType.tooManyRequests,
      message: 'Too many failed attempts. Please try again later.',
    );
  }

  factory AuthError.operationNotAllowed() {
    return const AuthError(
      type: AuthErrorType.operationNotAllowed,
      message: 'This operation is not allowed.',
    );
  }

  factory AuthError.requiresRecentLogin() {
    return const AuthError(
      type: AuthErrorType.requiresRecentLogin,
      message: 'Please sign in again to complete this action.',
    );
  }

  factory AuthError.notImplemented(String feature) {
    return AuthError(
      type: AuthErrorType.notImplemented,
      message: '$feature is not implemented yet.',
    );
  }

  factory AuthError.unknown(String message) {
    return AuthError(
      type: AuthErrorType.unknown,
      message: 'An unexpected error occurred: $message',
    );
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
