import 'package:flutter/material.dart';
import 'package:tailorapp/view/auth/widgets/phone_auth_modals.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo and Title - Compact Header
              _buildCompactHeader(),

              // Welcome Hero Section
              Expanded(
                flex: 2,
                child: _buildWelcomeHero(),
              ),

              // Features Section - More compact
              Expanded(
                flex: 1,
                child: _buildCompactFeaturesSection(),
              ),

              // Action Buttons
              _buildActionButtons(context),
              // const SizedBox(height: 8),

              // Sign Up Link
              // _buildSignUpLink(context),
              // const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[600]!, Colors.purple[600]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.content_cut,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Tailoring',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Crafting Perfect Fits with AI Precision',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeHero() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to the Future\nof Custom Tailoring',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Experience personalized fashion with AI-powered design tools, virtual fitting, and expert craftsmanship.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFeaturesSection() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactFeatureItem(
            icon: Icons.auto_awesome,
            title: 'AI-Powered Design',
            description: 'Smart suggestions for perfect fits and styles',
          ),
          const SizedBox(height: 12),
          _buildCompactFeatureItem(
            icon: Icons.view_in_ar,
            title: 'Virtual Fitting',
            description: 'Try before you order with AR technology',
          ),
          const SizedBox(height: 12),
          _buildCompactFeatureItem(
            icon: Icons.precision_manufacturing,
            title: 'Expert Craftsmanship',
            description: 'Professional tailors for premium quality',
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.blue[600],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Get Started Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showPhoneAuthModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Get Started to Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // const SizedBox(height: 10),

        // // Get Started Button (Secondary)
        // SizedBox(
        //   width: double.infinity,
        //   child: OutlinedButton(
        //     onPressed: () => _navigateToRegister(context),
        //     style: OutlinedButton.styleFrom(
        //       foregroundColor: Colors.blue[600],
        //       padding: const EdgeInsets.symmetric(vertical: 14),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       side: BorderSide(color: Colors.blue[600]!, width: 1.5),
        //     ),
        //     child: const Text(
        //       'Get Started Free',
        //       style: TextStyle(
        //         fontSize: 16,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  void _showPhoneAuthModal(BuildContext context) {
    PhoneAuthModals.showPhoneNumberModal(context);
  }
}
