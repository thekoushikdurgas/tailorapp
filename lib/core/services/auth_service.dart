import 'package:firebase_auth/firebase_auth.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/repositories/customer_repository.dart';

abstract class AuthService {
  // Auth state
  Stream<User?> get authStateChanges;
  User? get currentUser;
  bool get isAuthenticated;

  // Authentication methods
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  Future<AuthResult> createUserWithEmailAndPassword(
      String email, String password, String name);
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInAnonymously();
  Future<void> signOut();
  Future<void> deleteAccount();

  // Password management
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);

  // Email verification
  Future<void> sendEmailVerification();
  Future<void> reloadUser();

  // Profile management
  Future<void> updateProfile({String? displayName, String? photoURL});

  // Customer profile integration
  Future<CustomerModel?> getCurrentCustomerProfile();
  Future<void> createCustomerProfile(CustomerModel customer);
  Future<void> updateCustomerProfile(CustomerModel customer);
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
  Future<AuthResult> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
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
          orderHistory: [],
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
          AuthError.notImplemented('Google Sign-In not implemented yet'));
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
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final user = currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw AuthException('No authenticated user');
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
  Future<CustomerModel?> getCurrentCustomerProfile() async {
    final user = currentUser;
    if (user != null) {
      return await _customerRepository.getCustomer(user.uid);
    }
    return null;
  }

  @override
  Future<void> createCustomerProfile(CustomerModel customer) async {
    await _customerRepository.createCustomer(customer);
  }

  @override
  Future<void> updateCustomerProfile(CustomerModel customer) async {
    await _customerRepository.updateCustomer(customer);
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
      message: 'Incorrect password. Please try again.',
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
      message: 'Password is too weak. Please choose a stronger password.',
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
