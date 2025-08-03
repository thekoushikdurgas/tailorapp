import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/services/auth_service.dart';
import 'package:tailorapp/core/models/user_model.dart';
import 'package:tailorapp/core/models/user_role.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final UserModel userProfile;

  const AuthAuthenticated({
    required this.user,
    required this.userProfile,
  });

  @override
  List<Object?> get props => [
        user,
        userProfile,
      ];

  UserRole get userRole => userProfile.role;

  bool hasPermission(String permission) {
    return userRole.permissions.contains(permission);
  }

  String get homeRoute => userRole.homeRoute;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final AuthErrorType type;

  const AuthError({
    required this.message,
    required this.type,
  });

  @override
  List<Object?> get props => [message, type];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    emit(const AuthLoading());

    _authStateSubscription = _authService.authStateChanges.listen(
      (user) async {
        if (user != null) {
          await _handleUserAuthenticated(user);
        } else {
          emit(const AuthUnauthenticated());
        }
      },
      onError: (error) {
        emit(
          AuthError(
            message: 'Authentication stream error: ${error.toString()}',
            type: AuthErrorType.unknown,
          ),
        );
      },
    );
  }

  Future<void> _handleUserAuthenticated(User user) async {
    try {
      // Get user profile from the new unified user service
      final userProfile = await _authService.getCurrentUserProfile();

      if (userProfile != null) {
        emit(
          AuthAuthenticated(
            user: user,
            userProfile: userProfile,
          ),
        );
      } else {
        // User not found in database, this shouldn't happen if auth flow is correct
        emit(
          const AuthError(
            message: 'User profile not found. Please contact support.',
            type: AuthErrorType.userNotFound,
          ),
        );
      }
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to load user profile: ${e.toString()}',
          type: AuthErrorType.unknown,
        ),
      );
    }
  }

  // Authentication methods
  Future<void> signInWithEmailAndPin(String email, String pin) async {
    emit(const AuthLoading());

    final result = await _authService.signInWithEmailAndPin(email, pin);

    if (!result.isSuccess && result.error != null) {
      emit(
        AuthError(
          message: result.error!.message,
          type: result.error!.type,
        ),
      );
    }
    // Success case is handled by the auth state stream
  }

  Future<void> createUserWithEmailAndPin(
    String email,
    String pin,
    String name,
  ) async {
    emit(const AuthLoading());

    final result = await _authService.createUserWithEmailAndPin(
      email,
      pin,
      name,
    );

    if (!result.isSuccess && result.error != null) {
      emit(
        AuthError(
          message: result.error!.message,
          type: result.error!.type,
        ),
      );
    }
    // Success case is handled by the auth state stream
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());

    final result = await _authService.signInWithGoogle();

    if (!result.isSuccess && result.error != null) {
      emit(
        AuthError(
          message: result.error!.message,
          type: result.error!.type,
        ),
      );
    }
  }

  Future<void> signInAnonymously() async {
    emit(const AuthLoading());

    final result = await _authService.signInAnonymously();

    if (!result.isSuccess && result.error != null) {
      emit(
        AuthError(
          message: result.error!.message,
          type: result.error!.type,
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    await _authService.signOut();
    // Unauthenticated state will be emitted by the stream
  }

  Future<void> deleteAccount() async {
    emit(const AuthLoading());

    try {
      await _authService.deleteAccount();
      // Unauthenticated state will be emitted by the stream
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to delete account: ${e.toString()}',
          type: AuthErrorType.unknown,
        ),
      );
    }
  }

  // PIN management
  Future<void> sendPinResetEmail(String email) async {
    try {
      await _authService.sendPinResetEmail(email);
      // Could emit a success state if needed
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to send PIN reset email: ${e.toString()}',
          type: AuthErrorType.unknown,
        ),
      );
    }
  }

  Future<void> updatePin(String newPin) async {
    try {
      await _authService.updatePin(newPin);
      // PIN updated successfully
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to update PIN: ${e.toString()}',
          type: e.toString().contains('requires-recent-login')
              ? AuthErrorType.requiresRecentLogin
              : AuthErrorType.unknown,
        ),
      );
    }
  }

  // Email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      // Could emit a success state if needed
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to send email verification: ${e.toString()}',
          type: AuthErrorType.unknown,
        ),
      );
    }
  }

  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();

      // Refresh the current state with updated user info
      final user = _authService.currentUser;
      if (user != null) {
        await _handleUserAuthenticated(user);
      }
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to reload user: ${e.toString()}',
          type: AuthErrorType.unknown,
        ),
      );
    }
  }

  // Profile management
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Reload to get updated info
      await reloadUser();
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to update profile: ${e.toString()}',
          type: AuthErrorType.unknown,
        ),
      );
    }
  }

  Future<void> updateUserProfile(UserModel userProfile) async {
    try {
      await _authService.updateUserProfile(userProfile);

      // Update the current state with new user profile
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(
          AuthAuthenticated(
            user: currentState.user,
            userProfile: userProfile,
          ),
        );
      }
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to update user profile: ${e.toString()}',
          type: AuthErrorType.unknown,
        ),
      );
    }
  }

  // Phone authentication methods
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    emit(const AuthLoading());

    final result = await _authService.verifyPhoneNumber(phoneNumber);

    if (!result.isSuccess) {
      emit(
        AuthError(
          message: result.error ?? 'Phone verification failed',
          type: AuthErrorType.unknown,
        ),
      );
    }
    // Success case: verification ID is stored and PIN modal should be shown
    // The verification ID will be passed to the next step
  }

  Future<void> signInWithPhoneAndPin(String phoneNumber, String pin) async {
    emit(const AuthLoading());

    final result = await _authService.signInWithPhoneAndPin(phoneNumber, pin);

    if (!result.isSuccess && result.error != null) {
      emit(
        AuthError(
          message: result.error!.message,
          type: result.error!.type,
        ),
      );
    }
    // Success case is handled by the auth state stream
  }

  // Simplified phone authentication methods
  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      return await _authService.getUserByPhone(phoneNumber);
    } catch (e) {
      return null;
    }
  }

  Future<void> signInWithPhoneAndPinDirect(String phoneNumber, String pin) async {
    emit(const AuthLoading());

    final result = await _authService.signInWithPhoneAndPinDirect(phoneNumber, pin);

    if (!result.isSuccess && result.error != null) {
      emit(
        AuthError(
          message: result.error!.message,
          type: result.error!.type,
        ),
      );
    }
    // Success case is handled by the auth state stream
  }

  Future<void> createUserWithPhoneAndPin({
    required String phoneNumber,
    required String name,
    required String email,
    required String pin,
    required UserRole role,
  }) async {
    emit(const AuthLoading());

    final result = await _authService.createUserWithPhoneAndPin(
      phoneNumber: phoneNumber,
      name: name,
      email: email,
      pin: pin,
      role: role,
    );

    if (!result.isSuccess && result.error != null) {
      emit(
        AuthError(
          message: result.error!.message,
          type: result.error!.type,
        ),
      );
    }
    // Success case is handled by the auth state stream
  }

  // Check if user exists by phone number
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      return await _authService.checkUserExistsByPhone(phoneNumber);
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  bool get isAuthenticated => state is AuthAuthenticated;

  User? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  UserModel? get currentUserProfile {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.userProfile;
    }
    return null;
  }

  String? get currentUserId => currentUser?.uid;

  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Clear error state
  void clearError() {
    if (state is AuthError) {
      emit(const AuthUnauthenticated());
    }
  }

  // Retry authentication check
  Future<void> retry() async {
    emit(const AuthLoading());
    final user = _authService.currentUser;
    if (user != null) {
      await _handleUserAuthenticated(user);
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
