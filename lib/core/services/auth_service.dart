import 'package:firebase_auth/firebase_auth.dart';
import 'package:tailorapp/core/models/user_model.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/core/repositories/user_repository.dart';
import 'package:tailorapp/core/services/debug_logger.dart';

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
  Future<AuthResult> signInWithPhoneAndPinDirect(String phoneNumber, String pin);

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

  // User profile management (unified)
  Future<UserModel?> getCurrentUserProfile();
  Future<void> updateUserProfile(UserModel userProfile);

  // Role management
  Future<UserRole> getUserRole(String uid);
  Future<void> setUserRole(String uid, UserRole role);
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    required UserRepository userRepository,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _userRepository = userRepository;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  bool get isAuthenticated => currentUser != null;

  @override
  Future<AuthResult> signInWithEmailAndPin(
    String email,
    String pin,
  ) async {
    try {
      // For Firebase Auth, we still use the pin as password since Firebase expects password auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: pin,
      );

      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
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
      // For Firebase Auth, we still use the pin as password since Firebase expects password auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: pin,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user profile with customer role
        final userProfile = UserModel.customer(
          id: credential.user!.uid,
          name: name,
          email: email,
          phone: credential.user!.phoneNumber ?? '',
          isVerified: false,
        );

        await _userRepository.createUser(userProfile);

        return AuthResult.success(credential.user);
      }

      return AuthResult.failure(AuthError.unknown('Failed to create user'));
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Note: Google Sign-In implementation would require google_sign_in package
      // For now, return not implemented
      return AuthResult.failure(
        AuthError.notImplemented('Google Sign-In not implemented yet'),
      );
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      // Delete user profile first
      await _userRepository.deleteUser(user.uid);

      // Delete Firebase user
      await user.delete();
    }
  }

  @override
  Future<void> sendPinResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updatePin(String newPin) async {
    final user = currentUser;
    if (user != null) {
      await user.updatePassword(newPin);
    } else {
      throw const AuthException('No authenticated user');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> reloadUser() async {
    final user = currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    final user = currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }

  @override
  Future<UserRole> getUserRole(String uid) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final idTokenResult = await user.getIdTokenResult();
        final claims = idTokenResult.claims;

        // Check custom claims for role
        if (claims?['admin'] == true) return UserRole.admin;
        if (claims?['tailor'] == true) return UserRole.tailor;
        if (claims?['customer'] == true) return UserRole.customer;

        // Check role field in claims
        final roleString = claims?['role'] as String?;
        if (roleString != null) {
          return UserRoleExtension.fromString(roleString);
        }
      }

      // Default to customer if no role found
      return UserRole.customer;
    } catch (e) {
      // Default to customer on error
      return UserRole.customer;
    }
  }

  @override
  Future<void> setUserRole(String uid, UserRole role) async {
    // Note: This would typically be implemented via Cloud Functions
    // For now, we'll store it in Firestore user document
    // In production, this should set Firebase custom claims
    try {
      // This is a placeholder - in production you'd call a Cloud Function
      // that has admin privileges to set custom claims
      DebugLogger.auth('Setting user role to ${role.value} for user $uid');
      // TODO: Implement Cloud Function call to set custom claims
    } catch (e) {
      throw AuthException('Failed to set user role: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user != null) {
      try {
        return await _userRepository.getUser(user.uid);
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
  Future<AuthResult> signInWithPhoneAndPinDirect(String phoneNumber, String pin) async {
    try {
      // Get user from Firestore first to verify they exist
      final userProfile = await _userRepository.getUserByPhone(phoneNumber);
      if (userProfile == null) {
        return AuthResult.failure(
          const AuthError(
            type: AuthErrorType.userNotFound,
            message: 'User not found with this phone number',
          ),
        );
      }

      // Use phone number as email for Firebase Auth
      final phoneEmail = '${phoneNumber.replaceAll('+', '')}@phone.auth';

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: phoneEmail,
        password: pin,
      );

      if (credential.user != null) {
        DebugLogger.auth('Direct phone sign-in successful for: $phoneNumber');
        return AuthResult.success(credential.user!);
      } else {
        return AuthResult.failure(
          const AuthError(
            type: AuthErrorType.unknown,
            message: 'Authentication failed',
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      DebugLogger.auth('Direct phone sign-in error: ${e.message}');

      AuthErrorType errorType;
      String message;

      switch (e.code) {
        case 'user-not-found':
          errorType = AuthErrorType.userNotFound;
          message = 'No account found with this phone number';
          break;
        case 'wrong-password':
          errorType = AuthErrorType.wrongPassword;
          message = 'Incorrect PIN';
          break;
        case 'invalid-email':
          errorType = AuthErrorType.invalidEmail;
          message = 'Invalid phone number format';
          break;
        case 'user-disabled':
          errorType = AuthErrorType.userDisabled;
          message = 'This account has been disabled';
          break;
        default:
          errorType = AuthErrorType.unknown;
          message = e.message ?? 'Authentication failed';
      }

      return AuthResult.failure(
        AuthError(
          type: errorType,
          message: message,
        ),
      );
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

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: phoneEmail,
        password: pin,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user profile based on role
        UserModel userProfile;

        switch (role) {
          case UserRole.customer:
            userProfile = UserModel.customer(
              id: credential.user!.uid,
              name: name,
              email: email,
              phone: phoneNumber,
              isVerified: true, // Phone authenticated
            );
            break;
          case UserRole.tailor:
            userProfile = UserModel.tailor(
              id: credential.user!.uid,
              name: name,
              email: email,
              phone: phoneNumber,
              isVerified: true, // Phone authenticated
            );
            break;
          case UserRole.admin:
            userProfile = UserModel.admin(
              id: credential.user!.uid,
              name: name,
              email: email,
              phone: phoneNumber,
              isVerified: true, // Phone authenticated
            );
            break;
        }

        await _userRepository.createUser(userProfile);

        // Set user role (TODO: implement properly with cloud functions)
        await setUserRole(credential.user!.uid, role);

        return AuthResult.success(credential.user);
      }

      return AuthResult.failure(AuthError.unknown('Failed to create user'));
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<PhoneAuthResult> verifyPhoneNumber(String phoneNumber) async {
    try {
      String? verificationId;
      String? errorMessage;

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution of verification code (Android only)
          // This will not be used in our PIN flow but Firebase requires it
        },
        verificationFailed: (FirebaseAuthException e) {
          errorMessage = e.message ?? 'Phone verification failed';
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          // Called when auto-retrieval times out
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait a bit for the callback to be processed
      await Future.delayed(const Duration(milliseconds: 500));

      if (errorMessage != null) {
        return PhoneAuthResult.failure(errorMessage!);
      }

      if (verificationId != null) {
        return PhoneAuthResult.success(verificationId!);
      }

      return PhoneAuthResult.failure('Phone verification failed');
    } catch (e) {
      return PhoneAuthResult.failure(
        'Phone verification error: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResult> signInWithPhoneAndPin(
    String phoneNumber,
    String pin,
  ) async {
    try {
      // For simplified auth, use email/password with phone number as email
      // In production, you'd implement proper phone + PIN authentication
      final email = '${phoneNumber.replaceAll('+', '')}@phone.auth';

      try {
        // Try to sign in first
        final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: pin,
        );
        return AuthResult.success(credential.user);
      } catch (signInError) {
        // If sign in fails, try to create new user
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: pin,
        );

        if (credential.user != null) {
          // Update display name to show phone number
          await credential.user!.updateDisplayName(phoneNumber);

          // Create customer profile (this shouldn't happen in new flow)
          final userProfile = UserModel.customer(
            id: credential.user!.uid,
            name: 'User', // Default name, can be updated later
            email: email,
            phone: phoneNumber,
            isVerified: true, // Phone authenticated
          );

          await _userRepository.createUser(userProfile);
        }

        return AuthResult.success(credential.user);
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  AuthError _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthError.userNotFound();
      case 'wrong-password':
        return AuthError.wrongPassword();
      case 'email-already-in-use':
        return AuthError.emailAlreadyInUse();
      case 'weak-password':
        return AuthError.weakPassword();
      case 'invalid-email':
        return AuthError.invalidEmail();
      case 'user-disabled':
        return AuthError.userDisabled();
      case 'too-many-requests':
        return AuthError.tooManyRequests();
      case 'operation-not-allowed':
        return AuthError.operationNotAllowed();
      case 'requires-recent-login':
        return AuthError.requiresRecentLogin();
      default:
        return AuthError.unknown(e.message ?? 'Unknown error');
    }
  }
}

// Result classes
class AuthResult {
  final bool isSuccess;
  final User? user;
  final AuthError? error;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
  });

  factory AuthResult.success(User? user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(AuthError error) {
    return AuthResult._(isSuccess: false, error: error);
  }
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

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

// Phone Auth Result classes
class PhoneAuthResult {
  final bool isSuccess;
  final String? verificationId;
  final String? error;

  const PhoneAuthResult._({
    required this.isSuccess,
    this.verificationId,
    this.error,
  });

  factory PhoneAuthResult.success(String verificationId) {
    return PhoneAuthResult._(isSuccess: true, verificationId: verificationId);
  }

  factory PhoneAuthResult.failure(String error) {
    return PhoneAuthResult._(isSuccess: false, error: error);
  }
}
