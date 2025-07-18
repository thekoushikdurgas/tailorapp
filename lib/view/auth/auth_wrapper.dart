import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/view/auth/login_page.dart';
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

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.content_cut,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 32),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ),
            const SizedBox(height: 24),

            // Loading text
            Text(
              'AI Tailoring',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading your experience...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
