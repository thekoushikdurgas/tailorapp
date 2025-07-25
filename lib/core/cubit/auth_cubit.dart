import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/services/auth_service.dart';
import 'package:tailorapp/core/models/customer_model.dart';

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
  final CustomerModel? customerProfile;

  const AuthAuthenticated({
    required this.user,
    this.customerProfile,
  });

  @override
  List<Object?> get props => [user, customerProfile];
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
      final customerProfile = await _authService.getCurrentCustomerProfile();
      emit(
        AuthAuthenticated(
          user: user,
          customerProfile: customerProfile,
        ),
      );
    } catch (e) {
      // Still emit authenticated state even if customer profile fails
      emit(AuthAuthenticated(user: user));
    }
  }

  // Authentication methods
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    emit(const AuthLoading());

    final result =
        await _authService.signInWithEmailAndPassword(email, password);

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

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    emit(const AuthLoading());

    final result = await _authService.createUserWithEmailAndPassword(
      email,
      password,
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

  // Password management
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      // Could emit a success state if needed
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to send password reset email: ${e.toString()}',
          type: AuthErrorType.unknown,
        ),
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
      // Password updated successfully
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to update password: ${e.toString()}',
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

  Future<void> updateCustomerProfile(CustomerModel customer) async {
    try {
      await _authService.updateCustomerProfile(customer);

      // Update the current state with new customer profile
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(
          AuthAuthenticated(
            user: currentState.user,
            customerProfile: customer,
          ),
        );
      }
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to update customer profile: ${e.toString()}',
          type: AuthErrorType.unknown,
        ),
      );
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

  CustomerModel? get currentCustomerProfile {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.customerProfile;
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
