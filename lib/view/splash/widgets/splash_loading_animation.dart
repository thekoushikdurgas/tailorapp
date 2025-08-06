import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:tailorapp/core/icons/prbal_icons.dart';
import 'package:tailorapp/core/theme/theme_manager.dart';

/// Reusable loading animation widget for splash screen
///
/// **FEATURES:**
/// - Lottie animation with error fallback
/// - Responsive sizing
/// - Theme-aware styling
/// - Customizable dimensions and animation path
class SplashLoadingAnimation extends StatelessWidget {
  final String animationPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool animate;
  final IconData? fallbackIcon;
  final Color? fallbackColor;

  const SplashLoadingAnimation({
    super.key,
    required this.animationPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.animate = true,
    this.fallbackIcon,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 80.w,
      height: height ?? 70.h,
      child: Lottie.asset(
        animationPath,
        fit: fit,
        repeat: repeat,
        animate: animate,
        frameRate: FrameRate.composition,
        options: LottieOptions(
          enableMergePaths: true,
        ),
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAnimation(context);
        },
      ),
    );
  }

  /// Build fallback animation when Lottie fails to load
  Widget _buildFallbackAnimation(BuildContext context) {
    return Container(
      width: width ?? 80.w,
      height: height ?? 80.h,
      decoration: BoxDecoration(
        gradient: ThemeManager.of(context).errorGradient,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Center(
        child: Icon(
          fallbackIcon ?? Prbal.business,
          size: 40.sp,
          color: fallbackColor ?? ThemeManager.of(context).textInverted,
        ),
      ),
    );
  }
}

/// Specialized loading animation for splash screen main content
class SplashMainAnimation extends StatelessWidget {
  const SplashMainAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashLoadingAnimation(
      animationPath: 'assets/animations/loading.json',
      width: null,
      height: 70,
      fallbackIcon: Prbal.rocket2,
    );
  }
}
