import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/user_data_cubit.dart';
import 'package:tailorapp/core/services/route_guard_service.dart';
import 'package:tailorapp/view/admin/view/platform_analytics_insights_screen.dart';
import 'package:tailorapp/view/admin/view/super_admin_dashboard_screen.dart';
import 'package:tailorapp/view/admin/view/user_management_roles_screen.dart';
import 'package:tailorapp/view/ai_suggestions/view/ai_suggestions_page.dart';

//
import 'package:tailorapp/view/auth/view/welcome.dart';
import 'package:tailorapp/view/common/view/notifications_center_screen.dart';
import 'package:tailorapp/view/common/view/universal_support_screen.dart';
import 'package:tailorapp/view/customer/view/customer_home_screen.dart';
import 'package:tailorapp/view/customer/view/design_collaboration_hub_screen.dart';
import 'package:tailorapp/view/customer/view/design_wishlist_screen.dart';
import 'package:tailorapp/view/customer/view/fabric_selection_studio_screen.dart';
import 'package:tailorapp/view/customer/view/size_profile_management_screen.dart';
import 'package:tailorapp/view/customer/view/style_preference_setup_screen.dart';
import 'package:tailorapp/view/customer/view/virtual_wardrobe_screen.dart';
import 'package:tailorapp/view/design/view/design_canvas_page.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:tailorapp/view/fabric_library/view/fabric_library_page.dart';
import 'package:tailorapp/view/fitting/view/virtual_fitting_page.dart';
import 'package:tailorapp/view/garment_customization/view/garment_customization_page.dart';
import 'package:tailorapp/view/home/view/home_page.dart';
import 'package:tailorapp/view/introduction/view/introduction_screen.dart';
import 'package:tailorapp/view/language_selection/view/language_selection_screen.dart';
import 'package:tailorapp/view/measurements/view/measurements_page.dart';
import 'package:tailorapp/view/order_details/view/order_details_page.dart';
import 'package:tailorapp/view/orders/view/orders_page.dart';
import 'package:tailorapp/view/pattern_library/view/pattern_library_page.dart';
import 'package:tailorapp/view/profile/view/profile_page.dart';
import 'package:tailorapp/view/settings/view/setting_view.dart';
import 'package:tailorapp/view/tailor/tailor_dashboard_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorapp/view/tailor/view/customer_communication_hub_screen.dart';
import 'package:tailorapp/view/tailor/view/inventory_materials_screen.dart';
import 'package:tailorapp/view/tailor/view/order_management_screen.dart';
import 'package:tailorapp/view/tailor/view/pattern_creation_management_screen.dart';
import 'package:tailorapp/view/splash/view/splash_view.dart';

class NavigationRouters {
  const NavigationRouters._();

  static final GoRouter router = GoRouter(
    // Start with splash screen instead of bypassing it
    initialLocation: RouteEnum.splash.rawValue,
    redirect: (context, state) {
      final userDataState = context.read<UserDataCubit>().state;
      final isAuthenticated = userDataState is UserDataLoaded;
      final userRole = isAuthenticated ? userDataState.userRole : null;
      final currentPath = state.fullPath ?? '/';

      // Allow splash screen to always load first
      if (currentPath == RouteEnum.splash.rawValue) {
        return null; // No redirect needed for splash
      }

      // Use RouteGuardService to validate access for other routes
      final guardResult = RouteGuardService.validateRouteAccess(
        route: currentPath,
        isAuthenticated: isAuthenticated,
        userRole: userRole,
      );

      if (guardResult.shouldRedirect) {
        return guardResult.redirectRoute;
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash route - entry point for the app
      GoRoute(
        path: RouteEnum.splash.rawValue,
        builder: (context, state) => const SplashScreen(),
      ),

      // // Auth routes
      // GoRoute(
      //   path: RouteEnum.auth.rawValue,
      //   builder: (context, state) => const AuthWrapper(),
      // ),
      GoRoute(
        path: RouteEnum.welcome.rawValue,
        builder: (context, state) => const WelcomePage(),
      ),
      // GoRoute(
      //   path: RouteEnum.forgotPassword.rawValue,
      //   builder: (context, state) => const ForgotPasswordPage(),
      // ),

      // Language Selection route
      GoRoute(
        path: RouteEnum.languageSelection.rawValue,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),

      // Intro route
      GoRoute(
        path: RouteEnum.intro.rawValue,
        builder: (context, state) => const Introduction(),
      ),

      // Main app routes (require authentication)
      GoRoute(
        path: RouteEnum.homePage.rawValue,
        builder: (context, state) => const HomePage(),
      ),

      // Customer-specific routes
      GoRoute(
        path: RouteEnum.customerHome.rawValue,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: RouteEnum.stylePreferenceSetup.rawValue,
        builder: (context, state) => const StylePreferenceSetupScreen(),
      ),
      GoRoute(
        path: RouteEnum.designWishlist.rawValue,
        builder: (context, state) => const DesignWishlistScreen(),
      ),
      GoRoute(
        path: RouteEnum.virtualWardrobe.rawValue,
        builder: (context, state) => const VirtualWardrobeScreen(),
      ),
      GoRoute(
        path: RouteEnum.sizeProfileManagement.rawValue,
        builder: (context, state) => const SizeProfileManagementScreen(),
      ),
      GoRoute(
        path: RouteEnum.designCollaboration.rawValue,
        builder: (context, state) => const DesignCollaborationHubScreen(),
      ),
      GoRoute(
        path: RouteEnum.fabricSelection.rawValue,
        builder: (context, state) => const FabricSelectionStudioScreen(),
      ),

      // Tailor-specific routes
      GoRoute(
        path: RouteEnum.tailorDashboard.rawValue,
        builder: (context, state) => const TailorDashboardScreen(),
      ),
      GoRoute(
        path: RouteEnum.orderManagement.rawValue,
        builder: (context, state) => const OrderManagementScreen(),
      ),
      GoRoute(
        path: RouteEnum.customerCommunicationHub.rawValue,
        builder: (context, state) => const CustomerCommunicationHubScreen(),
      ),
      GoRoute(
        path: RouteEnum.patternCreationManagement.rawValue,
        builder: (context, state) => const PatternCreationManagementScreen(),
      ),
      GoRoute(
        path: RouteEnum.inventoryMaterials.rawValue,
        builder: (context, state) => const InventoryMaterialsScreen(),
      ),

      // Admin-specific routes
      GoRoute(
        path: RouteEnum.superAdminDashboard.rawValue,
        builder: (context, state) => const SuperAdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteEnum.userManagementRoles.rawValue,
        builder: (context, state) => const UserManagementRolesScreen(),
      ),
      GoRoute(
        path: RouteEnum.platformAnalyticsInsights.rawValue,
        builder: (context, state) => const PlatformAnalyticsInsightsScreen(),
      ),

      // Common routes (accessible by all roles)
      GoRoute(
        path: RouteEnum.universalSupport.rawValue,
        builder: (context, state) => const UniversalSupportScreen(),
      ),
      GoRoute(
        path: RouteEnum.notificationsCenter.rawValue,
        builder: (context, state) => const NotificationsCenterScreen(),
      ),
      GoRoute(
        path: RouteEnum.setting.rawValue,
        builder: (context, state) => const SettingView(),
      ),

      // AI Tailoring Features
      GoRoute(
        path: RouteEnum.designCanvas.rawValue,
        builder: (context, state) => const DesignCanvasPage(),
      ),
      GoRoute(
        path: RouteEnum.virtualFitting.rawValue,
        builder: (context, state) => const VirtualFittingPage(),
      ),
      GoRoute(
        path: RouteEnum.orders.rawValue,
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: RouteEnum.profile.rawValue,
        builder: (context, state) => const ProfilePage(),
      ),

      // Additional AI features routes
      GoRoute(
        path: RouteEnum.aiSuggestions.rawValue,
        builder: (context, state) => const AISuggestionsPage(),
      ),
      GoRoute(
        path: RouteEnum.orderDetails.rawValue,
        builder: (context, state) {
          final orderId = state.uri.queryParameters['id'] ?? '';
          return OrderDetailsPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteEnum.garmentCustomization.rawValue,
        builder: (context, state) => const GarmentCustomizationPage(),
      ),
      GoRoute(
        path: RouteEnum.measurements.rawValue,
        builder: (context, state) => const MeasurementsPage(),
      ),
      GoRoute(
        path: RouteEnum.fabricLibrary.rawValue,
        builder: (context, state) => const FabricLibraryPage(),
      ),
      GoRoute(
        path: RouteEnum.patternLibrary.rawValue,
        builder: (context, state) => const PatternLibraryPage(),
      ),
    ],
  );
}
