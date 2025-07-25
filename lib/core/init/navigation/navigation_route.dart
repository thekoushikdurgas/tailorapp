import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorapp/view/_product/enum/route_enum.dart';

/// Navigation helper class with convenience methods for app navigation
class NavigationRoute {
  NavigationRoute._();

  /// Navigate to home page
  static void goHome(BuildContext context) {
    context.go(RouteEnum.homePage.rawValue);
  }

  /// Navigate to introduction/onboarding
  static void goIntro(BuildContext context) {
    context.go(RouteEnum.intro.rawValue);
  }

  /// Navigate to settings
  static void goSettings(BuildContext context) {
    context.go(RouteEnum.setting.rawValue);
  }

  /// Navigate to design canvas
  static void goDesignCanvas(BuildContext context) {
    context.go(RouteEnum.designCanvas.rawValue);
  }

  /// Navigate to virtual fitting room
  static void goVirtualFitting(BuildContext context) {
    context.go(RouteEnum.virtualFitting.rawValue);
  }

  /// Navigate to orders page
  static void goOrders(BuildContext context) {
    context.go(RouteEnum.orders.rawValue);
  }

  /// Navigate to profile page
  static void goProfile(BuildContext context) {
    context.go(RouteEnum.profile.rawValue);
  }

  /// Push to design canvas (keeps current page in history)
  static void pushDesignCanvas(BuildContext context) {
    context.push(RouteEnum.designCanvas.rawValue);
  }

  /// Push to virtual fitting (keeps current page in history)
  static void pushVirtualFitting(BuildContext context) {
    context.push(RouteEnum.virtualFitting.rawValue);
  }

  /// Push to orders page (keeps current page in history)
  static void pushOrders(BuildContext context) {
    context.push(RouteEnum.orders.rawValue);
  }

  /// Push to profile page (keeps current page in history)
  static void pushProfile(BuildContext context) {
    context.push(RouteEnum.profile.rawValue);
  }

  /// Navigate back to previous page
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // If there's nowhere to go back, go to home
      goHome(context);
    }
  }

  /// Navigate to a specific route by path
  static void goTo(BuildContext context, String route) {
    context.go(route);
  }

  /// Push to a specific route by path
  static void pushTo(BuildContext context, String route) {
    context.push(route);
  }

  /// Replace current route with new route
  static void replaceTo(BuildContext context, String route) {
    context.pushReplacement(route);
  }

  /// Check if we can go back
  static bool canGoBack(BuildContext context) {
    return context.canPop();
  }

  /// Get current route path
  static String getCurrentRoute(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    return router.routerDelegate.currentConfiguration.uri.path;
  }

  /// Navigate with parameters
  static void goWithParams(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) {
    final uri = Uri(path: route, queryParameters: params);
    context.go(uri.toString());
  }

  /// Push with parameters
  static void pushWithParams(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) {
    final uri = Uri(path: route, queryParameters: params);
    context.push(uri.toString());
  }

  /// Show modal route (for dialogs, bottom sheets, etc.)
  static Future<T?> showModal<T>(BuildContext context, Widget child) {
    return showDialog<T>(
      context: context,
      builder: (context) => child,
    );
  }

  /// Show bottom sheet
  static Future<T?> showBottomSheet<T>(BuildContext context, Widget child) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
    );
  }

  /// Clear all routes and go to specific route
  static void clearAndGoTo(BuildContext context, String route) {
    while (context.canPop()) {
      context.pop();
    }
    context.go(route);
  }

  /// Clear all routes and go to home
  static void clearAndGoHome(BuildContext context) {
    clearAndGoTo(context, RouteEnum.homePage.rawValue);
  }

  /// Navigate based on route enum
  static void goToRoute(BuildContext context, RouteEnum route) {
    context.go(route.rawValue);
  }

  /// Push based on route enum
  static void pushRoute(BuildContext context, RouteEnum route) {
    context.push(route.rawValue);
  }

  /// Quick navigation methods for common actions
  static void startNewDesign(BuildContext context) {
    pushDesignCanvas(context);
  }

  static void openVirtualFitting(BuildContext context) {
    pushVirtualFitting(context);
  }

  static void viewMyOrders(BuildContext context) {
    pushOrders(context);
  }

  static void openProfile(BuildContext context) {
    pushProfile(context);
  }

  static void openSettings(BuildContext context) {
    context.push(RouteEnum.setting.rawValue);
  }

  /// Logout and return to intro
  static void logout(BuildContext context) {
    clearAndGoTo(context, RouteEnum.intro.rawValue);
  }

  /// Error handling for navigation failures
  static void handleNavigationError(BuildContext context, Object error) {
    debugPrint('Navigation error: $error');

    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation error: ${error.toString()}'),
        backgroundColor: Colors.red[600],
        action: SnackBarAction(
          label: 'Home',
          textColor: Colors.white,
          onPressed: () => goHome(context),
        ),
      ),
    );

    // Try to go home as fallback
    try {
      goHome(context);
    } catch (e) {
      debugPrint('Failed to navigate to home: $e');
    }
  }

  /// Deep link handling
  static bool handleDeepLink(BuildContext context, String link) {
    try {
      final uri = Uri.parse(link);
      final path = uri.path;

      // Check if it's a valid route
      final validRoutes = RouteEnum.values.map((e) => e.rawValue);
      if (validRoutes.contains(path)) {
        context.go(path);
        return true;
      } else {
        // Invalid route, go to home
        goHome(context);
        return false;
      }
    } catch (e) {
      handleNavigationError(context, e);
      return false;
    }
  }

  /// Get route parameters
  static Map<String, String> getRouteParams(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    return state.uri.queryParameters;
  }

  /// Get path parameters
  static Map<String, String> getPathParams(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    return state.pathParameters;
  }
}
