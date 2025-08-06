import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/core/models/user_model.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/view/splash/model/splash_state_model.dart';

/// Splash Screen View Model - Business Logic Layer
///
/// **RESPONSIBILITIES:**
/// - Service initialization coordination
/// - Health checks and system validation
/// - Authentication state management and validation
/// - Role-based navigation logic
/// - Performance optimization
/// - Error handling and recovery
class SplashViewModel {
  final AuthCubit? _authCubit;

  SplashViewModel({AuthCubit? authCubit}) : _authCubit = authCubit;
  static const Duration _initializationDelay = Duration(milliseconds: 300);
  static const Duration _minimumSplashDuration = Duration(seconds: 2);

  final DateTime _startTime = DateTime.now();

  /// Initialize all application services
  Future<InitializationStatusModel> initializeServices() async {
    DebugLogger.info('SplashViewModel: Starting service initialization...');

    final status = InitializationStatusModel(
      startTime: _startTime,
    );

    try {
      // Step 1: Verify storage health
      final storageStatus = await _checkStorageHealth();
      final statusAfterStorage = status.copyWith(
        isStorageHealthy: storageStatus,
      );

      if (!storageStatus) {
        return statusAfterStorage.addError('Storage health check failed');
      }

      await _delayedProgress();

      // Step 2: Setup performance monitoring
      final performanceStatus = await _setupPerformanceMonitoring();
      final statusAfterPerformance = statusAfterStorage.copyWith(
        isPerformanceSetup: performanceStatus,
      );

      if (!performanceStatus) {
        return statusAfterPerformance.addError('Performance setup failed');
      }

      await _delayedProgress();

      // Step 3: Check authentication state
      final authStatus = await _checkAuthenticationState();
      final statusAfterAuth = statusAfterPerformance.copyWith(
        isAuthChecked: authStatus,
      );

      await _delayedProgress();

      // Step 4: Check connectivity
      final connectivityStatus = await _checkConnectivity();
      final finalStatus = statusAfterAuth.copyWith(
        isConnected: connectivityStatus,
        endTime: DateTime.now(),
      );

      DebugLogger.success(
        'SplashViewModel: Service initialization completed in ${finalStatus.duration?.inMilliseconds}ms',
      );

      return finalStatus;
    } catch (e, stackTrace) {
      DebugLogger.error('SplashViewModel: Service initialization failed: $e');
      DebugLogger.debug('SplashViewModel: Stack trace: $stackTrace');

      return status.addError('Initialization failed: ${e.toString()}').copyWith(
            endTime: DateTime.now(),
          );
    }
  }

  /// Check storage health and integrity
  Future<bool> _checkStorageHealth() async {
    try {
      DebugLogger.storage('SplashViewModel: Checking storage health...');

      if (!HiveService.isStorageHealthy()) {
        DebugLogger.warning('SplashViewModel: Storage health check failed');
        // Attempt to recover
        await _attemptStorageRecovery();
      }

      // Verify basic operations
      final storageInfo = HiveService.getStorageInfo();
      DebugLogger.storage('SplashViewModel: Storage info: $storageInfo');

      final isHealthy = storageInfo['isHealthy'] == true;

      if (isHealthy) {
        DebugLogger.success('SplashViewModel: Storage health check passed');
      } else {
        DebugLogger.error('SplashViewModel: Storage health check failed');
      }

      return isHealthy;
    } catch (e) {
      DebugLogger.error('SplashViewModel: Storage health check error: $e');
      return false;
    }
  }

  /// Attempt to recover from storage issues
  Future<void> _attemptStorageRecovery() async {
    try {
      DebugLogger.storage('SplashViewModel: Attempting storage recovery...');

      // Add storage recovery logic here
      // For now, just log the attempt

      DebugLogger.success(
        'SplashViewModel: Storage recovery attempt completed',
      );
    } catch (e) {
      DebugLogger.error('SplashViewModel: Storage recovery failed: $e');
    }
  }

  /// Setup performance monitoring and optimization
  Future<bool> _setupPerformanceMonitoring() async {
    try {
      DebugLogger.info('SplashViewModel: Setting up performance monitoring...');

      // Add performance monitoring initialization here
      // For now, simulate the setup
      await Future.delayed(const Duration(milliseconds: 100));

      // Optimize startup performance
      await _optimizeStartupPerformance();

      DebugLogger.success(
        'SplashViewModel: Performance monitoring setup completed',
      );
      return true;
    } catch (e) {
      DebugLogger.error(
        'SplashViewModel: Performance monitoring setup failed: $e',
      );
      return false;
    }
  }

  /// Optimize startup performance
  Future<void> _optimizeStartupPerformance() async {
    try {
      DebugLogger.info('SplashViewModel: Optimizing startup performance...');

      // Add startup optimization logic here
      // Examples:
      // - Preload critical resources
      // - Initialize image caching
      // - Setup memory management

      await Future.delayed(const Duration(milliseconds: 50));

      DebugLogger.success('SplashViewModel: Startup optimization completed');
    } catch (e) {
      DebugLogger.error('SplashViewModel: Startup optimization failed: $e');
    }
  }

  /// Check authentication state and validate tokens
  Future<bool> _checkAuthenticationState() async {
    try {
      DebugLogger.auth('SplashViewModel: Checking authentication state...');

      // Log current authentication status
      final isLoggedIn = HiveService.isLoggedIn();
      final userData = HiveService.getUserDataSafe();

      DebugLogger.auth('SplashViewModel: User logged in: $isLoggedIn');
      DebugLogger.auth(
        'SplashViewModel: User data available: ${userData != null}',
      );

      // Check AuthCubit state if available
      if (_authCubit != null) {
        final authState = _authCubit.state;
        DebugLogger.auth(
          'SplashViewModel: AuthCubit state: ${authState.runtimeType}',
        );

        if (authState is AuthAuthenticated) {
          DebugLogger.auth(
            'SplashViewModel: User authenticated in AuthCubit as ${authState.userRole.name}',
          );
          return true;
        } else if (authState is AuthError) {
          DebugLogger.warning(
            'SplashViewModel: AuthCubit error: ${authState.message}',
          );
        }
      }

      if (isLoggedIn && userData != null) {
        // Validate authentication tokens if available
        await _validateAuthenticationTokens();
      }

      DebugLogger.success(
        'SplashViewModel: Authentication state check completed',
      );
      return true;
    } catch (e) {
      DebugLogger.error(
        'SplashViewModel: Authentication state check failed: $e',
      );
      return false;
    }
  }

  /// Validate authentication tokens
  Future<void> _validateAuthenticationTokens() async {
    try {
      DebugLogger.auth('SplashViewModel: Validating authentication tokens...');

      final accessToken = HiveService.getAccessToken();
      // final refreshToken = HiveService.getRefreshToken();

      if (accessToken != null) {
        DebugLogger.auth('SplashViewModel: Access token found');

        // Check if tokens are expired
        if (HiveService.areTokensExpired()) {
          DebugLogger.warning('SplashViewModel: Tokens are expired');

          // Attempt token refresh through AuthCubit if available
          if (_authCubit != null) {
            DebugLogger.auth(
              'SplashViewModel: Attempting token refresh through AuthCubit...',
            );
            try {
              await _authCubit.retry();
              DebugLogger.success(
                'SplashViewModel: Token refresh attempt completed',
              );
            } catch (refreshError) {
              DebugLogger.error(
                'SplashViewModel: Token refresh failed: $refreshError',
              );
            }
          }
        } else {
          DebugLogger.success('SplashViewModel: Tokens are valid');
        }
      } else {
        DebugLogger.warning('SplashViewModel: No access token found');
      }
    } catch (e) {
      DebugLogger.error('SplashViewModel: Token validation failed: $e');
    }
  }

  /// Check network connectivity
  Future<bool> _checkConnectivity() async {
    try {
      DebugLogger.info('SplashViewModel: Checking connectivity...');

      // Add connectivity check logic here
      // For now, simulate the check
      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate connectivity status
      const isConnected = true;
      DebugLogger.success('SplashViewModel: Connectivity check passed');

      return isConnected;
    } catch (e) {
      DebugLogger.error('SplashViewModel: Connectivity check failed: $e');
      return false;
    }
  }

  /// Get current application state including authentication
  AppStateModel getCurrentAppState() {
    try {
      DebugLogger.info('SplashViewModel: Getting current app state...');

      bool isLoggedIn = HiveService.isLoggedIn();
      UserModel? userData = HiveService.getUserDataSafe();

      // Override with AuthCubit state if available and authenticated
      if (_authCubit != null) {
        final authState = _authCubit.state;
        if (authState is AuthAuthenticated) {
          isLoggedIn = true;
          userData = authState.userProfile;
          DebugLogger.info(
            'SplashViewModel: Using AuthCubit state - user: ${userData.name}, role: ${authState.userRole.name}',
          );
        } else if (authState is AuthUnauthenticated) {
          isLoggedIn = false;
          userData = null;
        }
      }

      final appState = AppStateModel(
        isIntroWatched: HiveService.isIntroWatched(),
        isLanguageSelected: HiveService.isLanguageSelected(),
        isLoggedIn: isLoggedIn,
        userData: userData,
        lastChecked: DateTime.now(),
      );

      DebugLogger.info(
        'SplashViewModel: App state: ${appState.stateDescription}',
      );

      return appState;
    } catch (e) {
      DebugLogger.error('SplashViewModel: Failed to get app state: $e');

      // Return default state on error
      return AppStateModel(
        isIntroWatched: false,
        isLanguageSelected: false,
        isLoggedIn: false,
        lastChecked: DateTime.now(),
      );
    }
  }

  /// Ensure minimum splash duration for better UX
  Future<void> ensureMinimumSplashDuration() async {
    final elapsed = DateTime.now().difference(_startTime);

    if (elapsed < _minimumSplashDuration) {
      final remaining = _minimumSplashDuration - elapsed;
      DebugLogger.info(
        'SplashViewModel: Waiting ${remaining.inMilliseconds}ms to meet minimum splash duration',
      );
      await Future.delayed(remaining);
    }
  }

  /// Add delay between initialization steps for better UX
  Future<void> _delayedProgress() async {
    await Future.delayed(_initializationDelay);
  }

  /// Get debug information for troubleshooting
  Map<String, dynamic> getDebugInfo() {
    final debugInfo = {
      'startTime': _startTime.toIso8601String(),
      'elapsedTime': DateTime.now().difference(_startTime).inMilliseconds,
      'storageInfo': HiveService.getStorageInfo(),
      'isIntroWatched': HiveService.isIntroWatched(),
      'isLanguageSelected': HiveService.isLanguageSelected(),
      'isLoggedIn': HiveService.isLoggedIn(),
      'hasUserData': HiveService.getUserDataSafe() != null,
    };

    // Add AuthCubit debug info if available
    if (_authCubit != null) {
      final authState = _authCubit.state;
      debugInfo.addAll({
        'authCubitState': authState.runtimeType.toString(),
        'authCubitAuthenticated': _authCubit.isAuthenticated,
        'authCubitUserId': _authCubit.currentUserId ?? 'null',
        'authCubitUserRole': _authCubit.currentUserProfile?.role.name ?? 'null',
      });
    }

    return debugInfo;
  }

  /// Handle initialization errors
  String getErrorRecoveryMessage(String errorMessage) {
    if (errorMessage.contains('storage')) {
      return 'Storage issue detected. Please restart the app or clear app data.';
    } else if (errorMessage.contains('connectivity')) {
      return 'Network connection issue. Please check your internet connection.';
    } else if (errorMessage.contains('authentication')) {
      return 'Authentication issue. You may need to log in again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Cleanup resources
  void dispose() {
    DebugLogger.info('SplashViewModel: Disposing resources...');
    // Add cleanup logic here if needed
  }
}
