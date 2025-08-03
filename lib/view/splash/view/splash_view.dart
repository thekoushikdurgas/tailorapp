import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tailorapp/core/services/theme_manager.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/view/splash/cubit/splash_cubit.dart';
import 'package:tailorapp/view/splash/view-model/splash_view_model.dart';
import 'package:tailorapp/view/splash/widgets/splash_loading_animation.dart';
import 'package:tailorapp/view/splash/widgets/splash_progress_indicator.dart';
import 'package:tailorapp/view/splash/widgets/splash_loading_text.dart';
import 'package:tailorapp/view/splash/widgets/splash_footer.dart';
import 'package:tailorapp/product/lang/locale_keys.g.dart';

/// Refactored Splash Screen View with Cubit Architecture
///
/// **ARCHITECTURE:**
/// - Uses SplashCubit for state management
/// - Modular widget structure with reusable components
/// - Separation of concerns with view-model for business logic
/// - Enhanced error handling and user feedback
/// - Responsive design with theme integration
///
/// **COMPONENTS:**
/// - SplashLoadingAnimation: Handles Lottie animations
/// - SplashProgressIndicator: Enhanced progress tracking
/// - SplashLoadingText: Dynamic message display
/// - SplashFooter: Footer with branding and version info

// TODO: Add sound effects for splash animations
// TODO: Add biometric authentication check

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late SplashViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    DebugLogger.info(
      'SplashView: ====== INITIALIZING REFACTORED SPLASH SCREEN ======',
    );

    _initializeAnimations();
    _initializeViewModel();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _initializeViewModel() {
    _viewModel = SplashViewModel();
  }

  Future<void> _startInitialization() async {
    // Start animations
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();

    // Start splash initialization via cubit
    if (mounted) {
      context.read<SplashCubit>().initializeSplash();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: ThemeManager.of(context).backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the main content structure
  Widget _buildContent(BuildContext context) {
    return BlocConsumer<SplashCubit, SplashState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        return Column(
          children: [
            // Main content area
            Expanded(
              child: _buildMainContent(context, state),
            ),

            // Bottom section with progress and footer
            _buildBottomSection(context, state),
          ],
        );
      },
    );
  }

  /// Handle state changes and navigation
  void _handleStateChanges(BuildContext context, SplashState state) {
    if (state is SplashNavigationReady) {
      DebugLogger.navigation(
        'SplashView: Navigation ready, waiting for minimum duration...',
      );

      // Ensure minimum splash duration before navigation
      _handleNavigation(context);
    } else if (state is SplashError) {
      DebugLogger.error('SplashView: Error state received: ${state.message}');
      _showErrorDialog(context, state);
    }
  }

  /// Handle navigation after minimum duration
  Future<void> _handleNavigation(BuildContext context) async {
    await _viewModel.ensureMinimumSplashDuration();

    // Check if widget is still mounted before using context
    if (mounted) {
      if (context.mounted) {
        context.read<SplashCubit>().navigateToNextScreen(context);
      }
    }
  }

  /// Build the main content area
  Widget _buildMainContent(BuildContext context, SplashState state) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),

            // App branding section
            _buildBrandingSection(context),

            SizedBox(height: 40.h),

            // Loading animation
            const SplashMainAnimation(),

            SizedBox(height: 30.h),

            // Loading text with state-aware messaging
            SplashStateText(state: state),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// Build the branding section with app name
  Widget _buildBrandingSection(BuildContext context) {
    return Column(
      children: [
        // App name with gradient text effect
        ShaderMask(
          shaderCallback: (bounds) => ThemeManager.of(context).primaryGradient.createShader(bounds),
          child: Text(
            'Prbal',
            style: TextStyle(
              fontFamily: ThemeManager.fontFamilyPrimary,
              fontSize: 56.sp,
              color: ThemeManager.of(context).textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),

        SizedBox(height: 8.h),

        // App tagline
        Text(
          LocaleKeys.intro_appTagline.tr(),
          style: TextStyle(
            fontFamily: ThemeManager.fontFamilyPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: ThemeManager.of(context).textSecondary,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build the bottom section with progress and footer
  Widget _buildBottomSection(BuildContext context, SplashState state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        gradient: ThemeManager.of(context).surfaceGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: ThemeManager.of(context).elevatedShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          _buildProgressSection(context, state),

          SizedBox(height: 20.h),

          // Footer
          const SplashFooter(),
        ],
      ),
    );
  }

  /// Build the progress section based on current state
  Widget _buildProgressSection(BuildContext context, SplashState state) {
    if (state is SplashLoading) {
      return SplashProgressIndicator(
        progress: state.progress,
        currentPhase: state.phase,
        isComplete: state.phase == InitializationPhase.ready,
      );
    } else if (state is SplashNavigationReady) {
      return const SplashProgressIndicator(
        progress: 1.0,
        isComplete: true,
      );
    } else if (state is SplashError) {
      return _buildErrorSection(context, state);
    } else {
      return const SplashProgressIndicator(
        progress: 0.0,
      );
    }
  }

  /// Build error section with retry option
  Widget _buildErrorSection(BuildContext context, SplashError state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error indicator
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            gradient: ThemeManager.of(context).errorGradient.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: ThemeManager.of(context).errorColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 16.sp,
                color: ThemeManager.of(context).errorColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _viewModel.getErrorRecoveryMessage(state.message),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: ThemeManager.of(context).errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // Retry button (if retryable)
        if (state.canRetry) ...[
          SizedBox(height: 12.h),
          _buildRetryButton(context),
        ],
      ],
    );
  }

  /// Build retry button
  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<SplashCubit>().retryInitialization();
      },
      icon: Icon(
        Icons.refresh,
        size: 16.sp,
      ),
      label: Text(
        LocaleKeys.button_retry.tr(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeManager.of(context).primaryColor,
        foregroundColor: ThemeManager.of(context).textInverted,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  /// Show error dialog for critical errors
  void _showErrorDialog(BuildContext context, SplashError state) {
    if (!state.canRetry) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(LocaleKeys.error_critical.tr()),
          content: Text(state.message),
          actions: [
            TextButton(
              onPressed: () {
                context.read<SplashCubit>().performFallbackNavigation(context);
              },
              child: Text(LocaleKeys.button_continue.tr()),
            ),
          ],
        ),
      );
    }
  }
}

/// Wrapper widget that provides the SplashCubit
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(),
      child: const SplashView(),
    );
  }
}
