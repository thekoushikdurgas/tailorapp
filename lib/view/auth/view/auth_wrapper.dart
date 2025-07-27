import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/view/auth/view/auth_loading_screen.dart';
import 'package:tailorapp/view/auth/view/login_page.dart';
import 'package:tailorapp/view/home/view/home_page.dart';

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
          return const HomePage();
        } else {
          // AuthUnauthenticated or AuthError
          return const LoginPage();
        }
      },
    );
  }
}
