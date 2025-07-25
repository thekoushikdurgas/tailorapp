import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tailorapp/core/icons/prbal_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tailorapp/core/init/localization/project_locales.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/view/_product/enum/route_enum.dart';
import 'package:tailorapp/core/services/theme_manager.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/mixins/theme_aware_mixin.dart';

/// ====================================================================
/// TAILOR APP LANGUAGE SELECTION SCREEN
/// ====================================================================
///
/// **✅ COMPREHENSIVE INDIAN LANGUAGE SUPPORT ✅**
///
/// **🌍 ENHANCED MULTI-LANGUAGE SUPPORT:**
///
/// **1. SUPPORTED LANGUAGES (10 Total):**
/// - English (en-US) - Primary/Default
/// - Hindi (hi-IN) - National language
/// - Bengali (bn-IN) - West Bengal region
/// - Telugu (te-IN) - Andhra Pradesh/Telangana
/// - Marathi (mr-IN) - Maharashtra
/// - Tamil (ta-IN) - Tamil Nadu
/// - Gujarati (gu-IN) - Gujarat
/// - Kannada (kn-IN) - Karnataka
/// - Malayalam (ml-IN) - Kerala
/// - Punjabi (pa-IN) - Punjab
///
/// **2. ENHANCED FEATURES:**
/// - Beautiful flag-based language cards with native script display
/// - Smooth animations and haptic feedback
/// - Auto-detection of current device locale
/// - Fallback to English for unsupported locales
/// - Comprehensive debug logging throughout
/// - State management with proper error handling
/// - Theme-aware design with ThemeManager integration
/// - Proper navigation flow integration
///
/// **3. ARCHITECTURAL INTEGRATION:**
/// - ConsumerStatefulWidget for Riverpod integration
/// - ThemeAwareMixin for theme management
/// - HiveService for language persistence
/// - DebugLogger for comprehensive logging
/// - ProjectLocales for language metadata
/// - Easy localization for immediate language switching
///
/// **4. UX FEATURES:**
/// - Flag emoji representations
/// - Native script language names
/// - Language family and region information
/// - Writing script identification
/// - Smooth selection animations
/// - Success/error feedback with snackbars
/// - Skip option for default language
/// ====================================================================

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen>
    with TickerProviderStateMixin, ThemeAwareMixin {
  // Animation controllers for smooth UI transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Selected locale state - defaults to English
  Locale _selectedLocale = ProjectLocales.defaultLocale;

  @override
  void initState() {
    super.initState();
    DebugLogger.intro(
      'LanguageSelectionScreen: ====== INITIALIZING TAILOR APP LANGUAGE SELECTION ======',
    );
    DebugLogger.intro(
      'LanguageSelectionScreen: Supported languages: ${ProjectLocales.totalLanguages}',
    );
    DebugLogger.intro(
      'LanguageSelectionScreen: Indian languages: ${ProjectLocales.totalIndianLanguages}',
    );

    // Log all supported locales for debugging
    ProjectLocales.logSupportedLocales();

    _initializeAnimations();
    // Don't call _setCurrentLocale here - move to didChangeDependencies for proper context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DebugLogger.intro(
      'LanguageSelectionScreen: Dependencies changed → Setting current locale...',
    );
    _setCurrentLocale();
  }

  /// Initialize entrance animations for smooth user experience
  ///
  /// **ANIMATIONS:**
  /// - Fade animation: 0.0 → 1.0 over 800ms with ease-out curve
  /// - Slide animation: Offset(0, 0.5) → Offset.zero with elastic curve
  /// - Staggered timing for smooth sequential animation
  void _initializeAnimations() {
    DebugLogger.info(
      'LanguageSelectionScreen: Initializing entrance animations',
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Fade animation for overall screen appearance
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Slide animation for content sliding up from bottom
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Start animations immediately
    _animationController.forward();
    DebugLogger.success('LanguageSelectionScreen: ✅ Animations started');
  }

  /// Detect and set current locale based on device settings with comprehensive fallback
  ///
  /// **LOGIC:**
  /// 1. Attempt to get current locale from Flutter context
  /// 2. Check if device locale is supported in our language list
  /// 3. If supported → use device locale
  /// 4. If not supported → fallback to English (en-US)
  /// 5. Update UI state to reflect selected locale
  /// 6. Log all steps for debugging
  void _setCurrentLocale() {
    DebugLogger.intro(
      'LanguageSelectionScreen: === LOCALE DETECTION PROCESS ===',
    );

    try {
      // Step 1: Get current locale from Flutter context (safely)
      final currentLocale = Localizations.maybeLocaleOf(context);
      DebugLogger.intro(
        'LanguageSelectionScreen: Device locale detected: $currentLocale',
      );

      if (currentLocale != null) {
        DebugLogger.intro(
          'LanguageSelectionScreen: Checking if device locale is supported...',
        );

        // Step 2: Check if current locale is in our supported languages
        if (ProjectLocales.isSupported(currentLocale)) {
          DebugLogger.success(
            'LanguageSelectionScreen: Device locale IS supported → Using: ${ProjectLocales.getStringFromLocale(currentLocale)}',
          );
          _selectedLocale = currentLocale;
        } else {
          DebugLogger.info(
            'LanguageSelectionScreen: Device locale NOT supported → Checking language-only match...',
          );

          // Step 3: Try to find a language-only match (e.g., 'hi' matches 'hi-IN')
          final languageOnlyMatch = ProjectLocales.supportedLocales.firstWhere(
            (locale) => locale.languageCode == currentLocale.languageCode,
            orElse: () => ProjectLocales.defaultLocale,
          );

          if (languageOnlyMatch != ProjectLocales.defaultLocale) {
            DebugLogger.success(
              'LanguageSelectionScreen: Found language match: ${ProjectLocales.getStringFromLocale(languageOnlyMatch)}',
            );
            _selectedLocale = languageOnlyMatch;
          } else {
            DebugLogger.info(
              'LanguageSelectionScreen: No language match → Using default: ${ProjectLocales.getStringFromLocale(ProjectLocales.defaultLocale)}',
            );
            _selectedLocale = ProjectLocales.defaultLocale;
          }
        }
      } else {
        DebugLogger.info(
          'LanguageSelectionScreen: Device locale not available → Using default: ${ProjectLocales.getStringFromLocale(ProjectLocales.defaultLocale)}',
        );
        _selectedLocale = ProjectLocales.defaultLocale;
      }

      DebugLogger.success(
        'LanguageSelectionScreen: Final selected locale: ${ProjectLocales.getStringFromLocale(_selectedLocale)}',
      );
      DebugLogger.info(
        'LanguageSelectionScreen: Display name: ${ProjectLocales.getDisplayName(_selectedLocale)}',
      );

      // Step 4: Update UI to reflect selected locale
      if (mounted) {
        setState(() {});
        DebugLogger.success(
          'LanguageSelectionScreen: UI updated with selected locale',
        );
      }
    } catch (e) {
      DebugLogger.error(
        'LanguageSelectionScreen: Error in locale detection: $e',
      );
      DebugLogger.info(
        'LanguageSelectionScreen: Using fallback default locale',
      );

      // Fallback to default locale on any error
      _selectedLocale = ProjectLocales.defaultLocale;
      if (mounted) {
        setState(() {});
      }
    }

    DebugLogger.intro(
      'LanguageSelectionScreen: ============================================',
    );
  }

  @override
  void dispose() {
    DebugLogger.info('LanguageSelectionScreen: Disposing animation controller');
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DebugLogger.info(
      'LanguageSelectionScreen: Building UI with ThemeManager colors',
    );
    DebugLogger.info(
      'LanguageSelectionScreen: Background: ${ThemeManager.of(context).backgroundColor}',
    );
    DebugLogger.info(
      'LanguageSelectionScreen: Surface: ${ThemeManager.of(context).surfaceColor}',
    );
    DebugLogger.info(
      'LanguageSelectionScreen: Current selected locale: ${ProjectLocales.getStringFromLocale(_selectedLocale)}',
    );

    return Scaffold(
      backgroundColor: ThemeManager.of(context).backgroundColor,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(context),
            ),
          );
        },
      ),
    );
  }

  /// Set default language (English) and continue to next screen
  ///
  /// **USAGE:**
  /// - Called when user presses back/skip button
  /// - Provides fallback for users who don't want to select language
  /// - Ensures app always has a valid language setting
  ///
  /// **PROCESS:**
  /// 1. Set English as default language in local storage
  /// 2. Log the operation for debugging
  /// 3. Navigate to appropriate next screen
  /// 4. Handle errors gracefully
  void _setDefaultLanguageAndContinue(BuildContext context) async {
    DebugLogger.intro(
      'LanguageSelectionScreen: === SETTING DEFAULT LANGUAGE ===',
    );

    try {
      // Set English as default if no language is selected
      await HiveService.saveSelectedLanguage('en-US');
      DebugLogger.success(
        'LanguageSelectionScreen: Default language (en-US) saved successfully',
      );
      DebugLogger.navigation(
        'LanguageSelectionScreen: → Continuing to next screen...',
      );

      // Check if widget is still mounted before navigation
      if (context.mounted) {
        _navigateToNextScreen(context);
      } else {
        DebugLogger.warning(
          'LanguageSelectionScreen: Widget unmounted, skipping navigation after setting default language',
        );
      }
    } catch (e) {
      DebugLogger.error(
        'LanguageSelectionScreen: Error setting default language: $e',
      );
      DebugLogger.info(
        'LanguageSelectionScreen: → Continuing anyway (language can be set later)',
      );

      // Even if there's an error saving language, continue to next screen
      // Language selection can be done later in settings
      // Check if widget is still mounted before navigation
      if (context.mounted) {
        _navigateToNextScreen(context);
      } else {
        DebugLogger.warning(
          'LanguageSelectionScreen: Widget unmounted, skipping navigation after error',
        );
      }
    }
  }

  /// Navigate to the appropriate next screen
  ///
  /// **NAVIGATION LOGIC:**
  /// Based on app state and user authentication:
  /// - If intro not watched → Introduction Screen
  /// - If not authenticated → Home Screen (auth flow)
  /// - If authenticated → Main Dashboard
  ///
  /// **PROCESS:**
  /// 1. Check intro/onboarding status
  /// 2. Check authentication status
  /// 3. Navigate to appropriate screen
  /// 4. Handle errors gracefully with fallbacks
  void _navigateToNextScreen(BuildContext context) {
    DebugLogger.navigation('LanguageSelectionScreen: === NAVIGATION LOGIC ===');

    try {
      // Check intro status
      final hasIntroBeenWatched = HiveService.isIntroWatched();
      DebugLogger.navigation(
        'LanguageSelectionScreen: Intro watched: $hasIntroBeenWatched',
      );

      // Check authentication status
      final isLoggedIn = HiveService.isLoggedIn();
      DebugLogger.navigation(
        'LanguageSelectionScreen: Authenticated: $isLoggedIn',
      );

      DebugLogger.navigation('LanguageSelectionScreen: Navigation decision:');

      // Since language selection is part of the intro flow,
      // after language selection we continue with the normal app flow
      if (!isLoggedIn) {
        // User not authenticated → go to home for auth
        DebugLogger.navigation(
          'LanguageSelectionScreen: → Home Screen (authentication needed)',
        );
        context.go(RouteEnum.homePage.rawValue);
      } else {
        // User is authenticated → go to main dashboard
        DebugLogger.navigation(
          'LanguageSelectionScreen: → Main Dashboard (authenticated user)',
        );
        context.go(RouteEnum.homePage.rawValue);
      }

      DebugLogger.success(
        'LanguageSelectionScreen: Navigation completed successfully',
      );
    } catch (e, stackTrace) {
      DebugLogger.error('LanguageSelectionScreen: Navigation error: $e');
      DebugLogger.debug('LanguageSelectionScreen: Stack trace: $stackTrace');

      // Fallback navigation in case of error
      DebugLogger.navigation(
        'LanguageSelectionScreen: Attempting fallback navigation...',
      );
      try {
        // Fallback to home screen
        DebugLogger.navigation(
          'LanguageSelectionScreen: Fallback → Home Screen',
        );
        context.go(RouteEnum.homePage.rawValue);
      } catch (fallbackError) {
        DebugLogger.error(
          'LanguageSelectionScreen: Fallback navigation also failed: $fallbackError',
        );
        // Ultimate fallback to intro
        try {
          context.go(RouteEnum.intro.rawValue);
        } catch (ultimateError) {
          DebugLogger.error(
            'LanguageSelectionScreen: Ultimate fallback failed: $ultimateError',
          );
        }
      }
    }

    DebugLogger.navigation(
      'LanguageSelectionScreen: ===============================================',
    );
  }

  /// Builds the main body content with header and language list
  ///
  /// **LAYOUT:**
  /// - Column structure with scrollable content at top
  /// - Header section with app branding and description
  /// - Language selection grid/list (scrollable)
  /// - Apply button strictly positioned at bottom
  /// - Proper spacing and padding throughout
  Widget _buildBody(BuildContext context) {
    DebugLogger.info(
      'LanguageSelectionScreen: Building main body content with bottom-fixed apply button',
    );

    return Column(
      children: [
        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 32.h),
                _buildLanguageList(),
                SizedBox(
                  height: 20.h,
                ), // Reduced spacing since button is now separate
              ],
            ),
          ),
        ),

        // Fixed buttons at bottom
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: ThemeManager.of(context).backgroundColor,
            border: Border(
              top: BorderSide(
                color: ThemeManager.of(context).borderColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(child: _buildApplyButton(context)),
              SizedBox(width: 12.w),
              Expanded(child: _buildSkipButton(context)),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the header section with branding and description
  ///
  /// **FEATURES:**
  /// - App branding with logo and title
  /// - Multilingual description text
  /// - Proper typography and spacing
  /// - Theme-aware colors and styling
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App branding section
        Row(
          children: [
            // App icon with theme-aware gradient
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                gradient: ThemeManager.of(context).primaryGradient,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: ThemeManager.of(context)
                      .primaryColor
                      .withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Prbal.globe,
                color: Colors.white,
                size: 32.sp,
              ),
            ),

            SizedBox(width: 16.w),

            // App title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'localization.languageSelection.title'.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: ThemeManager.of(context).textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'localization.languageSelection.subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ThemeManager.of(context).textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        // Language selection stats
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: ThemeManager.of(context).surfaceElevated,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: ThemeManager.of(context).borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Prbal.info,
                size: 20.sp,
                color: ThemeManager.of(context).primaryColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'localization.availableLanguages'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: ThemeManager.of(context).textSecondary,
                      ),
                    ),
                    Text(
                      '${ProjectLocales.totalLanguages} languages (${ProjectLocales.totalIndianLanguages} Indian)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: ThemeManager.of(context).textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the language selection list with all supported languages
  ///
  /// **DESIGN:**
  /// - Modern card container with shadows
  /// - Individual language items with flags and native names
  /// - Smooth selection animations
  /// - Proper dividers between items
  /// - Theme-aware styling throughout
  Widget _buildLanguageList() {
    DebugLogger.info(
      'LanguageSelectionScreen: Building language list with ${ProjectLocales.totalLanguages} languages',
    );

    final sortedLocales = ProjectLocales.getSortedLocales();

    return Column(
      children: sortedLocales
          .map(
            (locale) => _buildLanguageItem(
              locale: locale,
              name: ProjectLocales.getDisplayName(locale),
              flag: ProjectLocales.getFlagForLocale(locale),
              region: ProjectLocales.getRegionName(locale),
              script: ProjectLocales.getWritingScript(locale),
              isLast: locale == sortedLocales.last,
            ),
          )
          .toList(),
    );
  }

  /// Builds individual language selection item with enhanced design
  ///
  /// **PARAMETERS:**
  /// - locale: The Locale object for this language
  /// - name: Display name (e.g., "हिन्दी (Hindi)")
  /// - flag: Flag emoji for the language/region
  /// - region: Geographic region (e.g., "Maharashtra")
  /// - script: Writing script (e.g., "Devanagari")
  /// - isLast: Whether this is the last item (for border handling)
  ///
  /// **FEATURES:**
  /// - Smooth tap animations with haptic feedback
  /// - Visual selection indicator
  /// - Flag emoji with proper styling
  /// - Native script language names
  /// - Proper typography and spacing
  /// - Theme-aware colors and styling
  Widget _buildLanguageItem({
    required Locale locale,
    required String name,
    required String flag,
    required String region,
    required String script,
    required bool isLast,
  }) {
    final isSelected = _selectedLocale == locale;
    DebugLogger.info(
      'LanguageSelectionScreen: Building language item: ${ProjectLocales.getStringFromLocale(locale)} (Selected: $isSelected)',
    );

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            DebugLogger.info(
              'LanguageSelectionScreen: Language tapped: ${ProjectLocales.getStringFromLocale(locale)}',
            );
            DebugLogger.info('LanguageSelectionScreen: Display name: $name');

            setState(() {
              _selectedLocale = locale;
            });

            // Provide haptic feedback for better UX
            HapticFeedback.lightImpact();
            DebugLogger.success(
              'LanguageSelectionScreen: Language selection updated with haptic feedback',
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? ThemeManager.of(context).primaryColor.withValues(alpha: 0.1)
                  : ThemeManager.of(context).surfaceColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? ThemeManager.of(context).primaryColor
                    : ThemeManager.of(context).borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Flag container with modern styling
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: ThemeManager.of(context).surfaceElevated,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: ThemeManager.of(context).borderColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      flag,
                      style: TextStyle(fontSize: 24.sp),
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Language name and metadata information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language display name with native script
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? ThemeManager.of(context).primaryColor
                              : ThemeManager.of(context).textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Language metadata (region and script)
                      Row(
                        children: [
                          // Region
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeManager.of(context)
                                  .textTertiary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              region,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: ThemeManager.of(context).textTertiary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Script
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeManager.of(context)
                                  .textTertiary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              script,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: ThemeManager.of(context).textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                // Selection indicator with smooth animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? ThemeManager.of(context).primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? ThemeManager.of(context).primaryColor
                          : ThemeManager.of(context).textTertiary,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Prbal.check,
                          color: Colors.white,
                          size: 16.sp,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the apply button with gradient styling and proper states
  ///
  /// **FEATURES:**
  /// - Gradient button with brand colors
  /// - Smooth hover and press animations
  /// - Proper icon and text spacing
  /// - Theme-aware shadows and styling
  /// - Handles language application logic
  Widget _buildApplyButton(BuildContext context) {
    DebugLogger.info('LanguageSelectionScreen: Building apply button');

    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        gradient: ThemeManager.of(context).primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ThemeManager.of(context).primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            DebugLogger.info('LanguageSelectionScreen: Apply button tapped');
            _applyLanguageSelection(context);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Prbal.check,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'localization.languageSelection.applyLanguage'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the skip button with outline styling
  ///
  /// **FEATURES:**
  /// - Outline button with theme colors
  /// - Subtle styling to complement the apply button
  /// - Proper icon and text spacing
  /// - Theme-aware colors and borders
  /// - Sets default language and continues navigation
  Widget _buildSkipButton(BuildContext context) {
    DebugLogger.info('LanguageSelectionScreen: Building skip button');

    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ThemeManager.of(context).borderColor,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            DebugLogger.info('LanguageSelectionScreen: Skip button tapped');
            _setDefaultLanguageAndContinue(context);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Prbal.arrowRight,
                  color: ThemeManager.of(context).textSecondary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'localization.languageSelection.skipSelection'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: ThemeManager.of(context).textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Apply the selected language with comprehensive error handling and user feedback
  ///
  /// **PROCESS:**
  /// 1. Convert selected locale to storage format (language-COUNTRY)
  /// 2. Save language preference to local storage
  /// 3. Apply locale change using EasyLocalization
  /// 4. Show success feedback with haptic response
  /// 5. Navigate to next screen after short delay
  /// 6. Handle errors gracefully with user notifications
  ///
  /// **ERROR HANDLING:**
  /// - Storage errors are caught and logged
  /// - User receives appropriate error messages
  /// - App continues to function even if language saving fails
  void _applyLanguageSelection(BuildContext context) async {
    DebugLogger.intro(
      'LanguageSelectionScreen: === APPLYING LANGUAGE SELECTION ===',
    );
    DebugLogger.intro(
      'LanguageSelectionScreen: Selected locale: ${ProjectLocales.getStringFromLocale(_selectedLocale)}',
    );
    DebugLogger.intro(
      'LanguageSelectionScreen: Display name: ${ProjectLocales.getDisplayName(_selectedLocale)}',
    );

    try {
      // Step 1: Convert locale to storage format
      final languageCode = ProjectLocales.getStringFromLocale(_selectedLocale);
      DebugLogger.storage(
        'LanguageSelectionScreen: Storage format: $languageCode',
      );

      // Step 2: Save the selected language to local storage
      DebugLogger.storage(
        'LanguageSelectionScreen: Saving language to local storage...',
      );
      await HiveService.saveSelectedLanguage(languageCode);
      DebugLogger.success(
        'LanguageSelectionScreen: Language saved successfully',
      );

      // Step 2.5: Apply locale change using EasyLocalization
      DebugLogger.info(
        'LanguageSelectionScreen: Applying locale change with EasyLocalization...',
      );

      if (context.mounted) {
        try {
          // Change the app's locale immediately using EasyLocalization
          await context.setLocale(_selectedLocale);

          // Check if still mounted after async operation
          if (!context.mounted) {
            DebugLogger.warning(
              'LanguageSelectionScreen: Widget unmounted after setLocale',
            );
            return;
          }

          DebugLogger.success(
            'LanguageSelectionScreen: EasyLocalization locale changed successfully',
          );
          DebugLogger.success(
            'LanguageSelectionScreen: App now using: ${ProjectLocales.getStringFromLocale(_selectedLocale)}',
          );
        } catch (localeError) {
          DebugLogger.error(
            'LanguageSelectionScreen: EasyLocalization setLocale failed: $localeError',
          );
          DebugLogger.info(
            'LanguageSelectionScreen: Continuing anyway - locale may change on next app start',
          );
        }
      }

      // Step 3: Provide haptic feedback for successful action
      HapticFeedback.mediumImpact();
      DebugLogger.info('LanguageSelectionScreen: ✅ Haptic feedback provided');

      // Step 4: Show success notification to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Prbal.check,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'localization.languageChanged'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: ThemeManager.of(context).successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.only(
              bottom: 100.h,
              left: 16.w,
              right: 16.w,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        DebugLogger.info(
          'LanguageSelectionScreen: ✅ Success notification shown',
        );
      }

      // Step 5: Navigate to next screen after short delay for UX
      DebugLogger.navigation(
        'LanguageSelectionScreen: Waiting 1 second before navigation...',
      );
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check if widget is still mounted after delay
      if (context.mounted) {
        DebugLogger.success(
          'LanguageSelectionScreen: Language applied: $languageCode',
        );
        _navigateToNextScreen(context);
      } else {
        DebugLogger.warning(
          'LanguageSelectionScreen: Widget unmounted after delay, skipping navigation',
        );
      }

      DebugLogger.success(
        'LanguageSelectionScreen: Language application completed successfully',
      );
    } catch (e) {
      DebugLogger.error(
        'LanguageSelectionScreen: Error saving language selection: $e',
      );

      // Show error notification to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Prbal.exclamationTriangle,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'localization.languageError'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: ThemeManager.of(context).errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.only(
              bottom: 100.h,
              left: 16.w,
              right: 16.w,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        DebugLogger.error('LanguageSelectionScreen: Error notification shown');
      }

      // Continue to next screen anyway - language can be set later in settings
      DebugLogger.navigation(
        'LanguageSelectionScreen: → Continuing to next screen despite error',
      );

      // Check if widget is still mounted before navigation
      if (context.mounted) {
        _navigateToNextScreen(context);
      } else {
        DebugLogger.warning(
          'LanguageSelectionScreen: Widget unmounted, skipping error recovery navigation',
        );
      }
    }

    DebugLogger.intro(
      'LanguageSelectionScreen: ===============================================',
    );
  }
}
