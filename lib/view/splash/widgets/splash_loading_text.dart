import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tailorapp/core/services/theme_manager.dart';
import 'package:tailorapp/view/splash/cubit/splash_cubit.dart';
import 'package:tailorapp/product/lang/locale_keys.g.dart';

/// Loading text widget with enhanced typography and animations
///
/// **FEATURES:**
/// - Smooth text transitions with fade animations
/// - Phase-based message display
/// - Enhanced typography with theme integration
/// - Error state styling
/// - Customizable appearance
class SplashLoadingText extends StatefulWidget {
  final String message;
  final InitializationPhase? currentPhase;
  final bool isComplete;
  final bool hasError;
  final Duration animationDuration;

  const SplashLoadingText({
    super.key,
    required this.message,
    this.currentPhase,
    this.isComplete = false,
    this.hasError = false,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<SplashLoadingText> createState() => _SplashLoadingTextState();
}

class _SplashLoadingTextState extends State<SplashLoadingText>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  String _currentMessage = '';
  String _previousMessage = '';

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Fade animation controller
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Pulse animation controller for loading state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _fadeController.forward();
    if (!widget.isComplete && !widget.hasError) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SplashLoadingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.message != widget.message) {
      _updateMessage();
    }

    if (widget.isComplete && !oldWidget.isComplete) {
      _pulseController.stop();
      _pulseController.reset();
    } else if (widget.hasError && !oldWidget.hasError) {
      _pulseController.stop();
      _pulseController.reset();
    } else if (!widget.isComplete &&
        !widget.hasError &&
        (oldWidget.isComplete || oldWidget.hasError)) {
      _pulseController.repeat(reverse: true);
    }
  }

  Future<void> _updateMessage() async {
    _previousMessage = _currentMessage;

    // Fade out current message
    await _fadeController.reverse();

    // Update message
    _currentMessage = widget.message;

    // Fade in new message
    await _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isComplete || widget.hasError
              ? 1.0
              : _pulseAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildMessageContainer(context),
          ),
        );
      },
    );
  }

  /// Build the message container with styling
  Widget _buildMessageContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main loading message
          _buildMainMessage(context),

          // Phase indicator (if available)
          if (widget.currentPhase != null &&
              !widget.isComplete &&
              !widget.hasError)
            _buildPhaseIndicator(context),
        ],
      ),
    );
  }

  /// Build the main loading message
  Widget _buildMainMessage(BuildContext context) {
    Color textColor;
    if (widget.hasError) {
      textColor = ThemeManager.of(context).errorColor;
    } else if (widget.isComplete) {
      textColor = ThemeManager.of(context).successColor;
    } else {
      textColor = ThemeManager.of(context).warningColor;
    }

    return Text(
      _currentMessage,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: ThemeManager.fontFamilyPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.4,
        height: 1.2,
        shadows: [
          Shadow(
            color: ThemeManager.of(context).shadowLight,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  /// Build phase indicator
  Widget _buildPhaseIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        'phase.${widget.currentPhase?.name}'.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: ThemeManager.fontFamilyPrimary,
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          color: ThemeManager.of(context).textTertiary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Specialized loading text for different states
class SplashStateText extends StatelessWidget {
  final SplashState state;

  const SplashStateText({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state is SplashLoading) {
      final loadingState = state as SplashLoading;
      return SplashLoadingText(
        message: loadingState.message,
        currentPhase: loadingState.phase,
        isComplete: loadingState.phase == InitializationPhase.ready,
      );
    } else if (state is SplashError) {
      final errorState = state as SplashError;
      return SplashLoadingText(
        message: errorState.message,
        hasError: true,
      );
    } else if (state is SplashNavigationReady) {
      return SplashLoadingText(
        message: LocaleKeys.loading_ready.tr(),
        isComplete: true,
      );
    } else {
      return SplashLoadingText(
        message: LocaleKeys.loading_initializingApp.tr(),
      );
    }
  }
}

/// Simple loading message widget
class SplashSimpleMessage extends StatelessWidget {
  final String message;
  final Color? textColor;
  final double? fontSize;

  const SplashSimpleMessage({
    super.key,
    required this.message,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: ThemeManager.fontFamilyPrimary,
        fontSize: fontSize ?? 14.sp,
        fontWeight: FontWeight.w500,
        color: textColor ?? ThemeManager.of(context).textSecondary,
        letterSpacing: 0.4,
        height: 1.2,
      ),
    );
  }
}
