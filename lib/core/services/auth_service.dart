import 'package:firebase_auth/firebase_auth.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/core/models/tailor_model.dart';
import 'package:tailorapp/core/models/admin_model.dart';
import 'package:tailorapp/core/repositories/customer_repository.dart';
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

  // PIN management
  Future<void> sendPinResetEmail(String email);
  Future<void> updatePin(String newPin);

  // Email verification
  Future<void> sendEmailVerification();
  Future<void> reloadUser();

  // Profile management
  Future<void> updateProfile({String? displayName, String? photoURL});

  // Role management
  Future<UserRole> getUserRole(String uid);
  Future<void> setUserRole(String uid, UserRole role);

  // Profile integration by role
  Future<CustomerModel?> getCurrentCustomerProfile();
  Future<TailorModel?> getCurrentTailorProfile();
  Future<AdminModel?> getCurrentAdminProfile();

  Future<void> createCustomerProfile(CustomerModel customer);
  Future<void> createTailorProfile(TailorModel tailor);
  Future<void> createAdminProfile(AdminModel admin);

  Future<void> updateCustomerProfile(CustomerModel customer);
  Future<void> updateTailorProfile(TailorModel tailor);
  Future<void> updateAdminProfile(AdminModel admin);
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final CustomerRepository _customerRepository;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    required CustomerRepository customerRepository,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _customerRepository = customerRepository;

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

        // Create customer profile
        final customer = CustomerModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          stylePreferences: const StylePreferences(
            preferredStyles: [],
            preferredColors: [],
            preferredFabrics: [],
            dislikedColors: [],
            dislikedFabrics: [],
            occasions: [],
          ),
          orderHistory: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: false,
        );

        await _customerRepository.createCustomer(customer);

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
      // Delete customer profile first
      await _customerRepository.deleteCustomer(user.uid);

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
  Future<CustomerModel?> getCurrentCustomerProfile() async {
    final user = currentUser;
    if (user != null) {
      return await _customerRepository.getCustomer(user.uid);
    }
    return null;
  }

  @override
  Future<TailorModel?> getCurrentTailorProfile() async {
    final user = currentUser;
    if (user != null) {
      // TODO: Implement TailorRepository and get tailor profile
      // For now, return null
      return null;
    }
    return null;
  }

  @override
  Future<AdminModel?> getCurrentAdminProfile() async {
    final user = currentUser;
    if (user != null) {
      // TODO: Implement AdminRepository and get admin profile
      // For now, return null
      return null;
    }
    return null;
  }

  @override
  Future<void> createCustomerProfile(CustomerModel customer) async {
    await _customerRepository.createCustomer(customer);
  }

  @override
  Future<void> createTailorProfile(TailorModel tailor) async {
    // TODO: Implement TailorRepository and create tailor profile
    DebugLogger.user('Creating tailor profile for ${tailor.name}');
  }

  @override
  Future<void> createAdminProfile(AdminModel admin) async {
    // TODO: Implement AdminRepository and create admin profile
    DebugLogger.user('Creating admin profile for ${admin.name}');
  }

  @override
  Future<void> updateCustomerProfile(CustomerModel customer) async {
    await _customerRepository.updateCustomer(customer);
  }

  @override
  Future<void> updateTailorProfile(TailorModel tailor) async {
    // TODO: Implement TailorRepository and update tailor profile
    DebugLogger.user('Updating tailor profile for ${tailor.name}');
  }

  @override
  Future<void> updateAdminProfile(AdminModel admin) async {
    // TODO: Implement AdminRepository and update admin profile
    DebugLogger.user('Updating admin profile for ${admin.name}');
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
