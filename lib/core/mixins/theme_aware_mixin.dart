import 'package:flutter/material.dart';
import 'package:tailorapp/core/services/theme_manager.dart';

/// Mixin that provides theme-aware functionality to widgets
///
/// This mixin gives widgets easy access to ThemeManager functionality
/// and common theme-related operations without needing to manually
/// call ThemeManager.of(context) repeatedly.
mixin ThemeAwareMixin<T extends StatefulWidget> on State<T> {
  /// Get ThemeManager instance
  ThemeManager get themeManager => ThemeManager.of(context);

  /// Quick access to common theme properties
  bool get isDarkMode => themeManager.isDarkMode;
  bool get isLightMode => themeManager.isLightMode;

  // =============================================================================
  // COLORS
  // =============================================================================

  /// Primary colors
  Color get primaryColor => themeManager.primaryColor;
  Color get primaryLight => themeManager.primaryLight;
  Color get primaryDark => themeManager.primaryDark;
  Color get secondaryColor => themeManager.secondaryColor;

  /// Accent colors
  Color get accent1 => themeManager.accent1;
  Color get accent2 => themeManager.accent2;
  Color get accent3 => themeManager.accent3;
  Color get accent4 => themeManager.accent4;
  Color get accent5 => themeManager.accent5;

  /// Status colors
  Color get successColor => themeManager.successColor;
  Color get successLight => themeManager.successLight;
  Color get infoColor => themeManager.infoColor;
  Color get infoLight => themeManager.infoLight;
  Color get warningColor => themeManager.warningColor;
  Color get warningLight => themeManager.warningLight;
  Color get errorColor => themeManager.errorColor;
  Color get errorLight => themeManager.errorLight;

  /// Background colors
  Color get backgroundColor => themeManager.backgroundColor;
  Color get backgroundSecondary => themeManager.backgroundSecondary;
  Color get surfaceColor => themeManager.surfaceColor;
  Color get surfaceElevated => themeManager.surfaceElevated;
  Color get cardBackground => themeManager.cardBackground;
  Color get modalBackground => themeManager.modalBackground;

  /// Text colors
  Color get textPrimary => themeManager.textPrimary;
  Color get textSecondary => themeManager.textSecondary;
  Color get textTertiary => themeManager.textTertiary;
  Color get textQuaternary => themeManager.textQuaternary;

  /// Border colors
  Color get borderColor => themeManager.borderColor;
  Color get borderSecondary => themeManager.borderSecondary;

  // =============================================================================
  // GRADIENTS
  // =============================================================================

  /// Common gradients
  LinearGradient get primaryGradient => themeManager.primaryGradient;
  LinearGradient get secondaryGradient => themeManager.secondaryGradient;
  LinearGradient get successGradient => themeManager.successGradient;
  LinearGradient get infoGradient => themeManager.infoGradient;
  LinearGradient get warningGradient => themeManager.warningGradient;
  LinearGradient get errorGradient => themeManager.errorGradient;
  LinearGradient get accent1Gradient => themeManager.accent1Gradient;
  LinearGradient get accent2Gradient => themeManager.accent2Gradient;
  LinearGradient get accent3Gradient => themeManager.accent3Gradient;

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  /// Get conditional color based on theme
  Color conditionalColor({
    required Color lightColor,
    required Color darkColor,
  }) {
    return themeManager.conditionalColor(
      lightColor: lightColor,
      darkColor: darkColor,
    );
  }

  /// Get conditional gradient based on theme
  LinearGradient conditionalGradient({
    required LinearGradient lightGradient,
    required LinearGradient darkGradient,
  }) {
    return themeManager.conditionalGradient(
      lightGradient: lightGradient,
      darkGradient: darkGradient,
    );
  }

  /// Get contrasting color for the given color
  Color getContrastingColor(Color color) {
    return themeManager.getContrastingColor(color);
  }

  /// Get appropriate text color for a background color
  Color getTextColorForBackground(Color backgroundColor) {
    return themeManager.getTextColorForBackground(backgroundColor);
  }

  /// Apply alpha to a color
  Color withAlpha(Color color, double alpha) {
    return themeManager.withAlpha(color, alpha);
  }

  /// Lighten a color
  Color lighten(Color color, [double amount = 0.1]) {
    return themeManager.lighten(color, amount);
  }

  /// Darken a color
  Color darken(Color color, [double amount = 0.1]) {
    return themeManager.darken(color, amount);
  }

  // =============================================================================
  // COMMON UI HELPERS
  // =============================================================================

  /// Create a themed container decoration
  BoxDecoration themedContainerDecoration({
    Color? color,
    LinearGradient? gradient,
    double borderRadius = 8.0,
    Color? borderColor,
    double borderWidth = 1.0,
    bool elevated = false,
  }) {
    return BoxDecoration(
      color: color ?? (elevated ? surfaceElevated : surfaceColor),
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      boxShadow: elevated
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  /// Create themed text style
  TextStyle themedTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Create themed button style
  ButtonStyle themedButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    double borderRadius = 8.0,
    bool outlined = false,
  }) {
    return outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? primaryColor,
            side: BorderSide(color: backgroundColor ?? primaryColor),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? primaryColor,
            foregroundColor: foregroundColor ??
                getContrastingColor(backgroundColor ?? primaryColor),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          );
  }

  /// Create themed card
  Widget themedCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 12.0,
    bool elevated = true,
    Color? color,
    LinearGradient? gradient,
  }) {
    return Container(
      margin: margin,
      decoration: themedContainerDecoration(
        color: color,
        gradient: gradient,
        borderRadius: borderRadius,
        elevated: elevated,
      ),
      child: padding != null ? Padding(padding: padding, child: child) : child,
    );
  }

  /// Create themed divider
  Widget themedDivider({
    double? height,
    double? thickness,
    Color? color,
    double? indent,
    double? endIndent,
  }) {
    return Divider(
      height: height,
      thickness: thickness ?? 1.0,
      color: color ?? borderColor,
      indent: indent,
      endIndent: endIndent,
    );
  }

  /// Create themed icon
  Widget themedIcon(
    IconData icon, {
    double? size,
    Color? color,
  }) {
    return Icon(
      icon,
      size: size,
      color: color ?? textPrimary,
    );
  }

  /// Show themed snackbar
  void showThemedSnackBar(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? textPrimary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor ?? textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? surfaceElevated,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show themed success snackbar
  void showSuccessSnackBar(String message) {
    showThemedSnackBar(
      message,
      backgroundColor: successColor,
      textColor: getContrastingColor(successColor),
      icon: Icons.check_circle,
    );
  }

  /// Show themed error snackbar
  void showErrorSnackBar(String message) {
    showThemedSnackBar(
      message,
      backgroundColor: errorColor,
      textColor: getContrastingColor(errorColor),
      icon: Icons.error,
    );
  }

  /// Show themed warning snackbar
  void showWarningSnackBar(String message) {
    showThemedSnackBar(
      message,
      backgroundColor: warningColor,
      textColor: getContrastingColor(warningColor),
      icon: Icons.warning,
    );
  }

  /// Show themed info snackbar
  void showInfoSnackBar(String message) {
    showThemedSnackBar(
      message,
      backgroundColor: infoColor,
      textColor: getContrastingColor(infoColor),
      icon: Icons.info,
    );
  }
}
