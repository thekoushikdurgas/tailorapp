import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/models/customer_model.dart';
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
  final CustomerModel customer;
  final bool isEditing;

  const ProfileLoaded({
    required this.customer,
    this.isEditing = false,
  });

  ProfileLoaded copyWith({
    CustomerModel? customer,
    bool? isEditing,
  }) {
    return ProfileLoaded(
      customer: customer ?? this.customer,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [customer, isEditing];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileUpdated extends ProfileState {
  final CustomerModel customer;
  final String message;

  const ProfileUpdated({
    required this.customer,
    required this.message,
  });

  @override
  List<Object?> get props => [customer, message];
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
      final customer =
          await ServiceLocator.customerRepository.getCustomer(userId);
      if (customer != null) {
        emit(ProfileLoaded(customer: customer));
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
    CustomerAddress? address,
  }) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(const ProfileLoading());

    try {
      final updatedCustomer = currentState.customer.copyWith(
        name: name ?? currentState.customer.name,
        email: email ?? currentState.customer.email,
        phone: phone ?? currentState.customer.phone,
        dateOfBirth: dateOfBirth ?? currentState.customer.dateOfBirth,
        gender: gender ?? currentState.customer.gender,
        address: address ?? currentState.customer.address,
        updatedAt: DateTime.now(),
      );

      final savedCustomer = await ServiceLocator.customerRepository
          .updateCustomer(updatedCustomer);

      emit(
        ProfileUpdated(
          customer: savedCustomer,
          message: 'Profile updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(customer: savedCustomer, isEditing: false));
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
      final imageUrl =
          await ServiceLocator.customerRepository.uploadProfileImage(
        currentState.customer.id,
        imageFile,
      );

      // Update customer with new image URL
      final updatedCustomer = currentState.customer.copyWith(
        profileImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      final savedCustomer = await ServiceLocator.customerRepository
          .updateCustomer(updatedCustomer);

      emit(
        ProfileImageUpdated(
          imageUrl: imageUrl,
          message: 'Profile image updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(customer: savedCustomer));
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
      await ServiceLocator.customerRepository.updateMeasurements(
        currentState.customer.id,
        measurements,
      );

      final updatedCustomer = currentState.customer.copyWith(
        measurements: measurements,
        updatedAt: DateTime.now(),
      );

      emit(
        MeasurementsUpdated(
          measurements: measurements,
          message: 'Measurements updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(customer: updatedCustomer));
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
      await ServiceLocator.customerRepository.updateStylePreferences(
        currentState.customer.id,
        preferences,
      );

      final updatedCustomer = currentState.customer.copyWith(
        stylePreferences: preferences,
        updatedAt: DateTime.now(),
      );

      emit(
        StylePreferencesUpdated(
          preferences: preferences,
          message: 'Style preferences updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(customer: updatedCustomer));
    } catch (e) {
      emit(
        ProfileError(
          message: 'Failed to update style preferences: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateAddress(CustomerAddress address) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(const ProfileLoading());

    try {
      final updatedCustomer = currentState.customer.copyWith(
        address: address,
        updatedAt: DateTime.now(),
      );

      final savedCustomer = await ServiceLocator.customerRepository
          .updateCustomer(updatedCustomer);

      emit(
        ProfileUpdated(
          customer: savedCustomer,
          message: 'Address updated successfully',
        ),
      );

      // Return to loaded state
      emit(ProfileLoaded(customer: savedCustomer));
    } catch (e) {
      emit(ProfileError(message: 'Failed to update address: ${e.toString()}'));
    }
  }

  Future<void> refreshProfile(String userId) async {
    // Refresh without showing loading state
    try {
      final customer =
          await ServiceLocator.customerRepository.getCustomer(userId);
      if (customer != null) {
        if (state is ProfileLoaded) {
          final currentState = state as ProfileLoaded;
          emit(currentState.copyWith(customer: customer));
        } else {
          emit(ProfileLoaded(customer: customer));
        }
      }
    } catch (e) {
      emit(ProfileError(message: 'Failed to refresh profile: ${e.toString()}'));
    }
  }

  Future<void> verifyEmail(String email) async {
    if (state is! ProfileLoaded) return;

    try {
      await ServiceLocator.customerRepository.sendEmailVerification(email);

      // In a real app, this would trigger an email verification flow
      // For now, we'll just show a success message
      emit(
        ProfileUpdated(
          customer: CustomerModel(
            id: '',
            name: '',
            email: '',
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
      await ServiceLocator.customerRepository.deleteCustomer(userId);

      emit(
        ProfileUpdated(
          customer: CustomerModel(
            id: '',
            name: '',
            email: '',
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
      // final exportData = await ServiceLocator.customerRepository.exportCustomerData(userId);

      // In a real app, this would trigger a download or email with the data
      emit(
        ProfileUpdated(
          customer: CustomerModel(
            id: '',
            name: '',
            email: '',
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
          ),
          message: 'Data export completed',
        ),
      );
    } catch (e) {
      emit(ProfileError(message: 'Failed to export data: ${e.toString()}'));
    }
  }
}
