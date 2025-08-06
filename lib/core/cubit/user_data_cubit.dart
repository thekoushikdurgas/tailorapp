import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/services/supabase_database_service.dart';
import 'package:tailorapp/core/models/user_model.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/core/services/debug_logger.dart';

// States
abstract class UserDataState extends Equatable {
  const UserDataState();

  @override
  List<Object?> get props => [];
}

class UserDataInitial extends UserDataState {
  const UserDataInitial();
}

class UserDataLoading extends UserDataState {
  const UserDataLoading();
}

class UserDataLoaded extends UserDataState {
  final UserModel user;

  const UserDataLoaded({
    required this.user,
  });

  @override
  List<Object?> get props => [user];

  UserRole get userRole => user.role;

  bool hasPermission(String permission) {
    return userRole.permissions.contains(permission);
  }

  String get homeRoute => userRole.homeRoute;
}

class UserDataError extends UserDataState {
  final String message;

  const UserDataError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserDataEmpty extends UserDataState {
  const UserDataEmpty();
}

// Events
abstract class UserDataEvent extends Equatable {
  const UserDataEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserData extends UserDataEvent {
  final String userId;

  const LoadUserData({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CreateUserData extends UserDataEvent {
  final UserModel user;

  const CreateUserData({required this.user});

  @override
  List<Object?> get props => [user];
}

class UpdateUserData extends UserDataEvent {
  final UserModel user;

  const UpdateUserData({required this.user});

  @override
  List<Object?> get props => [user];
}

class ClearUserData extends UserDataEvent {
  const ClearUserData();
}

class RefreshUserData extends UserDataEvent {
  final String userId;

  const RefreshUserData({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Cubit
class UserDataCubit extends Cubit<UserDataState> {
  final SupabaseDatabaseService _databaseService;
  StreamSubscription<List<Map<String, dynamic>>>? _userSubscription;
  String? _currentUserId;

  UserDataCubit({
    required SupabaseDatabaseService databaseService,
  })  : _databaseService = databaseService,
        super(const UserDataInitial());

  // ==========================================================================
  // PUBLIC METHODS
  // ==========================================================================

  /// Load user data by ID
  Future<void> loadUser(String? userId) async {
    if (userId == null) {
      emit(const UserDataEmpty());
      return;
    }

    if (state is UserDataLoading) return;

    emit(const UserDataLoading());
    _currentUserId = userId;

    try {
      final userData = await _databaseService.select(
        table: 'users',
        filters: {'id': userId},
        limit: 1,
      );

      if (userData.isEmpty) {
        emit(const UserDataEmpty());
        DebugLogger.warning('User not found with ID: $userId');
        return;
      }

      final user = UserModel.fromJson(userData.first);
      emit(UserDataLoaded(user: user));

      // Start real-time subscription for user updates
      _subscribeToUserUpdates(userId);

      DebugLogger.service('User data loaded successfully for: ${user.name}');
    } catch (e) {
      emit(UserDataError(message: 'Failed to load user data: $e'));
      DebugLogger.error('Failed to load user data: $e');
    }
  }

  /// Create new user
  Future<void> createUser(UserModel user) async {
    if (state is UserDataLoading) return;

    emit(const UserDataLoading());

    try {
      final userData = user.toJson();
      userData.remove('id'); // Let database generate ID
      userData['created_at'] = DateTime.now().toIso8601String();
      userData['updated_at'] = DateTime.now().toIso8601String();

      final createdUser = await _databaseService.insert(
        table: 'users',
        data: userData,
      );

      final newUser = UserModel.fromJson(createdUser);
      emit(UserDataLoaded(user: newUser));

      _currentUserId = newUser.id;
      _subscribeToUserUpdates(newUser.id);

      DebugLogger.service('User created successfully: ${newUser.name}');
    } catch (e) {
      emit(UserDataError(message: 'Failed to create user: $e'));
      DebugLogger.error('Failed to create user: $e');
    }
  }

  /// Update user data
  Future<void> updateUser(UserModel user) async {
    if (state is UserDataLoading) return;

    emit(const UserDataLoading());

    try {
      final userData = user.toJson();
      userData['updated_at'] = DateTime.now().toIso8601String();

      final updatedUser = await _databaseService.update(
        table: 'users',
        data: userData,
        filters: {'id': user.id},
      );

      final newUser = UserModel.fromJson(updatedUser);
      emit(UserDataLoaded(user: newUser));

      DebugLogger.service('User updated successfully: ${newUser.name}');
    } catch (e) {
      emit(UserDataError(message: 'Failed to update user: $e'));
      DebugLogger.error('Failed to update user: $e');
    }
  }

  /// Clear user data (logout equivalent)
  void clearUser() {
    _cancelSubscription();
    _currentUserId = null;
    emit(const UserDataEmpty());
    DebugLogger.service('User data cleared');
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    if (_currentUserId != null) {
      await loadUser(_currentUserId);
    }
  }

  /// Switch user role (for testing or admin purposes)
  Future<void> switchRole(UserRole newRole) async {
    final currentState = state;
    if (currentState is UserDataLoaded) {
      final updatedUser = currentState.user.copyWith(role: newRole);
      await updateUser(updatedUser);
    }
  }

  /// Update user profile information
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
  }) async {
    final currentState = state;
    if (currentState is UserDataLoaded) {
      final updatedUser = currentState.user.copyWith(
        name: name ?? currentState.user.name,
        email: email ?? currentState.user.email,
        phone: phone ?? currentState.user.phone,
        profileImageUrl: profileImageUrl ?? currentState.user.profileImageUrl,
      );
      await updateUser(updatedUser);
    }
  }

  /// Mark user as verified
  Future<void> verifyUser({
    bool? isVerified,
  }) async {
    final currentState = state;
    if (currentState is UserDataLoaded) {
      final updatedUser = currentState.user.copyWith(
        isVerified: isVerified ?? currentState.user.isVerified,
      );
      await updateUser(updatedUser);
    }
  }

  /// Complete onboarding (update metadata)
  Future<void> completeOnboarding() async {
    final currentState = state;
    if (currentState is UserDataLoaded) {
      final currentMetadata = currentState.user.metadata ?? {};
      final updatedMetadata = {
        ...currentMetadata,
        'onboarding_completed': true,
      };
      final updatedUser = currentState.user.copyWith(metadata: updatedMetadata);
      await updateUser(updatedUser);
    }
  }

  /// Activate/deactivate user
  Future<void> setUserActive(bool isActive) async {
    final currentState = state;
    if (currentState is UserDataLoaded) {
      final updatedUser = currentState.user.copyWith(isActive: isActive);
      await updateUser(updatedUser);
    }
  }

  // ==========================================================================
  // REAL-TIME FUNCTIONALITY
  // ==========================================================================

  /// Subscribe to real-time user updates
  void _subscribeToUserUpdates(String userId) {
    _cancelSubscription();

    try {
      _userSubscription = _databaseService.subscribeToTable(
        table: 'users',
        filters: {'id': userId},
      ).listen(
        (users) {
          if (users.isNotEmpty) {
            final user = UserModel.fromJson(users.first);
            emit(UserDataLoaded(user: user));
            DebugLogger.service('User data updated via real-time subscription');
          }
        },
        onError: (error) {
          DebugLogger.error('Real-time subscription error: $error');
          emit(UserDataError(message: 'Real-time update failed: $error'));
        },
      );
    } catch (e) {
      DebugLogger.error('Failed to setup real-time subscription: $e');
    }
  }

  /// Cancel real-time subscription
  void _cancelSubscription() {
    _userSubscription?.cancel();
    _userSubscription = null;
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Check if user is loaded
  bool get isUserLoaded => state is UserDataLoaded;

  /// Get current user (null if not loaded)
  UserModel? get currentUser {
    final currentState = state;
    if (currentState is UserDataLoaded) {
      return currentState.user;
    }
    return null;
  }

  /// Get current user role (null if not loaded)
  UserRole? get currentUserRole {
    final currentState = state;
    if (currentState is UserDataLoaded) {
      return currentState.userRole;
    }
    return null;
  }

  /// Check if current user has specific permission
  bool hasPermission(String permission) {
    final currentState = state;
    if (currentState is UserDataLoaded) {
      return currentState.hasPermission(permission);
    }
    return false;
  }

  /// Get home route for current user
  String? get homeRoute {
    final currentState = state;
    if (currentState is UserDataLoaded) {
      return currentState.homeRoute;
    }
    return null;
  }

  /// Get user display name
  String get displayName {
    final user = currentUser;
    if (user != null) {
      return user.name.isNotEmpty ? user.name : user.email;
    }
    return 'Unknown User';
  }

  /// Check if onboarding is completed
  bool get isOnboardingCompleted {
    final user = currentUser;
    return user?.metadata?['onboarding_completed'] ?? false;
  }

  /// Check if user is active
  bool get isUserActive {
    final user = currentUser;
    return user?.isActive ?? false;
  }

  /// Check if user is verified
  bool get isUserVerified {
    final user = currentUser;
    return user?.isVerified ?? false;
  }

  // ==========================================================================
  // SEARCH AND QUERY METHODS
  // ==========================================================================

  /// Search users by email
  Future<List<UserModel>> searchUsersByEmail(String email) async {
    try {
      final users = await _databaseService.select(
        table: 'users',
        filters: {'email': email},
      );

      return users.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      DebugLogger.error('Failed to search users by email: $e');
      return [];
    }
  }

  /// Search users by phone number
  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final users = await _databaseService.select(
        table: 'users',
        filters: {'phone': phone},
        limit: 1,
      );

      if (users.isEmpty) {
        return null;
      }

      return UserModel.fromJson(users.first);
    } catch (e) {
      DebugLogger.error('Failed to search user by phone: $e');
      return null;
    }
  }

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final users = await _databaseService.select(
        table: 'users',
        filters: {'role': role.toString().split('.').last},
        orderBy: 'created_at',
      );

      return users.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      DebugLogger.error('Failed to get users by role: $e');
      return [];
    }
  }

  /// Get all active users
  Future<List<UserModel>> getActiveUsers() async {
    try {
      final users = await _databaseService.select(
        table: 'users',
        filters: {'is_active': true},
        orderBy: 'created_at',
      );

      return users.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      DebugLogger.error('Failed to get active users: $e');
      return [];
    }
  }

  // ==========================================================================
  // CLEANUP
  // ==========================================================================

  @override
  Future<void> close() {
    _cancelSubscription();
    return super.close();
  }
}

// =============================================================================
// HELPER EXTENSIONS
// =============================================================================

extension UserDataStateExtensions on UserDataState {
  bool get isLoading => this is UserDataLoading;
  bool get isLoaded => this is UserDataLoaded;
  bool get hasError => this is UserDataError;
  bool get isEmpty => this is UserDataEmpty;
  bool get isInitial => this is UserDataInitial;

  UserModel? get user {
    if (this is UserDataLoaded) {
      return (this as UserDataLoaded).user;
    }
    return null;
  }

  String? get errorMessage {
    if (this is UserDataError) {
      return (this as UserDataError).message;
    }
    return null;
  }
}
