import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/core/services/debug_logger.dart';

/// **ThemeManager** - Performance-optimized centralized theme management utility
///
/// **Purpose**: Provides easy access to theme-aware colors, gradients, and design tokens
///
/// **Features**:
/// - Automatic light/dark theme detection
/// - Consistent color palette access
/// - Pre-built gradient combinations
/// - Material Design 3.0 compliance
/// - Debug logging for theme operations
/// - Comprehensive SourGummy typography system
/// - Performance caching for expensive operations
/// - Lazy loading of theme data
/// - Memory optimization and cache management
class ThemeManager {
  final BuildContext context;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isDarkMode;

  // Cache for expensive operations
  static final Map<String, dynamic> _cache = {};
  static bool _cacheEnabled = true;

  // Lazy-loaded theme data
  static ThemeData? _lightThemeInstance;
  static ThemeData? _darkThemeInstance;

  ThemeManager._(this.context)
      : theme = Theme.of(context),
        colorScheme = Theme.of(context).colorScheme,
        isDarkMode = Theme.of(context).brightness == Brightness.dark;

  /// Factory constructor with instance caching
  static ThemeManager? _instance;
  static BuildContext? _lastContext;

  factory ThemeManager.of(BuildContext context) {
    // Reuse instance if context hasn't changed significantly
    if (_instance != null &&
        _lastContext != null &&
        Theme.of(_lastContext!) == Theme.of(context)) {
      return _instance!;
    }

    _instance = ThemeManager._(context);
    _lastContext = context;
    return _instance!;
  }

  /// Clear cache when theme changes
  static void clearCache() {
    _cache.clear();
    _instance = null;
    _lastContext = null;
  }

  /// Enable/disable caching (useful for development)
  static void setCacheEnabled(bool enabled) {
    _cacheEnabled = enabled;
    if (!enabled) clearCache();
  }

  // =================== THEME MODE PROPERTIES ===================

  /// Whether the current theme is light mode
  bool get isLightMode => !isDarkMode;

  // =================== CACHED PROPERTY GETTER ===================

  T _getCached<T>(String key, T Function() factory) {
    if (!_cacheEnabled) return factory();

    final cacheKey = '${isDarkMode ? 'dark' : 'light'}_$key';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as T;
    }

    final value = factory();
    _cache[cacheKey] = value;
    return value;
  }

  // =================== SOUR GUMMY FONT FAMILY CONSTANTS ===================

  /// Primary SourGummy font family for standard text
  static const String fontFamilyPrimary = 'SourGummy';

  /// SourGummy Expanded for headings and emphasis
  static const String fontFamilyExpanded = 'SourGummy_Expanded';

  /// SourGummy SemiExpanded for subheadings and titles
  static const String fontFamilySemiExpanded = 'SourGummy_SemiExpanded';

  // =================== TYPOGRAPHY SYSTEM ===================

  /// Get comprehensive typography theme using SourGummy fonts
  static TextTheme _getSourGummyTextTheme(bool isDark) {
    final Color primaryTextColor =
        isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827);
    final Color secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563);
    final Color tertiaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return TextTheme(
      // Display styles - SourGummy Expanded for maximum impact
      displayLarge: TextStyle(
        fontFamily: fontFamilyExpanded,
        fontSize: 57.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.25,
        height: 1.12,
        color: primaryTextColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamilyExpanded,
        fontSize: 45.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.16,
        color: primaryTextColor,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamilySemiExpanded,
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.22,
        color: primaryTextColor,
      ),

      // Headline styles - SourGummy SemiExpanded for structure
      headlineLarge: TextStyle(
        fontFamily: fontFamilySemiExpanded,
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.25,
        color: primaryTextColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamilySemiExpanded,
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.29,
        color: primaryTextColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: primaryTextColor,
      ),

      // Title styles - SourGummy Primary for balance
      titleLarge: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: primaryTextColor,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
        color: primaryTextColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: primaryTextColor,
      ),

      // Label styles - SourGummy Primary for UI elements
      labelLarge: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: secondaryTextColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: secondaryTextColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: tertiaryTextColor,
      ),

      // Body styles - SourGummy Primary for readability
      bodyLarge: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
        color: primaryTextColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: primaryTextColor,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: secondaryTextColor,
      ),
    );
  }

  /// Get custom typography styles for specific use cases
  TextStyle get customHeadingXL => TextStyle(
        fontFamily: fontFamilyExpanded,
        fontSize: 64.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        height: 1.1,
        color: textPrimary,
      );

  TextStyle get customHeadingLogo => TextStyle(
        fontFamily: fontFamilyExpanded,
        fontSize: 32.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        height: 1.2,
        color: primaryColor,
      );

  TextStyle get customButtonText => TextStyle(
        fontFamily: fontFamilySemiExpanded,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        height: 1.2,
        color: textInverted,
      );

  TextStyle get customCaption => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 10.sp,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
        height: 1.4,
        color: textTertiary,
      );

  TextStyle get customCardTitle => TextStyle(
        fontFamily: fontFamilySemiExpanded,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
        color: textPrimary,
      );

  TextStyle get customCardSubtitle => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.3,
        color: textSecondary,
      );

  // =================== OPTIMIZED THEME DATA CREATION ===================

  /// Lazy-loaded light theme
  static ThemeData get lightTheme {
    return _lightThemeInstance ??= _createLightTheme();
  }

  /// Lazy-loaded dark theme
  static ThemeData get darkTheme {
    return _darkThemeInstance ??= _createDarkTheme();
  }

  /// Create light theme data compatible with ThemeManager system
  static ThemeData _createLightTheme() => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: fontFamilyPrimary, // Set default font family
        textTheme: _getSourGummyTextTheme(false),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFFFFFFFF),
          error: Color(0xFFDC2626),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFF111827),
          onError: Color(0xFFFFFFFF),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: fontFamilySemiExpanded,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: const Color(0xFFFFFFFF),
            elevation: 2,
            textStyle: TextStyle(
              fontFamily: fontFamilySemiExpanded,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          labelStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9CA3AF),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
        ),
      );

  /// Create dark theme data compatible with ThemeManager system
  static ThemeData _createDarkTheme() => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: fontFamilyPrimary, // Set default font family
        textTheme: _getSourGummyTextTheme(true),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
          error: Color(0xFFEF4444),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFFF1F5F9),
          onError: Color(0xFFFFFFFF),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: const Color(0xFFF1F5F9),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: fontFamilySemiExpanded,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF1F5F9),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: const Color(0xFFFFFFFF),
            elevation: 4,
            textStyle: TextStyle(
              fontFamily: fontFamilySemiExpanded,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E293B),
          labelStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            fontFamily: fontFamilyPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
          ),
        ),
      );

  // =================== BACKGROUND GRADIENTS ===================

  /// Primary background gradient for screens
  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDarkMode
            ? [const Color(0xFF0F0F23), const Color(0xFF1A1A2E)]
            : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
      );

  /// Surface gradient for cards and containers
  LinearGradient get surfaceGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
            : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
      );

  /// Primary accent gradient (cached)
  LinearGradient get primaryGradient => _getCached(
        'primaryGradient',
        () => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]
              : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        ),
      );

  /// Secondary accent gradient (cached)
  LinearGradient get secondaryGradient => _getCached(
        'secondaryGradient',
        () => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF06D6A0), const Color(0xFF048A81)]
              : [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
      );

  /// Success gradient for positive actions
  LinearGradient get successGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFF10B981), const Color(0xFF059669)]
            : [const Color(0xFF22C55E), const Color(0xFF16A34A)],
      );

  /// Warning gradient for attention-grabbing elements
  LinearGradient get warningGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFFEAB308), const Color(0xFFCA8A04)]
            : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      );

  /// Error gradient for error states
  LinearGradient get errorGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
            : [const Color(0xFFF87171), const Color(0xFFEF4444)],
      );

  /// Info gradient for informational elements
  LinearGradient get infoGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
            : [const Color(0xFF60A5FA), const Color(0xFF3B82F6)],
      );

  /// Neutral gradient for subtle elements
  LinearGradient get neutralGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFF334155), const Color(0xFF1E293B)]
            : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
      );

  /// Accent gradient 1 - Purple
  LinearGradient get accent1Gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]
            : [const Color(0xFFA78BFA), const Color(0xFF8B5CF6)],
      );

  /// Accent gradient 2 - Pink
  LinearGradient get accent2Gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFFEC4899), const Color(0xFFDB2777)]
            : [const Color(0xFFF472B6), const Color(0xFFEC4899)],
      );

  /// Accent gradient 3 - Teal
  LinearGradient get accent3Gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFF06D6A0), const Color(0xFF0D9488)]
            : [const Color(0xFF2DD4BF), const Color(0xFF14B8A6)],
      );

  /// Accent gradient 4 - Orange
  LinearGradient get accent4Gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [const Color(0xFFFF6B35), const Color(0xFFEA580C)]
            : [const Color(0xFFFF8C42), const Color(0xFFFF6B35)],
      );

  /// Glass gradient for glass morphism effects
  LinearGradient get glassGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ]
            : [
                Colors.white.withValues(alpha: 0.8),
                Colors.white.withValues(alpha: 0.4),
              ],
      );

  /// Shimmer gradient for loading states
  LinearGradient get shimmerGradient => LinearGradient(
        begin: const Alignment(-1.0, -2.0),
        end: const Alignment(1.0, 2.0),
        colors: isDarkMode
            ? [
                const Color(0xFF334155),
                const Color(0xFF475569),
                const Color(0xFF334155),
              ]
            : [
                const Color(0xFFE2E8F0),
                const Color(0xFFF1F5F9),
                const Color(0xFFE2E8F0),
              ],
        stops: const [0.0, 0.5, 1.0],
      );

  // =================== TEXT THEME ===================

  /// Access to theme text styles
  TextTheme get textTheme => theme.textTheme;

  // =================== COLORS ===================

  /// Primary brand color
  Color get primaryColor => colorScheme.primary;

  /// Secondary brand color
  Color get secondaryColor => colorScheme.secondary;

  /// Background color (cached)
  Color get backgroundColor => _getCached(
        'backgroundColor',
        () => isDarkMode ? const Color(0xFF0F0F23) : const Color(0xFFFAFAFA),
      );

  /// Surface color
  Color get surfaceColor => colorScheme.surface;

  // =================== TEXT COLORS ===================

  /// Primary text color - highest contrast (cached)
  Color get textPrimary => _getCached(
        'textPrimary',
        () => isDarkMode ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
      );

  /// Secondary text color - medium contrast (cached)
  Color get textSecondary => _getCached(
        'textSecondary',
        () => isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF6B7280),
      );

  /// Tertiary text color - low contrast (cached)
  Color get textTertiary => _getCached(
        'textTertiary',
        () => isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
      );

  /// Quaternary text color - subtle hints
  Color get textQuaternary =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFFD1D5DB);

  /// Disabled text color
  Color get textDisabled =>
      isDarkMode ? const Color(0xFF475569) : const Color(0xFFE5E7EB);

  /// Inverted text color - for use on primary/dark backgrounds
  Color get textInverted =>
      isDarkMode ? const Color(0xFF111827) : const Color(0xFFF1F5F9);

  // =================== BACKGROUND COLORS ===================

  /// Secondary background color
  Color get backgroundSecondary =>
      isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8FAFC);

  /// Tertiary background color
  Color get backgroundTertiary =>
      isDarkMode ? const Color(0xFF16213E) : const Color(0xFFE2E8F0);

  /// Card background color
  Color get cardBackground =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  /// Elevated surface color
  Color get surfaceElevated =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFF9FAFB);

  /// Modal background color
  Color get modalBackground =>
      isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);

  /// Overlay background color
  Color get overlayBackground => isDarkMode
      ? Colors.black.withValues(alpha: 0.7)
      : Colors.black.withValues(alpha: 0.5);

  // =================== BORDER COLORS ===================

  /// Primary border color
  Color get borderColor =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

  /// Secondary border color - lighter
  Color get borderSecondary =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);

  /// Focus border color
  Color get borderFocus =>
      isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1);

  /// Divider color
  Color get dividerColor =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);

  /// Transparent color
  Color get transparent => const Color(0x00000000);

  // =================== STATUS COLORS ===================

  /// Success color - green (cached)
  Color get successColor => _getCached(
        'successColor',
        () => isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669),
      );

  /// Success light variant (cached)
  Color get successLight => _getCached(
        'successLight',
        () => isDarkMode ? const Color(0xFF34D399) : const Color(0xFF10B981),
      );

  /// Success dark variant (cached)
  Color get successDark => _getCached(
        'successDark',
        () => isDarkMode ? const Color(0xFF047857) : const Color(0xFF065F46),
      );

  /// Warning color - yellow/orange (cached)
  Color get warningColor => _getCached(
        'warningColor',
        () => isDarkMode ? const Color(0xFFEAB308) : const Color(0xFFD97706),
      );

  /// Warning light variant (cached)
  Color get warningLight => _getCached(
        'warningLight',
        () => isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
      );

  /// Warning dark variant (cached)
  Color get warningDark => _getCached(
        'warningDark',
        () => isDarkMode ? const Color(0xFFA16207) : const Color(0xFF92400E),
      );

  /// Error color - red (cached)
  Color get errorColor => _getCached(
        'errorColor',
        () => isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
      );

  /// Error light variant (cached)
  Color get errorLight => _getCached(
        'errorLight',
        () => isDarkMode ? const Color(0xFFF87171) : const Color(0xFFEF4444),
      );

  /// Error dark variant (cached)
  Color get errorDark => _getCached(
        'errorDark',
        () => isDarkMode ? const Color(0xFFB91C1C) : const Color(0xFF991B1B),
      );

  /// Info color - blue (cached)
  Color get infoColor => _getCached(
        'infoColor',
        () => isDarkMode ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
      );

  /// Info light variant (cached)
  Color get infoLight => _getCached(
        'infoLight',
        () => isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
      );

  /// Info dark variant (cached)
  Color get infoDark => _getCached(
        'infoDark',
        () => isDarkMode ? const Color(0xFF1D4ED8) : const Color(0xFF1E40AF),
      );

  // =================== ACCENT COLORS ===================

  /// Accent color 1 - Purple
  Color get accent1 =>
      isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFF7C3AED);

  /// Accent color 2 - Pink
  Color get accent2 =>
      isDarkMode ? const Color(0xFFEC4899) : const Color(0xFFDB2777);

  /// Accent color 3 - Teal
  Color get accent3 =>
      isDarkMode ? const Color(0xFF06D6A0) : const Color(0xFF0D9488);

  /// Accent color 4 - Orange
  Color get accent4 =>
      isDarkMode ? const Color(0xFFFF6B35) : const Color(0xFFEA580C);

  /// Accent color 5 - Indigo
  Color get accent5 =>
      isDarkMode ? const Color(0xFF6366F1) : const Color(0xFF4F46E5);

  // =================== NEUTRAL COLORS ===================

  /// Neutral 50
  Color get neutral50 =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFFFAFAFA);

  /// Neutral 100
  Color get neutral100 =>
      isDarkMode ? const Color(0xFF475569) : const Color(0xFFF5F5F5);

  /// Neutral 200
  Color get neutral200 =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFEEEEEE);

  /// Neutral 300
  Color get neutral300 =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE0E0E0);

  /// Neutral 400
  Color get neutral400 =>
      isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFBDBDBD);

  /// Neutral 500
  Color get neutral500 =>
      isDarkMode ? const Color(0xFF0F172A) : const Color(0xFF9E9E9E);

  /// Neutral 600
  Color get neutral600 =>
      isDarkMode ? const Color(0xFF475569) : const Color(0xFF757575);

  /// Neutral 700
  Color get neutral700 =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF616161);

  /// Neutral 800
  Color get neutral800 =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF424242);

  /// Neutral 900
  Color get neutral900 =>
      isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF212121);

  // =================== INTERACTIVE COLORS ===================

  /// Button background - default state
  Color get buttonBackground =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  /// Button background - hover state
  Color get buttonBackgroundHover =>
      isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  /// Button background - pressed state
  Color get buttonBackgroundPressed =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFF94A3B8);

  /// Button background - disabled state
  Color get buttonBackgroundDisabled =>
      isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

  /// Input field background
  Color get inputBackground =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  /// Input field background - focused
  Color get inputBackgroundFocused =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFFAFAFA);

  /// Input field background - disabled
  Color get inputBackgroundDisabled =>
      isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF5F5F5);

  // =================== BRAND COLORS ===================

  /// Primary brand color variants
  Color get primaryLight =>
      isDarkMode ? const Color(0xFFA78BFA) : const Color(0xFF8B5DFF);
  Color get primaryDark =>
      isDarkMode ? const Color(0xFF6D28D9) : const Color(0xFF5B21B6);
  Color get onPrimaryColor =>
      isDarkMode ? const Color(0xFFF1F5F9) : const Color(0xFF111827);

  /// Secondary brand color variants
  Color get secondaryLight =>
      isDarkMode ? const Color(0xFF34D399) : const Color(0xFF34D399);
  Color get secondaryDark =>
      isDarkMode ? const Color(0xFF047857) : const Color(0xFF047857);

  // =================== SEMANTIC COLORS ===================

  /// Online/Active status
  Color get statusOnline =>
      isDarkMode ? const Color(0xFF10B981) : const Color(0xFF22C55E);

  /// Offline/Inactive status
  Color get statusOffline =>
      isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

  /// Away status
  Color get statusAway =>
      isDarkMode ? const Color(0xFFF59E0B) : const Color(0xFFEAB308);

  /// Busy/Do not disturb status
  Color get statusBusy =>
      isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFDC2626);

  /// Favorite/Like color
  Color get favoriteColor =>
      isDarkMode ? const Color(0xFFFF6B9D) : const Color(0xFFE91E63);

  /// Rating/Star color
  Color get ratingColor =>
      isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFEAB308);

  /// New/Unread indicator
  Color get newIndicator =>
      isDarkMode ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);

  /// Verified badge color
  Color get verifiedColor =>
      isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669);

  // =================== SHADOW COLORS ===================

  /// Light shadow color
  Color get shadowLight => isDarkMode
      ? Colors.black.withValues(alpha: 0.1)
      : Colors.grey.shade200.withValues(alpha: 0.5);

  /// Medium shadow color
  Color get shadowMedium => isDarkMode
      ? Colors.black.withValues(alpha: 0.2)
      : Colors.grey.shade300.withValues(alpha: 0.7);

  /// Dark shadow color
  Color get shadowDark => isDarkMode
      ? Colors.black.withValues(alpha: 0.3)
      : Colors.grey.shade400.withValues(alpha: 0.9);

  // =================== SHADOWS AND EFFECTS ===================

  /// Primary shadow (cached)
  List<BoxShadow> get primaryShadow => _getCached(
        'primaryShadow',
        () => [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey.shade300)
                .withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Elevated shadow (cached)
  List<BoxShadow> get elevatedShadow => _getCached(
        'elevatedShadow',
        () => [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey.shade400)
                .withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Subtle shadow for minimal elevation (cached)
  List<BoxShadow> get subtleShadow => _getCached(
        'subtleShadow',
        () => [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey.shade200)
                .withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// Glass morphism effect
  BoxDecoration get glassMorphism => BoxDecoration(
        color:
            (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey.shade300)
                .withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Enhanced glass morphism with stronger effects
  BoxDecoration get enhancedGlassMorphism => BoxDecoration(
        color:
            (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDarkMode ? Colors.white : Colors.black)
              .withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: elevatedShadow,
      );

  // =================== CONDITIONAL COLORS ===================

  /// Get color based on theme mode
  Color conditionalColor({
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode ? darkColor : lightColor;
  }

  /// Get gradient based on theme mode
  LinearGradient conditionalGradient({
    required LinearGradient lightGradient,
    required LinearGradient darkGradient,
  }) {
    return isDarkMode ? darkGradient : lightGradient;
  }

  // =================== COLOR MANIPULATION METHODS ===================

  /// Apply alpha to a color
  Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha.clamp(0.0, 1.0));
  }

  /// Lighten a color by the specified amount
  Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken a color by the specified amount
  Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // =================== HELPER METHODS ===================

  /// Get theme-aware text color for backgrounds
  Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : Colors.white;
  }

  /// Get contrasting color for better readability
  Color getContrastingColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Apply alpha to any color while maintaining theme consistency
  Color withThemeAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  /// Get color for user type (cached)
  Color getUserTypeColor(UserRole userRole) {
    return _getCached('userType_${userRole.name}', () {
      switch (userRole) {
        case UserRole.tailor:
          return isDarkMode ? successColor : successLight;
        case UserRole.customer:
          return isDarkMode ? infoColor : infoLight;
        case UserRole.admin:
          return isDarkMode ? warningColor : warningLight;
      }
    });
  }

  // =================== PERFORMANCE UTILITIES ===================

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'enabled': _cacheEnabled,
      'entries': _cache.length,
      'keys': _cache.keys.toList(),
      'memory_estimate_kb': (_cache.length * 0.1).toStringAsFixed(2),
    };
  }

  /// Preload commonly used theme properties
  void preloadCommonProperties() {
    final timer = PerformanceTimer('Theme Properties Preload');

    // Preload colors
    backgroundColor;
    textPrimary;
    textSecondary;
    primaryColor;
    successColor;

    // Preload gradients
    primaryGradient;
    backgroundGradient;

    // Preload shadows
    primaryShadow;

    timer.finish();
    DebugLogger.performance('Theme properties preloaded');
  }

  // =================== DEBUG UTILITIES ===================

  /// Log current theme information
  void logThemeInfo() {
    DebugLogger.ui('Theme mode: ${isDarkMode ? 'dark' : 'light'}');
    DebugLogger.ui('Primary color: $primaryColor');
    DebugLogger.ui('Cache stats: ${getCacheStats()}');
  }

  /// Log gradient information for debugging
  void logGradientInfo() {
    debugPrint('🌈 ThemeManager Gradients:');
    debugPrint('  === CORE GRADIENTS ===');
    debugPrint('  - Primary: ${primaryGradient.colors}');
    debugPrint('  - Secondary: ${secondaryGradient.colors}');
    debugPrint('  - Background: ${backgroundGradient.colors}');
    debugPrint('  - Surface: ${surfaceGradient.colors}');
    debugPrint('  - Neutral: ${neutralGradient.colors}');

    debugPrint('  === STATUS GRADIENTS ===');
    debugPrint('  - Success: ${successGradient.colors}');
    debugPrint('  - Warning: ${warningGradient.colors}');
    debugPrint('  - Error: ${errorGradient.colors}');
    debugPrint('  - Info: ${infoGradient.colors}');

    debugPrint('  === ACCENT GRADIENTS ===');
    debugPrint('  - Accent 1 (Purple): ${accent1Gradient.colors}');
    debugPrint('  - Accent 2 (Pink): ${accent2Gradient.colors}');
    debugPrint('  - Accent 3 (Teal): ${accent3Gradient.colors}');
    debugPrint('  - Accent 4 (Orange): ${accent4Gradient.colors}');

    debugPrint('  === SPECIAL GRADIENTS ===');
    debugPrint('  - Glass: ${glassGradient.colors}');
    debugPrint('  - Shimmer: ${shimmerGradient.colors}');
  }

  /// Log all color information
  void logAllColors() {
    debugPrint('🎨 ThemeManager Color Palette:');
    debugPrint('  === BRAND COLORS ===');
    debugPrint('  - Primary: $primaryColor');
    debugPrint('  - Primary Light: $primaryLight');
    debugPrint('  - Primary Dark: $primaryDark');
    debugPrint('  - Secondary: $secondaryColor');
    debugPrint('  - Secondary Light: $secondaryLight');
    debugPrint('  - Secondary Dark: $secondaryDark');

    debugPrint('  === BACKGROUND COLORS ===');
    debugPrint('  - Background: $backgroundColor');
    debugPrint('  - Background Secondary: $backgroundSecondary');
    debugPrint('  - Background Tertiary: $backgroundTertiary');
    debugPrint('  - Surface: $surfaceColor');
    debugPrint('  - Surface Elevated: $surfaceElevated');
    debugPrint('  - Card Background: $cardBackground');
    debugPrint('  - Modal Background: $modalBackground');

    debugPrint('  === TEXT COLORS ===');
    debugPrint('  - Text Primary: $textPrimary');
    debugPrint('  - Text Secondary: $textSecondary');
    debugPrint('  - Text Tertiary: $textTertiary');
    debugPrint('  - Text Quaternary: $textQuaternary');
    debugPrint('  - Text Disabled: $textDisabled');
    debugPrint('  - Text Inverted: $textInverted');

    debugPrint('  === BORDER COLORS ===');
    debugPrint('  - Border: $borderColor');
    debugPrint('  - Border Secondary: $borderSecondary');
    debugPrint('  - Border Focus: $borderFocus');
    debugPrint('  - Divider: $dividerColor');

    debugPrint('  === STATUS COLORS ===');
    debugPrint(
      '  - Success: $successColor (Light: $successLight, Dark: $successDark)',
    );
    debugPrint(
      '  - Warning: $warningColor (Light: $warningLight, Dark: $warningDark)',
    );
    debugPrint('  - Error: $errorColor (Light: $errorLight, Dark: $errorDark)');
    debugPrint('  - Info: $infoColor (Light: $infoLight, Dark: $infoDark)');

    debugPrint('  === ACCENT COLORS ===');
    debugPrint('  - Accent 1 (Purple): $accent1');
    debugPrint('  - Accent 2 (Pink): $accent2');
    debugPrint('  - Accent 3 (Teal): $accent3');
    debugPrint('  - Accent 4 (Orange): $accent4');
    debugPrint('  - Accent 5 (Indigo): $accent5');

    debugPrint('  === SEMANTIC COLORS ===');
    debugPrint('  - Status Online: $statusOnline');
    debugPrint('  - Status Offline: $statusOffline');
    debugPrint('  - Status Away: $statusAway');
    debugPrint('  - Status Busy: $statusBusy');
    debugPrint('  - Favorite: $favoriteColor');
    debugPrint('  - Rating: $ratingColor');
    debugPrint('  - New Indicator: $newIndicator');
    debugPrint('  - Verified: $verifiedColor');

    debugPrint('  === INTERACTIVE COLORS ===');
    debugPrint('  - Button Background: $buttonBackground');
    debugPrint('  - Button Hover: $buttonBackgroundHover');
    debugPrint('  - Button Pressed: $buttonBackgroundPressed');
    debugPrint('  - Button Disabled: $buttonBackgroundDisabled');
    debugPrint('  - Input Background: $inputBackground');
    debugPrint('  - Input Focused: $inputBackgroundFocused');
    debugPrint('  - Input Disabled: $inputBackgroundDisabled');
  }

  /// Log comprehensive typography information for debugging
  void logTypographyInfo() {
    debugPrint('🔤 ======== SOUR GUMMY TYPOGRAPHY DEBUG ========');
    debugPrint('🔤 Primary Font Family: $fontFamilyPrimary');
    debugPrint('🔤 Expanded Font Family: $fontFamilyExpanded');
    debugPrint('🔤 SemiExpanded Font Family: $fontFamilySemiExpanded');
    debugPrint(
      '🔤 Theme Default Font: ${theme.textTheme.bodyMedium?.fontFamily ?? 'System Default'}',
    );
    debugPrint(
      '🔤 Display Large: ${theme.textTheme.displayLarge?.fontFamily} - ${theme.textTheme.displayLarge?.fontSize}sp',
    );
    debugPrint(
      '🔤 Headline Large: ${theme.textTheme.headlineLarge?.fontFamily} - ${theme.textTheme.headlineLarge?.fontSize}sp',
    );
    debugPrint(
      '🔤 Title Large: ${theme.textTheme.titleLarge?.fontFamily} - ${theme.textTheme.titleLarge?.fontSize}sp',
    );
    debugPrint(
      '🔤 Body Large: ${theme.textTheme.bodyLarge?.fontFamily} - ${theme.textTheme.bodyLarge?.fontSize}sp',
    );
    debugPrint(
      '🔤 Label Large: ${theme.textTheme.labelLarge?.fontFamily} - ${theme.textTheme.labelLarge?.fontSize}sp',
    );
    debugPrint(
      '🔤 Custom Heading XL: ${customHeadingXL.fontFamily} - ${customHeadingXL.fontSize}sp',
    );
    debugPrint(
      '🔤 Custom Logo: ${customHeadingLogo.fontFamily} - ${customHeadingLogo.fontSize}sp',
    );
    debugPrint(
      '🔤 Custom Button: ${customButtonText.fontFamily} - ${customButtonText.fontSize}sp',
    );
    debugPrint('🔤 =============================================');
  }

  /// Log all typography styles with their properties
  void logAllTypographyStyles() {
    debugPrint('🔤 ========= ALL SOUR GUMMY TYPOGRAPHY STYLES =========');

    // Display styles
    debugPrint('📱 DISPLAY STYLES (SourGummy Expanded):');
    debugPrint(
      '  - Display Large: ${theme.textTheme.displayLarge?.fontFamily} | ${theme.textTheme.displayLarge?.fontSize}sp | ${theme.textTheme.displayLarge?.fontWeight}',
    );
    debugPrint(
      '  - Display Medium: ${theme.textTheme.displayMedium?.fontFamily} | ${theme.textTheme.displayMedium?.fontSize}sp | ${theme.textTheme.displayMedium?.fontWeight}',
    );
    debugPrint(
      '  - Display Small: ${theme.textTheme.displaySmall?.fontFamily} | ${theme.textTheme.displaySmall?.fontSize}sp | ${theme.textTheme.displaySmall?.fontWeight}',
    );

    // Headline styles
    debugPrint('📰 HEADLINE STYLES (SourGummy SemiExpanded):');
    debugPrint(
      '  - Headline Large: ${theme.textTheme.headlineLarge?.fontFamily} | ${theme.textTheme.headlineLarge?.fontSize}sp | ${theme.textTheme.headlineLarge?.fontWeight}',
    );
    debugPrint(
      '  - Headline Medium: ${theme.textTheme.headlineMedium?.fontFamily} | ${theme.textTheme.headlineMedium?.fontSize}sp | ${theme.textTheme.headlineMedium?.fontWeight}',
    );
    debugPrint(
      '  - Headline Small: ${theme.textTheme.headlineSmall?.fontFamily} | ${theme.textTheme.headlineSmall?.fontSize}sp | ${theme.textTheme.headlineSmall?.fontWeight}',
    );

    // Title styles
    debugPrint('🏷️ TITLE STYLES (SourGummy Primary):');
    debugPrint(
      '  - Title Large: ${theme.textTheme.titleLarge?.fontFamily} | ${theme.textTheme.titleLarge?.fontSize}sp | ${theme.textTheme.titleLarge?.fontWeight}',
    );
    debugPrint(
      '  - Title Medium: ${theme.textTheme.titleMedium?.fontFamily} | ${theme.textTheme.titleMedium?.fontSize}sp | ${theme.textTheme.titleMedium?.fontWeight}',
    );
    debugPrint(
      '  - Title Small: ${theme.textTheme.titleSmall?.fontFamily} | ${theme.textTheme.titleSmall?.fontSize}sp | ${theme.textTheme.titleSmall?.fontWeight}',
    );

    // Body styles
    debugPrint('📝 BODY STYLES (SourGummy Primary):');
    debugPrint(
      '  - Body Large: ${theme.textTheme.bodyLarge?.fontFamily} | ${theme.textTheme.bodyLarge?.fontSize}sp | ${theme.textTheme.bodyLarge?.fontWeight}',
    );
    debugPrint(
      '  - Body Medium: ${theme.textTheme.bodyMedium?.fontFamily} | ${theme.textTheme.bodyMedium?.fontSize}sp | ${theme.textTheme.bodyMedium?.fontWeight}',
    );
    debugPrint(
      '  - Body Small: ${theme.textTheme.bodySmall?.fontFamily} | ${theme.textTheme.bodySmall?.fontSize}sp | ${theme.textTheme.bodySmall?.fontWeight}',
    );

    // Label styles
    debugPrint('🏷️ LABEL STYLES (SourGummy Primary):');
    debugPrint(
      '  - Label Large: ${theme.textTheme.labelLarge?.fontFamily} | ${theme.textTheme.labelLarge?.fontSize}sp | ${theme.textTheme.labelLarge?.fontWeight}',
    );
    debugPrint(
      '  - Label Medium: ${theme.textTheme.labelMedium?.fontFamily} | ${theme.textTheme.labelMedium?.fontSize}sp | ${theme.textTheme.labelMedium?.fontWeight}',
    );
    debugPrint(
      '  - Label Small: ${theme.textTheme.labelSmall?.fontFamily} | ${theme.textTheme.labelSmall?.fontSize}sp | ${theme.textTheme.labelSmall?.fontWeight}',
    );

    // Custom styles
    debugPrint('🎨 CUSTOM SOUR GUMMY STYLES:');
    debugPrint(
      '  - Custom Heading XL: ${customHeadingXL.fontFamily} | ${customHeadingXL.fontSize}sp | ${customHeadingXL.fontWeight}',
    );
    debugPrint(
      '  - Custom Logo: ${customHeadingLogo.fontFamily} | ${customHeadingLogo.fontSize}sp | ${customHeadingLogo.fontWeight}',
    );
    debugPrint(
      '  - Custom Button: ${customButtonText.fontFamily} | ${customButtonText.fontSize}sp | ${customButtonText.fontWeight}',
    );
    debugPrint(
      '  - Custom Caption: ${customCaption.fontFamily} | ${customCaption.fontSize}sp | ${customCaption.fontWeight}',
    );
    debugPrint(
      '  - Custom Card Title: ${customCardTitle.fontFamily} | ${customCardTitle.fontSize}sp | ${customCardTitle.fontWeight}',
    );
    debugPrint(
      '  - Custom Card Subtitle: ${customCardSubtitle.fontFamily} | ${customCardSubtitle.fontSize}sp | ${customCardSubtitle.fontWeight}',
    );

    debugPrint('🔤 ====================================================');
  }
}

/// Performance timer utility for theme operations
class PerformanceTimer {
  final String _operation;
  final DateTime _startTime;

  PerformanceTimer(this._operation) : _startTime = DateTime.now();

  void finish() {
    final duration = DateTime.now().difference(_startTime);
    DebugLogger.performance('$_operation took ${duration.inMilliseconds}ms');
  }
}

/// Extension for easy theme access
extension ThemeExtension on BuildContext {
  ThemeManager get theme => ThemeManager.of(this);
}
