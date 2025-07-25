import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/view/_product/enum/route_enum.dart';
import 'package:tailorapp/view/home/view/home_page.dart';
import 'package:tailorapp/view/introduction/view/introduction_screen.dart';
import 'package:tailorapp/view/settings/view/setting_view.dart';
import 'package:tailorapp/view/design/design_canvas_page.dart';
import 'package:tailorapp/view/virtual_fitting/virtual_fitting_page.dart';
import 'package:tailorapp/view/orders/orders_page.dart';
import 'package:tailorapp/view/profile/profile_page.dart';
import 'package:tailorapp/view/auth/login_page.dart';
import 'package:tailorapp/view/auth/register_page.dart';
import 'package:tailorapp/view/auth/forgot_password_page.dart';
import 'package:tailorapp/view/auth/auth_wrapper.dart';
import 'package:tailorapp/view/design/widgets/ai_suggestions_panel.dart';
import 'package:tailorapp/view/measurements/measurements_page.dart';
import 'package:tailorapp/view/language_selection/language_selection_screen.dart';
import 'package:go_router/go_router.dart';

class NavigationRouters {
  const NavigationRouters._();

  static final GoRouter router = GoRouter(
    initialLocation: HiveService.getInitialIntroRoute(),
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isGoingToAuth = state.fullPath?.startsWith('/auth') ?? false;
      final isGoingToIntro = state.fullPath?.startsWith('/intro') ?? false;
      final isGoingToLanguage =
          state.fullPath?.startsWith('/language-selection') ?? false;

      // Allow access to language selection without restrictions
      if (isGoingToLanguage) {
        return null;
      }

      // If not logged in and not going to auth, intro, or language selection, redirect to auth
      if (!isLoggedIn && !isGoingToAuth && !isGoingToIntro) {
        return '/auth/login';
      }

      // If logged in and going to auth, redirect to home
      if (isLoggedIn && isGoingToAuth) {
        return RouteEnum.homePage.rawValue;
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthWrapper(),
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterPage(),
          ),
          GoRoute(
            path: '/forgot-password',
            builder: (context, state) => const ForgotPasswordPage(),
          ),
        ],
      ),

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
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('AI Suggestions')),
          body: AISuggestionsPanel(
            garmentType: 'shirt',
            selectedColor: Colors.blue,
            selectedFabric: 'Cotton',
            onApplySuggestion: (suggestion) {
              // Handle suggestion application
              Navigator.of(context).pop();
            },
            isGenerating: false,
          ),
        ),
      ),
      GoRoute(
        path: RouteEnum.orderDetails.rawValue,
        builder: (context, state) {
          final orderId = state.uri.queryParameters['id'] ?? '';
          return Scaffold(
            appBar: AppBar(title: Text('Order Details - $orderId')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Order ID: $orderId'),
                  const SizedBox(height: 16),
                  const Text('Order details will be implemented here'),
                ],
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteEnum.garmentCustomization.rawValue,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Garment Customization')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Advanced customization options'),
                SizedBox(height: 8),
                Text('Coming soon...'),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteEnum.measurements.rawValue,
        builder: (context, state) => const MeasurementsPage(),
      ),
      GoRoute(
        path: RouteEnum.fabricSelection.rawValue,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Fabric Library')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.texture, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Fabric Selection'),
                SizedBox(height: 8),
                Text('Browse premium fabrics'),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteEnum.patternLibrary.rawValue,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Pattern Library')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pattern, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Pattern Collection'),
                SizedBox(height: 8),
                Text('Explore design patterns'),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
