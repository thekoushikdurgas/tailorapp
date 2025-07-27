import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:tailorapp/core/services/debug_logger.dart';

class RouteGuardService {
  static const Map<String, List<UserRole>> _routePermissions = {
    // Common routes - accessible by all authenticated users
    '/intro': [UserRole.customer, UserRole.tailor, UserRole.admin],
    '/setting': [UserRole.customer, UserRole.tailor, UserRole.admin],
    '/language-selection': [UserRole.customer, UserRole.tailor, UserRole.admin],
    '/support': [UserRole.customer, UserRole.tailor, UserRole.admin],
    '/notifications': [UserRole.customer, UserRole.tailor, UserRole.admin],

    // Customer-only routes
    '/customer/home': [UserRole.customer],
    '/customer/style-preference-setup': [UserRole.customer],
    '/customer/design-wishlist': [UserRole.customer],
    '/customer/virtual-wardrobe': [UserRole.customer],
    '/customer/size-profile-management': [UserRole.customer],
    '/customer/design-collaboration': [UserRole.customer],
    '/customer/fabric-selection': [UserRole.customer],
    '/customer/order-timeline': [UserRole.customer],
    '/customer/feedback-reviews': [UserRole.customer],
    '/customer/payment-history-billing': [UserRole.customer],
    '/customer/style-consultation-booking': [UserRole.customer],
    '/customer/loyalty-rewards': [UserRole.customer],

    // Tailor-only routes
    '/tailor/dashboard': [UserRole.tailor],
    '/tailor/order-management': [UserRole.tailor],
    '/tailor/pattern-creation-management': [UserRole.tailor],
    '/tailor/inventory-materials': [UserRole.tailor],
    '/tailor/production-planning': [UserRole.tailor],
    '/tailor/customer-communication-hub': [UserRole.tailor],
    '/tailor/quality-control-inspection': [UserRole.tailor],
    '/tailor/portfolio-profile': [UserRole.tailor],

    // Admin-only routes
    '/admin/dashboard': [UserRole.admin],
    '/admin/user-management-roles': [UserRole.admin],
    '/admin/platform-analytics-insights': [UserRole.admin],
    '/admin/content-campaign-management': [UserRole.admin],
    '/admin/system-configuration-settings': [UserRole.admin],

    // Legacy routes - accessible by customers for backward compatibility
    '/home': [UserRole.customer],
    '/design-canvas': [UserRole.customer],
    '/virtual-fitting': [UserRole.customer],
    '/ai-suggestions': [UserRole.customer],
    '/orders': [UserRole.customer],
    '/order-details': [UserRole.customer],
    '/profile': [UserRole.customer, UserRole.tailor, UserRole.admin],
    '/garment-customization': [UserRole.customer],
    '/measurements': [UserRole.customer],
    '/pattern-library': [UserRole.tailor],
  };

  /// Check if a user role has access to a specific route
  static bool hasAccess(String route, UserRole userRole) {
    final allowedRoles = _routePermissions[route];

    if (allowedRoles == null) {
      // If route is not defined in permissions, deny access
      DebugLogger.navigation(
        'Route $route not found in permissions, denying access',
      );
      return false;
    }

    final hasAccess = allowedRoles.contains(userRole);
    DebugLogger.navigation(
      'Route access check: $route for ${userRole.name} = ${hasAccess ? 'ALLOWED' : 'DENIED'}',
    );

    return hasAccess;
  }

  /// Get the appropriate home route for a user role
  static String getHomeRouteForRole(UserRole userRole) {
    return userRole.homeRoute;
  }

  /// Get the login redirect route based on current route and user role
  static String getRedirectRoute(String currentRoute, UserRole? userRole) {
    // If no user role, redirect to auth
    if (userRole == null) {
      return '/auth/login';
    }

    // If user has access to current route, no redirect needed
    if (hasAccess(currentRoute, userRole)) {
      return currentRoute;
    }

    // Redirect to role-specific home
    return getHomeRouteForRole(userRole);
  }

  /// Check if route requires authentication
  static bool requiresAuth(String route) {
    // Auth routes don't require authentication
    if (route.startsWith('/auth') ||
        route == '/intro' ||
        route == '/language-selection') {
      return false;
    }

    return true;
  }

  /// Get all allowed routes for a user role
  static List<String> getAllowedRoutesForRole(UserRole userRole) {
    return _routePermissions.entries
        .where((entry) => entry.value.contains(userRole))
        .map((entry) => entry.key)
        .toList();
  }

  /// Validate route access and provide redirect if needed
  static RouteGuardResult validateRouteAccess({
    required String route,
    required bool isAuthenticated,
    UserRole? userRole,
  }) {
    DebugLogger.navigation(
      'Validating route: $route, authenticated: $isAuthenticated, role: ${userRole?.name}',
    );

    // Check if route requires authentication
    if (requiresAuth(route) && !isAuthenticated) {
      return RouteGuardResult.redirect('/auth/login');
    }

    // If authenticated but no role, redirect to role selection or default
    if (isAuthenticated && userRole == null) {
      return RouteGuardResult.redirect('/customer/home'); // Default to customer
    }

    // If authenticated and has role, check access
    if (isAuthenticated && userRole != null) {
      if (hasAccess(route, userRole)) {
        return RouteGuardResult.allow();
      } else {
        // Redirect to role-specific home
        return RouteGuardResult.redirect(getHomeRouteForRole(userRole));
      }
    }

    // Allow access for non-authenticated routes
    return RouteGuardResult.allow();
  }

  /// Get route enum from path
  static RouteEnum? getRouteEnumFromPath(String path) {
    try {
      return RouteEnum.values.firstWhere(
        (route) => route.rawValue == path,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if route is role-specific
  static bool isRoleSpecificRoute(String route) {
    return route.startsWith('/customer') ||
        route.startsWith('/tailor') ||
        route.startsWith('/admin');
  }

  /// Get the role from route path
  static UserRole? getRoleFromRoute(String route) {
    if (route.startsWith('/customer')) return UserRole.customer;
    if (route.startsWith('/tailor')) return UserRole.tailor;
    if (route.startsWith('/admin')) return UserRole.admin;
    return null;
  }

  /// Handle navigation error with appropriate fallback
  static void handleNavigationError(
    BuildContext context,
    String attemptedRoute,
    UserRole? userRole,
  ) {
    DebugLogger.navigation(
      'Navigation error for route: $attemptedRoute, role: ${userRole?.name}',
    );

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Access denied to $attemptedRoute'),
        backgroundColor: Colors.red[600],
        action: SnackBarAction(
          label: 'Go Home',
          textColor: Colors.white,
          onPressed: () {
            final homeRoute = userRole != null
                ? getHomeRouteForRole(userRole)
                : '/auth/login';
            context.go(homeRoute);
          },
        ),
      ),
    );

    // Navigate to appropriate home
    final fallbackRoute =
        userRole != null ? getHomeRouteForRole(userRole) : '/auth/login';

    context.go(fallbackRoute);
  }
}

/// Result of route guard validation
class RouteGuardResult {
  final bool isAllowed;
  final String? redirectRoute;

  const RouteGuardResult._({
    required this.isAllowed,
    this.redirectRoute,
  });

  factory RouteGuardResult.allow() {
    return const RouteGuardResult._(isAllowed: true);
  }

  factory RouteGuardResult.redirect(String route) {
    return RouteGuardResult._(isAllowed: false, redirectRoute: route);
  }

  bool get shouldRedirect => !isAllowed && redirectRoute != null;
}

/// Extension to add role checking to RouteEnum
extension RouteEnumGuard on RouteEnum {
  bool hasAccessForRole(UserRole userRole) {
    return RouteGuardService.hasAccess(rawValue, userRole);
  }

  List<UserRole> get allowedRoles {
    return RouteGuardService._routePermissions[rawValue] ?? [];
  }

  bool get isRoleSpecific {
    return RouteGuardService.isRoleSpecificRoute(rawValue);
  }

  UserRole? get requiredRole {
    return RouteGuardService.getRoleFromRoute(rawValue);
  }
}
