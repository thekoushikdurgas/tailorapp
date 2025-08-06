import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/core/cubit/user_data_cubit.dart';
import 'package:tailorapp/core/models/user_model.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:tailorapp/view/splash/model/splash_state_model.dart';

part 'splash_state.dart';

/// Splash Screen Cubit - Manages initialization and navigation flow
///
/// **RESPONSIBILITIES:**
/// - Service initialization and health checks
/// - Authentication state validation and management
/// - Role-based navigation flow management
/// - Loading state updates
/// - Error handling and recovery
/// - Direct authentication without AuthWrapper
class SplashCubit extends Cubit<SplashState> {
  final UserDataCubit _userDataCubit;

  SplashCubit({required UserDataCubit userDataCubit})
      : _userDataCubit = userDataCubit,
        super(const SplashInitial());

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
      DebugLogger.auth('SplashCubit: Validating authentication state...');

      // Check if user data is loaded
      final currentUserDataState = _userDataCubit.state;

      if (currentUserDataState is UserDataLoaded) {
        DebugLogger.success('SplashCubit: User data is loaded');

        // User data is available - can proceed with navigation
      } else if (currentUserDataState is UserDataInitial) {
        DebugLogger.info('SplashCubit: User data not initialized');
      } else if (currentUserDataState is UserDataError) {
        DebugLogger.error(
          'SplashCubit: User data error: ${currentUserDataState.message}',
        );
      }

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
      // Check authentication state first
      emit(const SplashAuthLoading(message: 'Verifying authentication...'));
      await _checkAuthenticationState();

      final appState = AppStateModel(
        isIntroWatched: HiveService.isIntroWatched(),
        isLanguageSelected: HiveService.isLanguageSelected(),
        isLoggedIn: HiveService.isLoggedIn(),
        userData: HiveService.getUserDataSafe(),
      );

      // Get current user data state
      final userDataState = _userDataCubit.state;
      UserModel? userProfile;
      UserRole? userRole;

      if (userDataState is UserDataLoaded) {
        userProfile = userDataState.user;
        userRole = userDataState.userRole;

        emit(
          SplashAuthAuthenticated(
            userProfile: userProfile,
            userRole: userRole,
          ),
        );
      } else if (userDataState is UserDataError) {
        emit(
          SplashAuthError(
            message: 'User data loading failed: ${userDataState.message}',
            canRetry: true,
          ),
        );
        return;
      } else {
        emit(const SplashAuthUnauthenticated());
      }

      emit(
        SplashNavigationReady(
          appState: appState,
          nextRoute: _determineNextRoute(appState),
          userProfile: userProfile,
          userRole: userRole,
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

  /// Determine the next route based on app state and authentication
  String _determineNextRoute(AppStateModel appState) {
    DebugLogger.navigation('SplashCubit: Determining next route...');

    // Check user data state first
    final userDataState = _userDataCubit.state;

    if (userDataState is UserDataLoaded) {
      // User data is loaded - route to role-based home
      final homeRoute = userDataState.userRole.homeRoute;
      DebugLogger.navigation(
        'SplashCubit: → ${userDataState.userRole.name} Dashboard ($homeRoute)',
      );
      return homeRoute;
    }

    // User is not authenticated - check onboarding status

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

    // Step 3: User needs authentication
    DebugLogger.navigation(
      'SplashCubit: → Welcome Screen (authentication required)',
    );
    return RouteEnum.welcome.rawValue;
  }

  /// Navigate to the determined route
  Future<void> navigateToNextScreen(BuildContext context) async {
    final currentState = state;

    if (currentState is SplashNavigationReady) {
      final targetRoute = currentState.targetRoute;

      DebugLogger.navigation(
        'SplashCubit: Navigating to: $targetRoute (isAuthenticated: ${currentState.isAuthenticated})',
      );

      try {
        context.go(targetRoute);
        DebugLogger.success(
          'SplashCubit: Navigation successful to $targetRoute',
        );
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
      // Check user data state first
      final userDataState = _userDataCubit.state;

      if (userDataState is UserDataLoaded) {
        // User data is loaded, go to their home
        final homeRoute = userDataState.userRole.homeRoute;
        DebugLogger.navigation(
          'SplashCubit: Fallback → $homeRoute (user data loaded)',
        );
        context.go(homeRoute);
        return;
      }

      // Try to navigate based on basic state checks
      if (!HiveService.isIntroWatched()) {
        DebugLogger.navigation('SplashCubit: Fallback → Introduction Screen');
        context.go(RouteEnum.intro.rawValue);
      } else if (!HiveService.isLanguageSelected()) {
        DebugLogger.navigation('SplashCubit: Fallback → Language Selection');
        context.go(RouteEnum.languageSelection.rawValue);
      } else {
        DebugLogger.navigation('SplashCubit: Fallback → Welcome Screen');
        context.go(RouteEnum.welcome.rawValue);
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

  /// Check authentication state explicitly
  Future<void> _checkAuthenticationState() async {
    DebugLogger.auth('SplashCubit: Checking authentication state...');

    try {
      // Note: For now, we don't automatically reload user data
      // This would need to be implemented based on your app's user session management
      DebugLogger.info('SplashCubit: User data state check completed');

      // Wait a moment for state to update
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      DebugLogger.error('SplashCubit: User data state check failed: $e');
    }
  }

  /// Get current user data state
  UserDataState get userDataState => _userDataCubit.state;

  /// Check if user data is loaded
  bool get isUserDataLoaded => _userDataCubit.state is UserDataLoaded;

  /// Get current user profile if loaded
  UserModel? get currentUserProfile {
    final state = _userDataCubit.state;
    if (state is UserDataLoaded) {
      return state.user;
    }
    return null;
  }

  /// Retry initialization after an error
  Future<void> retryInitialization() async {
    DebugLogger.info('SplashCubit: Retrying initialization...');
    await initializeSplash();
  }
}
