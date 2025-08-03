import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/models/shared_models.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/models/user_model.dart';
import 'dart:io';

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final bool isEditing;

  const ProfileLoaded({
    required this.user,
    this.isEditing = false,
  });

  ProfileLoaded copyWith({
    UserModel? user,
    bool? isEditing,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [user, isEditing];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileUpdated extends ProfileState {
  final UserModel user;
  final String message;

  const ProfileUpdated({
    required this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

class ProfileImageUpdated extends ProfileState {
  final String imageUrl;
  final String message;

  const ProfileImageUpdated({
    required this.imageUrl,
    required this.message,
  });

  @override
  List<Object?> get props => [imageUrl, message];
}

class MeasurementsUpdated extends ProfileState {
  final BodyMeasurements measurements;
  final String message;

  const MeasurementsUpdated({
    required this.measurements,
    required this.message,
  });

  @override
  List<Object?> get props => [measurements, message];
}

class StylePreferencesUpdated extends ProfileState {
  final StylePreferences preferences;
  final String message;

  const StylePreferencesUpdated({
    required this.preferences,
    required this.message,
  });

  @override
  List<Object?> get props => [preferences, message];
}

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(const ProfileLoading());

    try {
      final user = await ServiceLocator.userRepository.getUser(userId);
      if (user != null) {
        emit(ProfileLoaded(user: user));
      } else {
        emit(const ProfileError(message: 'Profile not found'));
      }
    } catch (e) {
      emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  void startEditing() {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isEditing: true));
    }
  }

  void cancelEditing() {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isEditing: false));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    UserAddress? address,
  }) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(const ProfileLoading());

    try {
      final updatedUser = currentState.user.copyWith(
        name: name ?? currentState.user.name,
        email: email ?? currentState.user.email,
        phone: phone ?? currentState.user.phone,
        dateOfBirth: dateOfBirth ?? currentState.user.dateOfBirth,
        gender: gender ?? currentState.user.gender,
        address: address ?? currentState.user.address,
        updatedAt: DateTime.now(),
      );

      final savedUser =
          await ServiceLocator.userRepository.updateUser(updatedUser);

      emit(
        ProfileUpdated(
          user: savedUser,
          message: 'Profile updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(user: savedUser, isEditing: false));
    } catch (e) {
      emit(ProfileError(message: 'Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(const ProfileLoading());

    try {
      // Upload image to storage
      final imageUrl = await ServiceLocator.userRepository.uploadProfileImage(
        currentState.user.id,
        imageFile,
      );

      // Update customer with new image URL
      final updatedUser = currentState.user.copyWith(
        profileImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      final savedUser =
          await ServiceLocator.userRepository.updateUser(updatedUser);

      emit(
        ProfileImageUpdated(
          imageUrl: imageUrl,
          message: 'Profile image updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(user: savedUser));
    } catch (e) {
      emit(
        ProfileError(
          message: 'Failed to update profile image: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateMeasurements(BodyMeasurements measurements) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(const ProfileLoading());

    try {
      await ServiceLocator.userRepository.updateMeasurements(
        currentState.user.id,
        measurements,
      );

      final updatedUser = currentState.user.copyWith(
        customerData: currentState.user.customerData?.copyWith(
          measurements: measurements,
        ),
        updatedAt: DateTime.now(),
      );

      emit(
        MeasurementsUpdated(
          measurements: measurements,
          message: 'Measurements updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(user: updatedUser));
    } catch (e) {
      emit(
        ProfileError(
          message: 'Failed to update measurements: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateStylePreferences(StylePreferences preferences) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(const ProfileLoading());

    try {
      await ServiceLocator.userRepository.updateStylePreferences(
        currentState.user.id,
        preferences,
      );

      final updatedUser = currentState.user.copyWith(
        customerData: currentState.user.customerData?.copyWith(
          stylePreferences: preferences,
        ),
        updatedAt: DateTime.now(),
      );

      emit(
        StylePreferencesUpdated(
          preferences: preferences,
          message: 'Style preferences updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(user: updatedUser));
    } catch (e) {
      emit(
        ProfileError(
          message: 'Failed to update style preferences: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateAddress(UserAddress address) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(const ProfileLoading());

    try {
      final updatedUser = currentState.user.copyWith(
        address: address,
        updatedAt: DateTime.now(),
      );

      final savedUser =
          await ServiceLocator.userRepository.updateUser(updatedUser);

      emit(
        ProfileUpdated(
          user: savedUser,
          message: 'Address updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(user: savedUser));
    } catch (e) {
      emit(ProfileError(message: 'Failed to update address: ${e.toString()}'));
    }
  }

  Future<void> refreshProfile(String userId) async {
    // Refresh without showing loading state
    try {
      final user = await ServiceLocator.userRepository.getUser(userId);
      if (user != null) {
        if (state is ProfileLoaded) {
          final currentState = state as ProfileLoaded;
          emit(currentState.copyWith(user: user));
        } else {
          emit(ProfileLoaded(user: user));
        }
      }
    } catch (e) {
      emit(ProfileError(message: 'Failed to refresh profile: ${e.toString()}'));
    }
  }

  Future<void> verifyEmail(String email) async {
    if (state is! ProfileLoaded) return;

    try {
      await ServiceLocator.userRepository.sendEmailVerification(email);

      // In a real app, this would trigger an email verification flow
      // For now, we'll just show a success message
      emit(
        ProfileUpdated(
          user: UserModel.customer(
            id: '',
            name: '',
            email: email,
            phone: '',
          ),
          message: 'Verification email sent',
        ),
      );
    } catch (e) {
      emit(
        ProfileError(
          message: 'Failed to send verification email: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteAccount(String userId) async {
    emit(const ProfileLoading());

    try {
      await ServiceLocator.userRepository.deleteUser(userId);

      emit(
        ProfileUpdated(
          user: UserModel.customer(
            id: '',
            name: '',
            email: '',
            phone: '',
          ),
          message: 'Account deleted successfully',
        ),
      );
    } catch (e) {
      emit(ProfileError(message: 'Failed to delete account: ${e.toString()}'));
    }
  }

  void clearError() {
    if (state is ProfileError) {
      emit(const ProfileInitial());
    }
  }

  Future<void> exportData(String userId) async {
    if (state is! ProfileLoaded) return;

    try {
      // final exportData = await ServiceLocator.userRepository.exportCustomerData(userId);

      // In a real app, this would trigger a download or email with the data
      emit(
        ProfileUpdated(
          user: UserModel.customer(
            id: '',
            name: '',
            email: '',
            phone: '',
          ),
          message: 'Data export completed',
        ),
      );
    } catch (e) {
      emit(ProfileError(message: 'Failed to export data: ${e.toString()}'));
    }
  }
}
