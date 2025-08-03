import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tailorapp/core/icons/prbal_icons.dart';
import 'package:tailorapp/core/mixins/theme_aware_mixin.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/core/services/theme_manager.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:tailorapp/product/lang/locale_keys.g.dart';

/// ====================================================================
/// TAILOR APP INTRODUCTION SCREEN - 6 STEPS FLOW
/// ====================================================================
///
/// ✅ **UPDATED FOR TAILOR APP BUSINESS FLOW** ✅
///
/// **🎯 TAILOR APP 6-STEP INTRODUCTION FLOW:**
///
/// **1. BODY MEASUREMENTS** (@body_measurement.json)
/// - Get precise body measurements using AI technology
/// - Perfect fit guarantee with phone-based measurement capture
///
/// **2. AI DESIGN STUDIO** (@design_studio.json)
/// - Create custom garments with intelligent design assistant
/// - AI-powered design suggestions and style recommendations
///
/// **3. VIRTUAL FITTING** (@virtually_fitting.json)
/// - Try designs virtually with AR technology
/// - See exact fit and appearance before ordering
///
/// **4. DESIGN MARKETPLACE** (@design_marketing.json)
/// - Sell your designs to customers worldwide
/// - Turn creativity into income through marketplace
///
/// **5. EXPERT TAILOR ASSIGNMENT** (@hard_working_tailor.json)
/// - Verified master tailors craft your designs
/// - Professional matching and quality craftsmanship
///
/// **6. DOORSTEP DELIVERY** (@warehouse_delivery.json)
/// - Skip fashion stores entirely
/// - Direct delivery with premium packaging and quality guarantee
///
/// **🔐 ENHANCED FEATURES:**
/// - Complete navigation logic with authentication integration
/// - Comprehensive theming with ThemeManager
/// - Advanced animations and transitions
/// - Proper state management and error handling
/// - Multi-language support via easy_localization
/// ====================================================================

class IntroductionScreen extends ConsumerStatefulWidget {
  const IntroductionScreen({super.key});

  @override
  ConsumerState<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends ConsumerState<IntroductionScreen>
    with TickerProviderStateMixin, ThemeAwareMixin {
  // ========== ANIMATION CONTROLLERS ==========
  late PageController pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  int currentPage = 0;
  bool _isInitialized = false;
  bool _isCompletingIntro = false; // Track intro completion state
  bool _disposed = false; // Track disposal state

  // Cache theme values to avoid accessing context during animations
  LinearGradient? _cachedGradient;
  Color? _cachedContrastingColor;

  @override
  void initState() {
    super.initState();
    DebugLogger.intro(
      'IntroductionScreen: ====== INITIALIZING TAILOR APP INTRO (6 STEPS) ======',
    );
    pageController = PageController();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // _logComprehensiveThemeInitialization();
      // _logAuthenticationState();
      _isInitialized = true;
    }
  }

  // /// Logs comprehensive initialization with ALL theme information
  // void _logComprehensiveThemeInitialization() {
  //   // Comprehensive theme logging
  //   ThemeManager.of(context).logGradientInfo();
  //   ThemeManager.of(context).logAllColors();
  // }

  // /// Logs current authentication state for debugging
  // void _logAuthenticationState() {
  //   final authState = ref.read(authenticationStateProvider);
  //   DebugLogger.auth('IntroductionScreen: Authentication state check:');
  //   DebugLogger.auth(
  //       'IntroductionScreen:   - Authenticated: ${authState.isAuthenticated}');
  //   DebugLogger.auth('IntroductionScreen:   - Loading: ${authState.isLoading}');
  //   DebugLogger.auth(
  //       'IntroductionScreen:   - User: ${authState.user?.username ?? 'none'}');
  //   DebugLogger.auth(
  //       'IntroductionScreen:   - User Type: ${authState.user?.userType.name ?? 'none'}');
  //   DebugLogger.auth(
  //       'IntroductionScreen:   - Has Tokens: ${authState.tokens != null}');
  //   DebugLogger.auth(
  //       'IntroductionScreen:   - Error: ${authState.error ?? 'none'}');
  // }

  /// Gets tailor app specific 6-page onboarding flow using ThemeManager
  List<OnboardingPage> _getEnhancedPages(BuildContext context) {
    return [
      // 1. BODY MEASUREMENTS
      OnboardingPage(
        title: LocaleKeys.intro_onboarding_page1_title.tr(),
        subtitle: LocaleKeys.intro_onboarding_page1_subtitle.tr(),
        animationPath: 'assets/intro/body_measurement.json',
        color: ThemeManager.of(context).primaryColor,
        gradientColors: [
          ThemeManager.of(context).primaryColor,
          ThemeManager.of(context).primaryLight,
          ThemeManager.of(context).accent1,
        ],
        icon: Prbal.clock, // Consider using a measurement-related icon
        statusType: 'primary',
        scale: 1.2,
        translateX: 10.0,
        translateY: 20.0,
      ),
      // 2. AI DESIGN STUDIO
      OnboardingPage(
        title: LocaleKeys.intro_onboarding_page2_title.tr(),
        subtitle: LocaleKeys.intro_onboarding_page2_subtitle.tr(),
        animationPath: 'assets/intro/design_studio.json',
        color: ThemeManager.of(context).successColor,
        gradientColors: [
          ThemeManager.of(context).successColor,
          ThemeManager.of(context).successLight,
          ThemeManager.of(context).accent3,
        ],
        icon: Prbal.palette, // Design/creative icon
        statusType: 'success',
        scale: 1.1,
        translateX: 15.0,
        translateY: 10.0,
      ),
      // 3. VIRTUAL FITTING
      OnboardingPage(
        title: LocaleKeys.intro_onboarding_page3_title.tr(),
        subtitle: LocaleKeys.intro_onboarding_page3_subtitle.tr(),
        animationPath: 'assets/intro/virtually_fitting.json',
        color: ThemeManager.of(context).infoColor,
        gradientColors: [
          ThemeManager.of(context).infoColor,
          ThemeManager.of(context).infoLight,
          ThemeManager.of(context).accent5,
        ],
        icon: Prbal.graduationCap1, // Consider VR/AR related icon
        statusType: 'info',
        scale: 1.3,
        translateX: 20.0,
        translateY: 15.0,
      ),
      // 4. DESIGN MARKETPLACE/SELLING
      OnboardingPage(
        title: LocaleKeys.intro_onboarding_page4_title.tr(),
        subtitle: LocaleKeys.intro_onboarding_page4_subtitle.tr(),
        animationPath: 'assets/intro/design_marketing.json',
        color: ThemeManager.of(context).warningColor,
        gradientColors: [
          ThemeManager.of(context).warningColor,
          ThemeManager.of(context).warningLight,
          ThemeManager.of(context).accent4,
        ],
        icon: Prbal.laptop11, // Consider marketplace/money icon
        statusType: 'warning',
        scale: 1.0,
        translateX: 12.0,
        translateY: 25.0,
      ),
      // 5. EXPERT TAILOR ASSIGNMENT
      OnboardingPage(
        title: LocaleKeys.intro_onboarding_page5_title.tr(),
        subtitle: LocaleKeys.intro_onboarding_page5_subtitle.tr(),
        animationPath: 'assets/intro/hard_working_tailor.json',
        color: ThemeManager.of(context).errorColor,
        gradientColors: [
          ThemeManager.of(context).errorColor,
          ThemeManager.of(context).errorLight,
          ThemeManager.of(context).accent2,
        ],
        icon: Prbal.hand, // Craftsmanship/work icon
        statusType: 'error',
        scale: 1.4,
        translateX: 8.0,
        translateY: 30.0,
      ),
      // 6. DOORSTEP DELIVERY
      OnboardingPage(
        title: LocaleKeys.intro_onboarding_page6_title.tr(),
        subtitle: LocaleKeys.intro_onboarding_page6_subtitle.tr(),
        animationPath: 'assets/intro/warehouse_delivery.json',
        color: ThemeManager.of(context).accent2,
        gradientColors: [
          ThemeManager.of(context).accent2,
          ThemeManager.of(context).primaryColor,
          ThemeManager.of(context).accent1,
        ],
        icon: Prbal.heart, // Consider delivery/package icon
        statusType: 'accent',
        scale: 1.1,
        translateX: 18.0,
        translateY: 12.0,
      ),
    ];
  }

  /// Gets comprehensive page gradient using ThemeManager gradient system
  LinearGradient _getPageGradient(
    OnboardingPage page,
  ) {
    // Safety check: Don't access context if widget is disposed
    if (_disposed || !mounted) {
      return _cachedGradient ??
          const LinearGradient(colors: [Colors.blue, Colors.blueAccent]);
    }

    LinearGradient gradient;
    switch (page.statusType) {
      case 'primary':
        gradient = ThemeManager.of(context).primaryGradient;
        break;
      case 'success':
        gradient = ThemeManager.of(context).successGradient;
        break;
      case 'info':
        gradient = ThemeManager.of(context).infoGradient;
        break;
      case 'warning':
        gradient = ThemeManager.of(context).warningGradient;
        break;
      case 'error':
        gradient = ThemeManager.of(context).errorGradient;
        break;
      case 'accent':
        gradient = ThemeManager.of(context).accent2Gradient;
        break;
      case 'secondary':
        gradient = ThemeManager.of(context).secondaryGradient;
        break;
      case 'verified':
        gradient = ThemeManager.of(context).accent3Gradient;
        break;
      default:
        gradient = ThemeManager.of(context).primaryGradient;
        break;
    }

    // Cache the gradient for future use
    _cachedGradient = gradient;
    return gradient;
  }

  /// Gets contrasting color with safety checks
  Color _getContrastingColor(Color baseColor) {
    // Safety check: Don't access context if widget is disposed
    if (_disposed || !mounted) {
      return _cachedContrastingColor ?? Colors.white;
    }

    final color = ThemeManager.of(context).getContrastingColor(baseColor);
    _cachedContrastingColor = color;
    return color;
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutBack,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _glowController.repeat(reverse: true);
  }

  void _restartAnimations() {
    _slideController.reset();
    _slideController.forward();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    DebugLogger.intro(
      'IntroductionScreen: Disposing and stopping animations...',
    );

    // Mark as disposed to prevent context access
    _disposed = true;

    // Stop all animations before disposing
    _fadeController.stop();
    _slideController.stop();
    _glowController.stop();

    // Dispose controllers
    pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _glowController.dispose();

    // Clear cached values
    _cachedGradient = null;
    _cachedContrastingColor = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.of(context).backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Main content with vertical PageView
              Column(
                children: [
                  _buildEnhancedVerticalPageView(),
                  _buildEnhancedBottomNavigation(),
                ],
              ),

              // Enhanced right-side components
              _buildEnhancedSkipIndicator(),
              _buildEnhancedRightSideIndicators(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedVerticalPageView() {
    final pages = _getEnhancedPages(context);

    return Expanded(
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
          _restartAnimations();
        },
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return SlideTransition(
            position: _slideAnimation,
            child: _buildEnhancedPageContent(pages[index]),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedSkipIndicator() {
    final pages = _getEnhancedPages(context);
    final currentPageData = pages[currentPage];

    return Positioned(
      right: 16.w,
      top: 0,
      bottom: 0,
      child: Column(
        children: [
          if (currentPage < pages.length - 1)
            Column(
              children: [
                SizedBox(height: 6.h),
                GestureDetector(
                  onTap: _skipOnboarding,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      gradient: ThemeManager.of(context).conditionalGradient(
                        lightGradient: LinearGradient(
                          colors: [
                            ThemeManager.of(context).surfaceElevated,
                            ThemeManager.of(context).cardBackground,
                            ThemeManager.of(context).modalBackground,
                          ],
                        ),
                        darkGradient: LinearGradient(
                          colors: [
                            ThemeManager.of(context).surfaceElevated,
                            ThemeManager.of(context).backgroundSecondary,
                            ThemeManager.of(context).cardBackground,
                          ],
                        ),
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: ThemeManager.of(context).conditionalColor(
                          lightColor:
                              currentPageData.color.withValues(alpha: 0.3),
                          darkColor:
                              currentPageData.color.withValues(alpha: 0.4),
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      LocaleKeys.button_skip.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: currentPageData.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRightSideIndicators() {
    final pages = _getEnhancedPages(context);
    final currentPageData = pages[currentPage];

    return Positioned(
      right: 16.w,
      bottom: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced current page indicator with glass morphism
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  // Safety check: Don't build if widget is disposed or not mounted
                  if (_disposed || !mounted) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      gradient: _getPageGradient(currentPageData),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: _getContrastingColor(currentPageData.color)
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${currentPage + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: _getContrastingColor(currentPageData.color),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 16.h),

              // Enhanced vertical page indicators with comprehensive theming
              ...List.generate(pages.length, (index) {
                final pageData = pages[index];
                final isActive = currentPage == index;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: isActive ? 10.w : 6.w,
                      height: isActive ? 32.h : 12.h,
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? _getPageGradient(pageData)
                            : LinearGradient(
                                colors: [
                                  ThemeManager.of(context).textTertiary,
                                  ThemeManager.of(context).textQuaternary,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(6.r),
                        border: isActive
                            ? Border.all(
                                color: pageData.color.withValues(alpha: 0.3),
                                width: 1,
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(height: 16.h),

              // Enhanced swipe hint with glass morphism
              if (currentPage < pages.length - 1)
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    // Safety check: Don't build if widget is disposed or not mounted
                    if (_disposed || !mounted) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            currentPageData.color
                                .withValues(alpha: 0.2 * _glowAnimation.value),
                            currentPageData.color
                                .withValues(alpha: 0.1 * _glowAnimation.value),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: currentPageData.color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Prbal.arrowDown,
                        size: 14.sp,
                        color: currentPageData.color,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedPageContent(
    OnboardingPage page,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 60.w,
            top: 8.h,
            bottom: 8.h,
          ),
          child: Column(
            children: [
              // Enhanced Animation Container with comprehensive theming
              Expanded(
                flex: 3,
                child: _buildEnhancedIllustration(page),
              ),

              SizedBox(height: 20.h),

              // Enhanced Content with comprehensive typography
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight * 0.25,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Enhanced feature badge with comprehensive theming
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            gradient:
                                ThemeManager.of(context).conditionalGradient(
                              lightGradient: LinearGradient(
                                colors: [
                                  page.color.withValues(alpha: 0.15),
                                  page.gradientColors[1].withValues(alpha: 0.1),
                                  page.gradientColors[2]
                                      .withValues(alpha: 0.05),
                                ],
                              ),
                              darkGradient: LinearGradient(
                                colors: [
                                  page.color.withValues(alpha: 0.2),
                                  page.gradientColors[1]
                                      .withValues(alpha: 0.15),
                                  page.gradientColors[2].withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: ThemeManager.of(context).conditionalColor(
                                lightColor: page.color.withValues(alpha: 0.3),
                                darkColor: page.color.withValues(alpha: 0.4),
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: page.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  page.icon,
                                  size: 14.sp,
                                  color: page.color,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '${LocaleKeys.intro_feature.tr()} ${currentPage + 1}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: page.color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Enhanced title with comprehensive typography
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            page.title,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: ThemeManager.of(context).textPrimary,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Enhanced subtitle with comprehensive theming
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            page.subtitle,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: ThemeManager.of(context).textSecondary,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedIllustration(
    OnboardingPage page,
  ) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Lottie animation with enhanced container, different transform scales, and translations
          Container(
            padding: EdgeInsets.all(16.w),
            child: Transform.translate(
              offset: Offset(page.translateX, page.translateY),
              child: Transform.scale(
                scale: page.scale,
                child: Lottie.asset(
                  page.animationPath,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBottomNavigation() {
    final pages = _getEnhancedPages(context);
    final currentPageData = pages[currentPage];

    return Container(
      margin: EdgeInsets.only(
        left: 20.w,
        right: 60.w,
        bottom: 20.h,
        top: 8.h,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: ThemeManager.of(context).conditionalGradient(
          lightGradient: LinearGradient(
            colors: [
              ThemeManager.of(context).surfaceElevated,
              ThemeManager.of(context).cardBackground,
              ThemeManager.of(context).modalBackground.withValues(alpha: 0.9),
            ],
          ),
          darkGradient: LinearGradient(
            colors: [
              ThemeManager.of(context).surfaceElevated,
              ThemeManager.of(context).backgroundSecondary,
              ThemeManager.of(context).cardBackground,
            ],
          ),
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: ThemeManager.of(context).conditionalColor(
            lightColor:
                ThemeManager.of(context).borderColor.withValues(alpha: 0.3),
            darkColor:
                ThemeManager.of(context).borderSecondary.withValues(alpha: 0.4),
          ),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Enhanced Previous button
          if (currentPage > 0)
            Expanded(
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  gradient: ThemeManager.of(context).conditionalGradient(
                    lightGradient: LinearGradient(
                      colors: [
                        ThemeManager.of(context).neutral100,
                        ThemeManager.of(context).neutral200,
                        ThemeManager.of(context).surfaceElevated,
                      ],
                    ),
                    darkGradient: LinearGradient(
                      colors: [
                        ThemeManager.of(context).neutral700,
                        ThemeManager.of(context).neutral600,
                        ThemeManager.of(context).surfaceElevated,
                      ],
                    ),
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: ThemeManager.of(context).conditionalColor(
                      lightColor: currentPageData.color.withValues(alpha: 0.3),
                      darkColor: currentPageData.color.withValues(alpha: 0.4),
                    ),
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handlePrevious,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Prbal.arrowUp,
                            size: 18.sp,
                            color: currentPageData.color,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              LocaleKeys.intro_previous.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: currentPageData.color,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (currentPage > 0) SizedBox(width: 16.w),

          // Enhanced Next/Get Started button
          Expanded(
            flex: currentPage == 0 ? 1 : 1,
            child: Container(
              height: 52.h,
              decoration: BoxDecoration(
                gradient: _getPageGradient(currentPageData),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: ThemeManager.of(context)
                      .getContrastingColor(currentPageData.color)
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleNext,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            currentPage == pages.length - 1
                                ? LocaleKeys.intro_getStarted.tr()
                                : LocaleKeys.button_next.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: ThemeManager.of(context)
                                  .getContrastingColor(currentPageData.color),
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          currentPage == pages.length - 1
                              ? Prbal.rocket2
                              : Prbal.arrowDown,
                          size: 18.sp,
                          color: ThemeManager.of(context)
                              .getContrastingColor(currentPageData.color),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _skipOnboarding() {
    final pages = _getEnhancedPages(context);
    HapticFeedback.mediumImpact();

    pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handlePrevious() {
    if (currentPage > 0) {
      HapticFeedback.lightImpact();
      pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleNext() {
    final pages = _getEnhancedPages(context);

    if (currentPage < pages.length - 1) {
      HapticFeedback.lightImpact();
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      HapticFeedback.heavyImpact();
      _handleGetStarted(context);
    }
  }

  /// Enhanced intro completion with direct navigation flow for tailor app
  ///
  /// **PROCESS:**
  /// 1. Mark intro as watched in HiveService for persistence
  /// 2. Check language selection status → Navigate to language selection if needed
  /// 3. Check authentication status → Navigate to welcome screen if not authenticated
  /// 4. Navigate to appropriate dashboard based on user type
  /// 5. Provide proper error handling and user feedback
  ///
  /// **NAVIGATION FLOW:**
  /// - Mark intro as watched
  /// - Check language selection → Language Selection Screen
  /// - Check authentication → Welcome Screen
  /// - Navigate to user-specific dashboard (Admin/Provider/Customer)
  Future<void> _handleGetStarted(BuildContext context) async {
    if (_isCompletingIntro) {
      DebugLogger.intro(
        'IntroductionScreen: Intro completion already in progress, ignoring...',
      );
      return;
    }

    DebugLogger.intro(
      'IntroductionScreen: ====== COMPLETING TAILOR APP INTRODUCTION FLOW ======',
    );

    try {
      setState(() {
        _isCompletingIntro = true;
      });

      // Log current auth state for debugging
      // final authState = ref.read(authenticationStateProvider);
      // DebugLogger.auth(
      //     'IntroductionScreen: Current auth state before completion:');
      // DebugLogger.auth(
      //     'IntroductionScreen:   - Authenticated: ${authState.isAuthenticated}');
      // DebugLogger.auth(
      //     'IntroductionScreen:   - User: ${authState.user?.username ?? 'none'}');
      // DebugLogger.auth(
      //     'IntroductionScreen:   - User Type: ${authState.user?.userType.name ?? 'none'}');

      // Step 1: Mark intro as watched in HiveService for persistence
      DebugLogger.storage(
        'IntroductionScreen: Marking intro as watched in HiveService...',
      );
      await HiveService.setIntroWatched();

      // Check if widget is still mounted after async operation
      if (!context.mounted) {
        DebugLogger.warning(
          'IntroductionScreen: Widget unmounted after setIntroWatched',
        );
        return;
      }

      DebugLogger.success(
        'IntroductionScreen: Intro completion status saved successfully',
      );

      // Step 2: Check language selection status
      DebugLogger.intro(
        'IntroductionScreen: Checking language selection status...',
      );
      if (!HiveService.isLanguageSelected()) {
        DebugLogger.info(
          'IntroductionScreen: Language not selected → Navigating to language selection screen',
        );
        DebugLogger.navigation(
          'IntroductionScreen: → Language Selection Screen',
        );

        // Check if widget is still mounted before navigation
        if (context.mounted) {
          context.go(RouteEnum.languageSelection.rawValue);
        } else {
          DebugLogger.warning(
            'IntroductionScreen: Widget unmounted, skipping navigation to language selection',
          );
        }
        return;
      }
      DebugLogger.success(
        'IntroductionScreen: Language already selected: ${HiveService.getSelectedLanguage()}',
      );

      // Step 3: Check authentication status
      DebugLogger.auth('IntroductionScreen: Checking authentication status...');
      if (!HiveService.isLoggedIn()) {
        DebugLogger.info(
          'IntroductionScreen: User not authenticated → Navigating to welcome screen',
        );
        DebugLogger.navigation(
          'IntroductionScreen: → Welcome Screen for authentication',
        );

        // Check if widget is still mounted before navigation
        if (context.mounted) {
          context.go(RouteEnum.welcome.rawValue);
        } else {
          DebugLogger.warning(
            'IntroductionScreen: Widget unmounted, skipping navigation to welcome',
          );
        }
        return;
      }
      DebugLogger.success('IntroductionScreen: User is authenticated');

      // Step 4: Get user data and navigate to appropriate dashboard
      DebugLogger.user(
        'IntroductionScreen: Getting user data for dashboard routing...',
      );
      final userData = HiveService.getUserDataSafe();

      if (userData != null) {
        DebugLogger.success(
          'IntroductionScreen: User data retrieved successfully',
        );
        DebugLogger.user('IntroductionScreen: User: ${userData.name}');
        DebugLogger.user('IntroductionScreen: Email: ${userData.email}');
        DebugLogger.user(
          'IntroductionScreen: Verified: ${userData.isVerified}',
        );

        // Navigate to main dashboard (for now, we'll use homePage as the main dashboard)
        DebugLogger.navigation('IntroductionScreen: → Main Dashboard');

        // Check if widget is still mounted before navigation
        if (context.mounted) {
          context.go(RouteEnum.homePage.rawValue);
        } else {
          DebugLogger.warning(
            'IntroductionScreen: Widget unmounted, skipping navigation to dashboard',
          );
        }
      } else {
        DebugLogger.error(
          'IntroductionScreen: User data is null despite login status being true',
        );
        DebugLogger.error(
          'IntroductionScreen: Inconsistent state detected → Clearing session and navigating to home',
        );

        // Clear inconsistent session state
        await HiveService.emergencyLogout();

        // Check if widget is still mounted after async operation
        if (!context.mounted) {
          DebugLogger.warning(
            'IntroductionScreen: Widget unmounted after emergencyLogout',
          );
          return;
        }

        DebugLogger.navigation(
          'IntroductionScreen: → Home Screen (after clearing inconsistent state)',
        );

        // Check if widget is still mounted before navigation
        if (context.mounted) {
          context.go(RouteEnum.homePage.rawValue);
        } else {
          DebugLogger.warning(
            'IntroductionScreen: Widget unmounted, skipping emergency navigation',
          );
        }
      }

      DebugLogger.success(
        'IntroductionScreen: ====== TAILOR APP INTRO COMPLETION SUCCESSFUL ======',
      );
    } catch (e, stackTrace) {
      DebugLogger.error('IntroductionScreen: Error completing intro: $e');
      DebugLogger.debug('IntroductionScreen: Stack trace: $stackTrace');

      // Fallback navigation on error
      DebugLogger.navigation(
        'IntroductionScreen: Attempting fallback navigation...',
      );

      // Check if widget is still mounted before fallback navigation
      if (!context.mounted) {
        DebugLogger.warning(
          'IntroductionScreen: Widget unmounted, skipping fallback navigation',
        );
        return;
      }

      try {
        // Try to navigate to home screen as fallback
        DebugLogger.navigation('IntroductionScreen: Fallback → Home Screen');
        context.go(RouteEnum.homePage.rawValue);
      } catch (navError) {
        DebugLogger.error(
          'IntroductionScreen: Fallback navigation failed: $navError',
        );

        // Check if widget is still mounted before ultimate fallback
        if (!context.mounted) {
          DebugLogger.warning(
            'IntroductionScreen: Widget unmounted, skipping ultimate fallback',
          );
          return;
        }

        // Ultimate fallback to home route
        try {
          DebugLogger.navigation(
            'IntroductionScreen: Ultimate fallback → Home',
          );
          context.go(RouteEnum.homePage.rawValue);
        } catch (ultimateError) {
          DebugLogger.error(
            'IntroductionScreen: Ultimate fallback failed: $ultimateError',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompletingIntro = false;
        });
      }
    }
  }
}

/// Enhanced OnboardingPage class with comprehensive ThemeManager support
class OnboardingPage {
  final String title;
  final String subtitle;
  final String animationPath;
  final Color color;
  final List<Color> gradientColors;
  final IconData icon;
  final String statusType;
  final double scale;
  final double translateX;
  final double translateY;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.animationPath,
    required this.color,
    required this.gradientColors,
    required this.icon,
    required this.statusType,
    this.scale = 1.0,
    this.translateX = 0.0,
    this.translateY = 0.0,
  });
}

/// Legacy Introduction class for backward compatibility
class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroductionScreen();
  }

  // Legacy static getter for backward compatibility
  static Widget get intro => const IntroductionScreen();
}
