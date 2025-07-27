part of 'splash_cubit.dart';

/// Base class for all splash screen states
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial state when splash screen is first loaded
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// Loading state during initialization with progress tracking
class SplashLoading extends SplashState {
  final InitializationPhase phase;
  final String message;
  final double progress;

  const SplashLoading({
    required this.phase,
    required this.message,
    required this.progress,
  });

  @override
  List<Object?> get props => [phase, message, progress];

  @override
  String toString() {
    return 'SplashLoading(phase: $phase, message: $message, progress: $progress)';
  }
}

/// State when initialization is complete and ready to navigate
class SplashNavigationReady extends SplashState {
  final AppStateModel appState;
  final String nextRoute;

  const SplashNavigationReady({
    required this.appState,
    required this.nextRoute,
  });

  @override
  List<Object?> get props => [appState, nextRoute];

  @override
  String toString() {
    return 'SplashNavigationReady(nextRoute: $nextRoute, appState: $appState)';
  }
}

/// Error state when initialization fails
class SplashError extends SplashState {
  final String message;
  final bool canRetry;

  const SplashError({
    required this.message,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, canRetry];

  @override
  String toString() {
    return 'SplashError(message: $message, canRetry: $canRetry)';
  }
}

/// Enumeration of initialization phases for progress tracking
enum InitializationPhase {
  starting('Starting initialization'),
  checkingStorage('Checking storage health'),
  setupPerformance('Setting up performance monitoring'),
  optimizingStartup('Optimizing startup'),
  optimizingImages('Optimizing image loading'),
  checkingAuth('Checking authentication'),
  validatingTokens('Validating tokens'),
  initializingHealth('Initializing health monitoring'),
  checkingConnectivity('Checking connectivity'),
  loadingPreferences('Loading preferences'),
  finalizingSetup('Finalizing setup'),
  ready('Ready to launch');

  const InitializationPhase(this.description);

  final String description;

  /// Get progress percentage for this phase (0.0 to 1.0)
  double get progressPercentage {
    switch (this) {
      case starting:
        return 0.0;
      case checkingStorage:
        return 0.1;
      case setupPerformance:
        return 0.2;
      case optimizingStartup:
        return 0.3;
      case optimizingImages:
        return 0.4;
      case checkingAuth:
        return 0.5;
      case validatingTokens:
        return 0.6;
      case initializingHealth:
        return 0.7;
      case checkingConnectivity:
        return 0.8;
      case loadingPreferences:
        return 0.9;
      case finalizingSetup:
        return 0.95;
      case ready:
        return 1.0;
    }
  }

  /// Check if this phase is complete
  bool get isComplete => this == ready;

  /// Get the next phase in the sequence
  InitializationPhase? get nextPhase {
    final currentIndex = InitializationPhase.values.indexOf(this);
    if (currentIndex < InitializationPhase.values.length - 1) {
      return InitializationPhase.values[currentIndex + 1];
    }
    return null;
  }
}
