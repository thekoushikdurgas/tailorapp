import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/models/user_model.dart';

/// Model representing the current state of the application
/// Used to determine navigation flow after splash screen initialization
class AppStateModel extends Equatable {
  final bool isIntroWatched;
  final bool isLanguageSelected;
  final bool isLoggedIn;
  final UserModel? userData;
  final DateTime lastChecked;

  AppStateModel({
    required this.isIntroWatched,
    required this.isLanguageSelected,
    required this.isLoggedIn,
    this.userData,
    DateTime? lastChecked,
  }) : lastChecked = lastChecked ?? AlwaysEqualDateTime();

  @override
  List<Object?> get props => [
        isIntroWatched,
        isLanguageSelected,
        isLoggedIn,
        userData,
        // Don't include lastChecked in equality comparison
      ];

  /// Check if the user needs to complete onboarding
  bool get needsOnboarding => !isIntroWatched;

  /// Check if the user needs to select language
  bool get needsLanguageSelection => !isLanguageSelected;

  /// Check if the user needs authentication
  bool get needsAuthentication => !isLoggedIn;

  /// Check if the user can proceed directly to the main app
  bool get canProceedToApp =>
      isIntroWatched && isLanguageSelected && isLoggedIn;

  /// Get a user-friendly description of the current state
  String get stateDescription {
    if (needsOnboarding) {
      return 'New user - needs onboarding';
    } else if (needsLanguageSelection) {
      return 'Returning user - needs language selection';
    } else if (needsAuthentication) {
      return 'User - needs authentication';
    } else {
      return 'Authenticated user - ready to proceed';
    }
  }

  /// Create a copy of this model with updated values
  AppStateModel copyWith({
    bool? isIntroWatched,
    bool? isLanguageSelected,
    bool? isLoggedIn,
    UserModel? userData,
    DateTime? lastChecked,
  }) {
    return AppStateModel(
      isIntroWatched: isIntroWatched ?? this.isIntroWatched,
      isLanguageSelected: isLanguageSelected ?? this.isLanguageSelected,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userData: userData ?? this.userData,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  /// Convert to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'isIntroWatched': isIntroWatched,
      'isLanguageSelected': isLanguageSelected,
      'isLoggedIn': isLoggedIn,
      'userData': userData?.toJson(),
      'lastChecked': lastChecked.millisecondsSinceEpoch,
    };
  }

  /// Create from a map for deserialization
  factory AppStateModel.fromMap(Map<String, dynamic> map) {
    return AppStateModel(
      isIntroWatched: map['isIntroWatched'] ?? false,
      isLanguageSelected: map['isLanguageSelected'] ?? false,
      isLoggedIn: map['isLoggedIn'] ?? false,
      userData:
          map['userData'] != null ? UserModel.fromJson(map['userData']) : null,
      lastChecked: DateTime.fromMillisecondsSinceEpoch(
        map['lastChecked'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'AppStateModel('
        'isIntroWatched: $isIntroWatched, '
        'isLanguageSelected: $isLanguageSelected, '
        'isLoggedIn: $isLoggedIn, '
        'userData: ${userData?.name ?? 'null'}, '
        'stateDescription: $stateDescription'
        ')';
  }
}

/// Model for tracking initialization progress and status
class InitializationStatusModel extends Equatable {
  final bool isStorageHealthy;
  final bool isPerformanceSetup;
  final bool isAuthChecked;
  final bool isConnected;
  final bool hasErrors;
  final List<String> errorMessages;
  final DateTime startTime;
  final DateTime? endTime;

  InitializationStatusModel({
    this.isStorageHealthy = false,
    this.isPerformanceSetup = false,
    this.isAuthChecked = false,
    this.isConnected = false,
    this.hasErrors = false,
    this.errorMessages = const [],
    DateTime? startTime,
    this.endTime,
  }) : startTime = startTime ?? AlwaysEqualDateTime();

  @override
  List<Object?> get props => [
        isStorageHealthy,
        isPerformanceSetup,
        isAuthChecked,
        isConnected,
        hasErrors,
        errorMessages,
        // Don't include timestamps in equality
      ];

  /// Check if initialization is complete
  bool get isComplete =>
      isStorageHealthy && isPerformanceSetup && isAuthChecked && !hasErrors;

  /// Get initialization progress as a percentage
  double get progress {
    int completed = 0;
    const int total = 4; // Total number of required steps

    if (isStorageHealthy) completed++;
    if (isPerformanceSetup) completed++;
    if (isAuthChecked) completed++;
    if (isConnected) completed++;

    return completed / total;
  }

  /// Get duration of initialization
  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  /// Add an error message
  InitializationStatusModel addError(String error) {
    return copyWith(
      hasErrors: true,
      errorMessages: [...errorMessages, error],
    );
  }

  /// Create a copy with updated values
  InitializationStatusModel copyWith({
    bool? isStorageHealthy,
    bool? isPerformanceSetup,
    bool? isAuthChecked,
    bool? isConnected,
    bool? hasErrors,
    List<String>? errorMessages,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return InitializationStatusModel(
      isStorageHealthy: isStorageHealthy ?? this.isStorageHealthy,
      isPerformanceSetup: isPerformanceSetup ?? this.isPerformanceSetup,
      isAuthChecked: isAuthChecked ?? this.isAuthChecked,
      isConnected: isConnected ?? this.isConnected,
      hasErrors: hasErrors ?? this.hasErrors,
      errorMessages: errorMessages ?? this.errorMessages,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() {
    return 'InitializationStatusModel('
        'progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'isComplete: $isComplete, '
        'hasErrors: $hasErrors, '
        'duration: ${duration?.inMilliseconds ?? 0}ms'
        ')';
  }
}

/// Helper class for consistent DateTime comparison in Equatable
class AlwaysEqualDateTime extends DateTime {
  AlwaysEqualDateTime() : super(0);

  @override
  bool operator ==(Object other) => true;

  @override
  int get hashCode => 0;
}
