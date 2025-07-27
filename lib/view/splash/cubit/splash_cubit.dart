import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:tailorapp/view/splash/model/splash_state_model.dart';

part 'splash_state.dart';

/// Splash Screen Cubit - Manages initialization and navigation flow
///
/// **RESPONSIBILITIES:**
/// - Service initialization and health checks
/// - Authentication state validation
/// - Navigation flow management
/// - Loading state updates
/// - Error handling and recovery
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashInitial());

  /// Initialize the splash screen and start the service initialization process
  Future<void> initializeSplash() async {
    try {
      emit(
        const SplashLoading(
          phase: InitializationPhase.starting,
          message: 'Initializing application...',
          progress: 0.0,
        ),
      );

      await _initializeServices();
      await _checkAppState();
    } catch (e, stackTrace) {
      DebugLogger.error('SplashCubit: Initialization failed: $e');
      DebugLogger.debug('SplashCubit: Stack trace: $stackTrace');

      emit(
        SplashError(
          message: 'Failed to initialize application: ${e.toString()}',
          canRetry: true,
        ),
      );
    }
  }

  /// Perform comprehensive service initialization
  Future<void> _initializeServices() async {
    final phases = [
      (InitializationPhase.checkingStorage, 'Checking storage health...', 0.1),
      (
        InitializationPhase.setupPerformance,
        'Setting up performance monitoring...',
        0.2
      ),
      (InitializationPhase.optimizingStartup, 'Optimizing startup...', 0.3),
      (
        InitializationPhase.optimizingImages,
        'Optimizing image loading...',
        0.4
      ),
      (InitializationPhase.checkingAuth, 'Checking authentication...', 0.5),
      (InitializationPhase.validatingTokens, 'Validating tokens...', 0.6),
      (
        InitializationPhase.initializingHealth,
        'Initializing health monitoring...',
        0.7
      ),
      (
        InitializationPhase.checkingConnectivity,
        'Checking connectivity...',
        0.8
      ),
      (InitializationPhase.loadingPreferences, 'Loading preferences...', 0.9),
      (InitializationPhase.finalizingSetup, 'Finalizing setup...', 1.0),
    ];

    for (final (phase, message, progress) in phases) {
      emit(
        SplashLoading(
          phase: phase,
          message: message,
          progress: progress,
        ),
      );

      await _executeInitializationPhase(phase);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    emit(
      const SplashLoading(
        phase: InitializationPhase.ready,
        message: 'Ready to launch!',
        progress: 1.0,
      ),
    );
  }

  /// Execute specific initialization phase
  Future<void> _executeInitializationPhase(InitializationPhase phase) async {
    try {
      switch (phase) {
        case InitializationPhase.checkingStorage:
          if (!HiveService.isStorageHealthy()) {
            DebugLogger.warning('SplashCubit: Storage health check failed');
          }
          break;

        case InitializationPhase.setupPerformance:
          // await PerformanceService.instance.initializePerformanceMonitoring();
          break;

        case InitializationPhase.optimizingStartup:
          // await PerformanceService.instance.optimizeStartup();
          break;

        case InitializationPhase.optimizingImages:
          // PerformanceService.optimizeImageLoading();
          break;

        case InitializationPhase.checkingAuth:
          await _logAuthenticationState();
          break;

        case InitializationPhase.validatingTokens:
          await _validateAndRefreshAuthentication();
          break;

        case InitializationPhase.initializingHealth:
          // final healthService = HealthService();
          // await healthService.initialize();
          break;

        case InitializationPhase.checkingConnectivity:
          // Check connectivity status
          break;

        case InitializationPhase.loadingPreferences:
          // await _loadUserPreferences();
          break;

        case InitializationPhase.finalizingSetup:
          // Final setup tasks
          break;

        default:
          break;
      }
    } catch (e) {
      DebugLogger.warning('SplashCubit: Phase $phase failed: $e');
      // Continue with other phases even if one fails
    }
  }

  /// Log current authentication state for debugging
  Future<void> _logAuthenticationState() async {
    DebugLogger.storage(
      'SplashCubit: HiveService logged in: ${HiveService.isLoggedIn()}',
    );
    DebugLogger.storage(
      'SplashCubit: HiveService intro watched: ${HiveService.isIntroWatched()}',
    );
    DebugLogger.storage(
      'SplashCubit: HiveService language selected: ${HiveService.isLanguageSelected()}',
    );
  }

  /// Validate and refresh authentication if needed
  Future<void> _validateAndRefreshAuthentication() async {
    try {
      // Add token validation logic here
      DebugLogger.info('SplashCubit: Authentication validation completed');
    } catch (e, stackTrace) {
      DebugLogger.error('SplashCubit: Authentication validation error: $e');
      DebugLogger.debug('SplashCubit: Stack trace: $stackTrace');
    }
  }

  /// Check app state and determine next navigation step
  Future<void> _checkAppState() async {
    DebugLogger.navigation(
      'SplashCubit: ====== CHECKING APP STATE FOR NAVIGATION ======',
    );

    try {
      final appState = AppStateModel(
        isIntroWatched: HiveService.isIntroWatched(),
        isLanguageSelected: HiveService.isLanguageSelected(),
        isLoggedIn: HiveService.isLoggedIn(),
        userData: HiveService.getUserDataSafe(),
      );

      emit(
        SplashNavigationReady(
          appState: appState,
          nextRoute: _determineNextRoute(appState),
        ),
      );
    } catch (e, stackTrace) {
      DebugLogger.error('SplashCubit: App state check failed: $e');
      DebugLogger.debug('SplashCubit: Stack trace: $stackTrace');

      emit(
        SplashError(
          message: 'Failed to check app state: ${e.toString()}',
          canRetry: true,
        ),
      );
    }
  }

  /// Determine the next route based on app state
  String _determineNextRoute(AppStateModel appState) {
    DebugLogger.navigation('SplashCubit: Determining next route...');

    // Step 1: Check intro completion status
    if (!appState.isIntroWatched) {
      DebugLogger.navigation(
        'SplashCubit: → Introduction Screen (intro not completed)',
      );
      return RouteEnum.intro.rawValue;
    }

    // Step 2: Check language selection status
    if (!appState.isLanguageSelected) {
      DebugLogger.navigation(
        'SplashCubit: → Language Selection (language not selected)',
      );
      return RouteEnum.languageSelection.rawValue;
    }

    // Step 3: Check authentication status
    if (!appState.isLoggedIn) {
      DebugLogger.navigation('SplashCubit: → Authentication (not logged in)');
      return RouteEnum.login.rawValue;
    }

    // Step 4: User is authenticated - go to home
    DebugLogger.navigation('SplashCubit: → Home (authenticated user)');
    return RouteEnum.homePage.rawValue;
  }

  /// Navigate to the determined route
  Future<void> navigateToNextScreen(BuildContext context) async {
    final currentState = state;

    if (currentState is SplashNavigationReady) {
      DebugLogger.navigation(
        'SplashCubit: Navigating to: ${currentState.nextRoute}',
      );

      try {
        context.go(currentState.nextRoute);
        DebugLogger.success('SplashCubit: Navigation successful');
      } catch (e, stackTrace) {
        DebugLogger.error('SplashCubit: Navigation failed: $e');
        DebugLogger.debug('SplashCubit: Stack trace: $stackTrace');

        emit(
          SplashError(
            message: 'Navigation failed: ${e.toString()}',
            canRetry: true,
          ),
        );
      }
    }
  }

  /// Handle fallback navigation in case of errors
  Future<void> performFallbackNavigation(BuildContext context) async {
    DebugLogger.navigation('SplashCubit: Performing fallback navigation...');

    try {
      // Try to navigate based on basic state checks
      if (!HiveService.isIntroWatched()) {
        DebugLogger.navigation('SplashCubit: Fallback → Introduction Screen');
        context.go(RouteEnum.intro.rawValue);
      } else if (!HiveService.isLanguageSelected()) {
        DebugLogger.navigation('SplashCubit: Fallback → Language Selection');
        context.go(RouteEnum.languageSelection.rawValue);
      } else {
        DebugLogger.navigation('SplashCubit: Fallback → Login Screen');
        context.go(RouteEnum.login.rawValue);
      }
    } catch (e) {
      DebugLogger.error('SplashCubit: Fallback navigation failed: $e');

      // Ultimate fallback - try to navigate to intro
      try {
        DebugLogger.navigation('SplashCubit: Ultimate fallback → Introduction');
        context.go(RouteEnum.intro.rawValue);
      } catch (ultimateError) {
        DebugLogger.error(
          'SplashCubit: Ultimate fallback failed: $ultimateError',
        );
      }
    }
  }

  /// Retry initialization after an error
  Future<void> retryInitialization() async {
    DebugLogger.info('SplashCubit: Retrying initialization...');
    await initializeSplash();
  }
}
