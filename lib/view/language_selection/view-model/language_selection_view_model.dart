import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:tailorapp/view/language_selection/model/language_selection_model.dart';

/// Language Selection View Model - Business Logic Layer
///
/// **RESPONSIBILITIES:**
/// - Navigation logic and flow control
/// - User interaction handling and validation
/// - Integration with system services (haptic feedback, etc.)
/// - Business rules enforcement
/// - Error handling and user feedback coordination
class LanguageSelectionViewModel {
  /// Navigate to the appropriate next screen based on app state
  ///
  /// **NAVIGATION LOGIC:**
  /// - Check authentication status
  /// - Determine appropriate next screen
  /// - Handle navigation errors gracefully
  Future<void> navigateToNextScreen(BuildContext context) async {
    DebugLogger.navigation(
      'LanguageSelectionViewModel: === NAVIGATION LOGIC ===',
    );

    try {
      // Check authentication status
      final isLoggedIn = HiveService.isLoggedIn();
      DebugLogger.navigation(
        'LanguageSelectionViewModel: User authenticated: $isLoggedIn',
      );

      // Check intro status
      final hasIntroBeenWatched = HiveService.isIntroWatched();
      DebugLogger.navigation(
        'LanguageSelectionViewModel: Intro watched: $hasIntroBeenWatched',
      );

      DebugLogger.navigation(
        'LanguageSelectionViewModel: Navigation decision:',
      );

      // Navigate based on app state
      if (!hasIntroBeenWatched) {
        // User hasn't seen intro → go to introduction
        DebugLogger.navigation(
          'LanguageSelectionViewModel: → Introduction Screen (intro needed)',
        );
        if (context.mounted) {
          context.go(RouteEnum.intro.rawValue);
        }
      } else if (!isLoggedIn) {
        // User not authenticated → go to home for auth
        DebugLogger.navigation(
          'LanguageSelectionViewModel: → Home Screen (authentication needed)',
        );
        if (context.mounted) {
          context.go(RouteEnum.homePage.rawValue);
        }
      } else {
        // User is authenticated → go to main dashboard
        DebugLogger.navigation(
          'LanguageSelectionViewModel: → Home Screen (authenticated user)',
        );
        if (context.mounted) {
          context.go(RouteEnum.homePage.rawValue);
        }
      }

      DebugLogger.success(
        'LanguageSelectionViewModel: Navigation completed successfully',
      );
    } catch (e, stackTrace) {
      DebugLogger.error(
        'LanguageSelectionViewModel: Navigation error: $e',
      );
      DebugLogger.debug(
        'LanguageSelectionViewModel: Stack trace: $stackTrace',
      );

      await _handleNavigationError(context, e);
    }

    DebugLogger.navigation(
      'LanguageSelectionViewModel: ===============================================',
    );
  }

  /// Handle navigation errors with fallback strategies
  Future<void> _handleNavigationError(
    BuildContext context,
    dynamic error,
  ) async {
    DebugLogger.navigation(
      'LanguageSelectionViewModel: Handling navigation error...',
    );

    try {
      // Fallback navigation strategies
      if (context.mounted) {
        // Try fallback to home screen
        DebugLogger.navigation(
          'LanguageSelectionViewModel: Fallback → Home Screen',
        );
        context.go(RouteEnum.homePage.rawValue);
      }
    } catch (fallbackError) {
      DebugLogger.error(
        'LanguageSelectionViewModel: Fallback navigation failed: $fallbackError',
      );

      // Ultimate fallback to intro
      try {
        if (context.mounted) {
          context.go(RouteEnum.intro.rawValue);
        }
      } catch (ultimateError) {
        DebugLogger.error(
          'LanguageSelectionViewModel: Ultimate fallback failed: $ultimateError',
        );
      }
    }
  }

  /// Provide haptic feedback for user interactions
  void provideHapticFeedback({bool isSuccess = false}) {
    try {
      if (isSuccess) {
        HapticFeedback.mediumImpact();
        DebugLogger.info(
          'LanguageSelectionViewModel: Success haptic feedback provided',
        );
      } else {
        HapticFeedback.lightImpact();
        DebugLogger.info(
          'LanguageSelectionViewModel: Light haptic feedback provided',
        );
      }
    } catch (e) {
      DebugLogger.error(
        'LanguageSelectionViewModel: Haptic feedback error: $e',
      );
    }
  }

  /// Validate language selection before applying
  bool validateLanguageSelection(LanguageItemModel? selectedLanguage) {
    if (selectedLanguage == null) {
      DebugLogger.warning(
        'LanguageSelectionViewModel: No language selected for validation',
      );
      return false;
    }

    DebugLogger.info(
      'LanguageSelectionViewModel: Validating language selection: ${selectedLanguage.displayName}',
    );

    // Add validation logic here if needed
    // For now, all selections are valid

    DebugLogger.success(
      'LanguageSelectionViewModel: Language selection validated',
    );
    return true;
  }

  /// Show success message to user
  void showSuccessMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(
            bottom: 100,
            left: 16,
            right: 16,
          ),
          duration: duration,
        ),
      );

      DebugLogger.info(
        'LanguageSelectionViewModel: Success message shown: $message',
      );
    } catch (e) {
      DebugLogger.error(
        'LanguageSelectionViewModel: Error showing success message: $e',
      );
    }
  }

  /// Show error message to user
  void showErrorMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(
            bottom: 100,
            left: 16,
            right: 16,
          ),
          duration: duration,
        ),
      );

      DebugLogger.error(
        'LanguageSelectionViewModel: Error message shown: $message',
      );
    } catch (e) {
      DebugLogger.error(
        'LanguageSelectionViewModel: Error showing error message: $e',
      );
    }
  }

  /// Handle skip action (set default language and continue)
  Future<void> handleSkipAction(BuildContext context) async {
    DebugLogger.intro(
      'LanguageSelectionViewModel: === HANDLING SKIP ACTION ===',
    );

    try {
      // Set English as default
      await HiveService.saveSelectedLanguage('en-US');
      DebugLogger.success(
        'LanguageSelectionViewModel: Default language (en-US) saved',
      );

      // Provide feedback
      provideHapticFeedback();

      // Navigate to next screen
      if (context.mounted) {
        await navigateToNextScreen(context);
      }
    } catch (e) {
      DebugLogger.error(
        'LanguageSelectionViewModel: Skip action failed: $e',
      );

      // Continue anyway - language can be set later
      if (context.mounted) {
        await navigateToNextScreen(context);
      }
    }
  }

  /// Get user-friendly error messages
  String getUserFriendlyErrorMessage(String errorMessage) {
    if (errorMessage.contains('storage') || errorMessage.contains('save')) {
      return 'Unable to save language preference. Please try again.';
    } else if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    } else if (errorMessage.contains('locale') ||
        errorMessage.contains('localization')) {
      return 'Language change failed. Please restart the app.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Calculate animation delays for staggered animations
  Duration getAnimationDelay(int index, {int itemsPerGroup = 3}) {
    return Duration(
        milliseconds: (index * 150) + (index ~/ itemsPerGroup * 100));
  }

  /// Check if device supports haptic feedback
  bool get isHapticFeedbackSupported {
    try {
      // This is a simple check - in a real app you might want more sophisticated detection
      return true; // Assume supported for now
    } catch (e) {
      DebugLogger.warning(
        'LanguageSelectionViewModel: Haptic feedback not supported: $e',
      );
      return false;
    }
  }

  /// Get performance metrics for the selection process
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Theme.of(
        NavigationService.navigatorKey.currentContext!,
      ).platform.name,
      'hapticSupported': isHapticFeedbackSupported,
    };
  }

  /// Cleanup resources if needed
  void dispose() {
    DebugLogger.info('LanguageSelectionViewModel: Disposing resources...');
    // Add cleanup logic if needed
  }
}

/// Navigation Service for global context access
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
