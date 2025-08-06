import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tailorapp/core/theme/theme_manager.dart';
import 'package:tailorapp/view/splash/cubit/splash_cubit.dart';

/// Enhanced progress indicator widget for splash screen
///
/// **FEATURES:**
/// - Animated progress bar with moving circle
/// - Phase-based progress tracking
/// - Gradient styling with theme integration
/// - Shimmer effect during loading
/// - Smooth animations and transitions
class SplashProgressIndicator extends StatefulWidget {
  final double progress;
  final InitializationPhase? currentPhase;
  final bool isComplete;
  final Duration animationDuration;

  const SplashProgressIndicator({
    super.key,
    required this.progress,
    this.currentPhase,
    this.isComplete = false,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<SplashProgressIndicator> createState() =>
      _SplashProgressIndicatorState();
}

class _SplashProgressIndicatorState extends State<SplashProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _shimmerController;
  late Animation<double> _progressAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Progress animation controller
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Shimmer animation
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );

    // Start animations
    _progressController.forward();
    if (!widget.isComplete) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(SplashProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeInOutCubic,
        ),
      );

      _progressController.reset();
      _progressController.forward();
    }

    if (widget.isComplete && !oldWidget.isComplete) {
      _shimmerController.stop();
    } else if (!widget.isComplete && oldWidget.isComplete) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar with moving circle
        _buildProgressBar(context),

        SizedBox(height: 8.h),

        // Phase indicator (optional)
        if (widget.currentPhase != null) _buildPhaseIndicator(context),
      ],
    );
  }

  /// Build the main progress bar with moving circle
  Widget _buildProgressBar(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 6.h,
          decoration: BoxDecoration(
            gradient: ThemeManager.of(context).neutralGradient,
            borderRadius: BorderRadius.circular(3.r),
            boxShadow: ThemeManager.of(context).subtleShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final progressWidth =
                  constraints.maxWidth * _progressAnimation.value;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background shimmer (only when not complete)
                  if (!widget.isComplete)
                    _buildShimmerBackground(context, constraints),

                  // Progress fill
                  _buildProgressFill(context, progressWidth),

                  // Moving circle at the end of progress bar
                  if (_progressAnimation.value > 0.01)
                    _buildMovingCircle(context, progressWidth),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Build shimmer background effect
  Widget _buildShimmerBackground(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.r),
        child: Stack(
          children: [
            Positioned(
              left: _shimmerAnimation.value * constraints.maxWidth,
              child: Container(
                width: constraints.maxWidth * 0.3,
                height: 6.h,
                decoration: BoxDecoration(
                  gradient: ThemeManager.of(context).shimmerGradient,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the progress fill
  Widget _buildProgressFill(BuildContext context, double progressWidth) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: _progressAnimation.value,
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.isComplete
              ? ThemeManager.of(context).successGradient
              : ThemeManager.of(context).accent1Gradient,
          borderRadius: BorderRadius.circular(3.r),
        ),
      ),
    );
  }

  /// Build the moving circle at the progress end
  Widget _buildMovingCircle(BuildContext context, double progressWidth) {
    return Positioned(
      left: progressWidth - 8.w,
      top: -4.h,
      child: Container(
        width: 15.w,
        height: 15.h,
        decoration: BoxDecoration(
          gradient: widget.isComplete
              ? ThemeManager.of(context).successGradient
              : ThemeManager.of(context).primaryGradient,
          shape: BoxShape.circle,
          border: Border.all(
            color: ThemeManager.of(context).textPrimary,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isComplete
                  ? ThemeManager.of(context).successColor.withValues(alpha: 0.5)
                  : ThemeManager.of(context)
                      .primaryColor
                      .withValues(alpha: 0.5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: ThemeManager.of(context).textPrimary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  /// Build phase indicator text
  Widget _buildPhaseIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: ThemeManager.of(context).surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.isComplete
              ? ThemeManager.of(context).successColor.withValues(alpha: 0.3)
              : ThemeManager.of(context).primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.currentPhase?.description ?? 'Processing...',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: widget.isComplete
              ? ThemeManager.of(context).successColor
              : ThemeManager.of(context).primaryColor,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Simplified progress indicator for basic usage
class SplashSimpleProgress extends StatelessWidget {
  final double progress;
  final bool showPercentage;

  const SplashSimpleProgress({
    super.key,
    required this.progress,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SplashProgressIndicator(
          progress: progress,
          isComplete: progress >= 1.0,
        ),
        if (showPercentage) ...[
          SizedBox(height: 4.h),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: ThemeManager.of(context).textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
