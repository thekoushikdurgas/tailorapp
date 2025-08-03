import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/view/auth/view/auth_loading_screen.dart';
import 'package:tailorapp/view/auth/view/welcome.dart';
import 'package:tailorapp/view/customer/view/customer_home_screen.dart';
import 'package:tailorapp/view/tailor/view/tailor_dashboard_screen.dart';
import 'package:tailorapp/view/admin/view/super_admin_dashboard_screen.dart';
import 'package:tailorapp/core/models/user_role.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Handle any side effects like showing snackbars for auth errors
        if (state is AuthError) {
          // Error is already handled in individual auth pages
          // We could add global error handling here if needed
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const AuthLoadingScreen();
        } else if (state is AuthAuthenticated) {
          // Route user to appropriate dashboard based on their role
          switch (state.userRole) {
            case UserRole.customer:
              return const CustomerHomeScreen();
            case UserRole.tailor:
              return const TailorDashboardScreen();
            case UserRole.admin:
              return const SuperAdminDashboardScreen();
          }
        } else {
          // AuthUnauthenticated or AuthError
          return const WelcomePage();
        }
      },
    );
  }
}
