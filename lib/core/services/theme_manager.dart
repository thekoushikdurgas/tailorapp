import 'package:flutter/material.dart';
import 'package:tailorapp/core/services/debug_logger.dart';

/// Comprehensive Theme Manager for advanced theming capabilities
///
/// This class provides a centralized theme management system with support for:
/// - Dynamic color schemes
/// - Gradient systems
/// - Theme-aware colors
/// - Light/dark mode support
/// - Material Design 3 colors
/// - Custom color palettes for the Tailor app
class ThemeManager {
  final BuildContext context;

  const ThemeManager._(this.context);

  /// Get ThemeManager instance for the given context
  static ThemeManager of(BuildContext context) {
    return ThemeManager._(context);
  }

  /// Get current theme data
  ThemeData get theme => Theme.of(context);

  /// Check if dark mode is active
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Check if light mode is active
  bool get isLightMode => theme.brightness == Brightness.light;

  // =============================================================================
  // PRIMARY COLORS
  // =============================================================================

  /// Primary brand color for the Tailor app
  Color get primaryColor =>
      isDarkMode ? const Color(0xFF6C63FF) : const Color(0xFF6C63FF);

  /// Primary light variant
  Color get primaryLight =>
      isDarkMode ? const Color(0xFF9C94FF) : const Color(0xFF9C94FF);

  /// Primary dark variant
  Color get primaryDark =>
      isDarkMode ? const Color(0xFF3F37CC) : const Color(0xFF3F37CC);

  // =============================================================================
  // SECONDARY COLORS
  // =============================================================================

  /// Secondary brand color
  Color get secondaryColor =>
      isDarkMode ? const Color(0xFFFF6B6B) : const Color(0xFFFF6B6B);

  // =============================================================================
  // ACCENT COLORS
  // =============================================================================

  /// Accent color 1 - Teal
  Color get accent1 =>
      isDarkMode ? const Color(0xFF4ECDC4) : const Color(0xFF4ECDC4);

  /// Accent color 2 - Orange
  Color get accent2 =>
      isDarkMode ? const Color(0xFFFF9800) : const Color(0xFFFF9800);

  /// Accent color 3 - Purple
  Color get accent3 =>
      isDarkMode ? const Color(0xFFE91E63) : const Color(0xFFE91E63);

  /// Accent color 4 - Green
  Color get accent4 =>
      isDarkMode ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50);

  /// Accent color 5 - Blue
  Color get accent5 =>
      isDarkMode ? const Color(0xFF2196F3) : const Color(0xFF2196F3);

  // =============================================================================
  // STATUS COLORS
  // =============================================================================

  /// Success color
  Color get successColor =>
      isDarkMode ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50);

  /// Success light variant
  Color get successLight =>
      isDarkMode ? const Color(0xFF81C784) : const Color(0xFF81C784);

  /// Info color
  Color get infoColor =>
      isDarkMode ? const Color(0xFF2196F3) : const Color(0xFF2196F3);

  /// Info light variant
  Color get infoLight =>
      isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF64B5F6);

  /// Warning color
  Color get warningColor =>
      isDarkMode ? const Color(0xFFFF9800) : const Color(0xFFFF9800);

  /// Warning light variant
  Color get warningLight =>
      isDarkMode ? const Color(0xFFFFB74D) : const Color(0xFFFFB74D);

  /// Error color
  Color get errorColor =>
      isDarkMode ? const Color(0xFFF44336) : const Color(0xFFF44336);

  /// Error light variant
  Color get errorLight =>
      isDarkMode ? const Color(0xFFE57373) : const Color(0xFFE57373);

  // =============================================================================
  // BACKGROUND COLORS
  // =============================================================================

  /// Main background color
  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

  /// Secondary background color
  Color get backgroundSecondary =>
      isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);

  /// Surface color for cards, sheets, etc.
  Color get surfaceColor =>
      isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF);

  /// Elevated surface color
  Color get surfaceElevated =>
      isDarkMode ? const Color(0xFF383838) : const Color(0xFFFFFFFF);

  /// Card background
  Color get cardBackground =>
      isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF);

  /// Modal background
  Color get modalBackground =>
      isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF);

  // =============================================================================
  // TEXT COLORS
  // =============================================================================

  /// Primary text color
  Color get textPrimary =>
      isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);

  /// Secondary text color
  Color get textSecondary =>
      isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF666666);

  /// Tertiary text color
  Color get textTertiary =>
      isDarkMode ? const Color(0xFF808080) : const Color(0xFF999999);

  /// Quaternary text color
  Color get textQuaternary =>
      isDarkMode ? const Color(0xFF606060) : const Color(0xFFCCCCCC);

  // =============================================================================
  // BORDER COLORS
  // =============================================================================

  /// Primary border color
  Color get borderColor =>
      isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0);

  /// Secondary border color
  Color get borderSecondary =>
      isDarkMode ? const Color(0xFF606060) : const Color(0xFFCCCCCC);

  // =============================================================================
  // NEUTRAL COLORS
  // =============================================================================

  /// Neutral 100
  Color get neutral100 =>
      isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5);

  /// Neutral 200
  Color get neutral200 =>
      isDarkMode ? const Color(0xFF404040) : const Color(0xFFEEEEEE);

  /// Neutral 600
  Color get neutral600 =>
      isDarkMode ? const Color(0xFF909090) : const Color(0xFF757575);

  /// Neutral 700
  Color get neutral700 =>
      isDarkMode ? const Color(0xFF707070) : const Color(0xFF616161);

  // =============================================================================
  // GRADIENT SYSTEMS
  // =============================================================================

  /// Primary gradient
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryColor, primaryLight, accent1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Secondary gradient
  LinearGradient get secondaryGradient => LinearGradient(
        colors: [secondaryColor, warningColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Success gradient
  LinearGradient get successGradient => LinearGradient(
        colors: [successColor, successLight, accent4],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Info gradient
  LinearGradient get infoGradient => LinearGradient(
        colors: [infoColor, infoLight, accent5],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Warning gradient
  LinearGradient get warningGradient => LinearGradient(
        colors: [warningColor, warningLight, accent2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Error gradient
  LinearGradient get errorGradient => LinearGradient(
        colors: [errorColor, errorLight, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Accent gradients
  LinearGradient get accent1Gradient => LinearGradient(
        colors: [accent1, primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get accent2Gradient => LinearGradient(
        colors: [accent2, warningLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get accent3Gradient => LinearGradient(
        colors: [accent3, primaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // =============================================================================
  // CONDITIONAL HELPERS
  // =============================================================================

  /// Get conditional color based on theme
  Color conditionalColor({
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode ? darkColor : lightColor;
  }

  /// Get conditional gradient based on theme
  LinearGradient conditionalGradient({
    required LinearGradient lightGradient,
    required LinearGradient darkGradient,
  }) {
    return isDarkMode ? darkGradient : lightGradient;
  }

  /// Get contrasting color for the given color
  Color getContrastingColor(Color color) {
    // Calculate luminance
    final luminance = color.computeLuminance();

    // Return white for dark colors, black for light colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Get appropriate text color for a background color
  Color getTextColorForBackground(Color backgroundColor) {
    return getContrastingColor(backgroundColor);
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Apply alpha to a color
  Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha.clamp(0.0, 1.0));
  }

  /// Lighten a color
  Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken a color
  Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // =============================================================================
  // DEBUGGING HELPERS
  // =============================================================================

  /// Log gradient information
  void logGradientInfo() {
    DebugLogger.theme('Theme Manager Gradient Info:');
    DebugLogger.theme('  Primary: ${primaryGradient.colors.length} colors');
    DebugLogger.theme('  Success: ${successGradient.colors.length} colors');
    DebugLogger.theme('  Warning: ${warningGradient.colors.length} colors');
    DebugLogger.theme('  Error: ${errorGradient.colors.length} colors');
  }

  /// Log all colors
  void logAllColors() {
    DebugLogger.theme('Theme Manager Color Palette:');
    DebugLogger.theme('  Mode: ${isDarkMode ? 'Dark' : 'Light'}');
    DebugLogger.theme('  Primary: $primaryColor');
    DebugLogger.theme('  Secondary: $secondaryColor');
    DebugLogger.theme('  Success: $successColor');
    DebugLogger.theme('  Warning: $warningColor');
    DebugLogger.theme('  Error: $errorColor');
    DebugLogger.theme('  Background: $backgroundColor');
    DebugLogger.theme('  Surface: $surfaceColor');
    DebugLogger.theme('  Text Primary: $textPrimary');
    DebugLogger.theme('  Text Secondary: $textSecondary');
  }

  /// Get theme info as map
  Map<String, dynamic> getThemeInfo() {
    return {
      'isDarkMode': isDarkMode,
      'primaryColor': primaryColor.toString(),
      'secondaryColor': secondaryColor.toString(),
      'backgroundColor': backgroundColor.toString(),
      'textPrimary': textPrimary.toString(),
      'gradientCount': 8,
    };
  }
}
