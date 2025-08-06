import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tailorapp/core/icons/prbal_icons.dart';
import 'package:tailorapp/core/theme/theme_manager.dart';
import 'package:tailorapp/product/lang/locale_keys.g.dart';

/// Enhanced footer widget for splash screen
///
/// **FEATURES:**
/// - Copyright information with localization
/// - Security verification indicator
/// - Version information display
/// - Responsive design and enhanced typography
/// - Theme-aware styling
class SplashFooter extends StatelessWidget {
  final bool showVersion;
  final bool showSecurity;
  final bool showCopyright;
  final String? customVersion;

  const SplashFooter({
    super.key,
    this.showVersion = true,
    this.showSecurity = true,
    this.showCopyright = true,
    this.customVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main footer row
          _buildMainFooterRow(context),

          // Additional info if needed
          if (showVersion && customVersion != null) ...[
            SizedBox(height: 8.h),
            _buildVersionInfo(context),
          ],
        ],
      ),
    );
  }

  /// Build the main footer row with copyright, security, and version
  Widget _buildMainFooterRow(BuildContext context) {
    final List<Widget> footerItems = [];

    // Copyright
    if (showCopyright) {
      footerItems.add(_buildCopyrightInfo(context));
    }

    // Security indicator
    if (showSecurity) {
      if (footerItems.isNotEmpty) {
        footerItems.add(SizedBox(width: 8.w));
      }
      footerItems.addAll([
        _buildSecurityIcon(context),
        SizedBox(width: 4.w),
        _buildSecurityText(context),
      ]);
    }

    // Version info
    if (showVersion) {
      if (footerItems.isNotEmpty) {
        footerItems.add(SizedBox(width: 8.w));
      }
      footerItems.add(_buildVersionText(context));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: footerItems,
    );
  }

  /// Build copyright information
  Widget _buildCopyrightInfo(BuildContext context) {
    return Flexible(
      child: Text(
        LocaleKeys.footer_copyright.tr(),
        style: TextStyle(
          fontFamily: ThemeManager.fontFamilyPrimary,
          fontSize: 9.sp,
          fontWeight: FontWeight.w300,
          color: ThemeManager.of(context).textDisabled,
          letterSpacing: 0.2,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Build security verification icon
  Widget _buildSecurityIcon(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: ThemeManager.of(context).verifiedColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(
        Prbal.shield,
        size: 12.sp,
        color: ThemeManager.of(context).verifiedColor,
      ),
    );
  }

  /// Build security text
  Widget _buildSecurityText(BuildContext context) {
    return Text(
      LocaleKeys.footer_secure.tr(),
      style: TextStyle(
        fontFamily: ThemeManager.fontFamilyPrimary,
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: ThemeManager.of(context).verifiedColor,
        letterSpacing: 0.4,
        shadows: [
          Shadow(
            color:
                ThemeManager.of(context).verifiedColor.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  /// Build version text
  Widget _buildVersionText(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: ThemeManager.of(context).surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: ThemeManager.of(context).borderColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        customVersion ?? LocaleKeys.footer_version.tr(),
        style: TextStyle(
          fontFamily: ThemeManager.fontFamilyPrimary,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: ThemeManager.of(context).textQuaternary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Build additional version information
  Widget _buildVersionInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: ThemeManager.of(context).surfaceElevated.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: ThemeManager.of(context).borderColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        customVersion!,
        style: TextStyle(
          fontFamily: ThemeManager.fontFamilyPrimary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: ThemeManager.of(context).textTertiary,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Minimal footer for simple use cases
class SplashSimpleFooter extends StatelessWidget {
  final String? message;

  const SplashSimpleFooter({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 12.h,
      ),
      child: Text(
        message ?? LocaleKeys.footer_copyright.tr(),
        style: TextStyle(
          fontFamily: ThemeManager.fontFamilyPrimary,
          fontSize: 9.sp,
          fontWeight: FontWeight.w300,
          color: ThemeManager.of(context).textDisabled,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Footer with custom branding
class SplashBrandedFooter extends StatelessWidget {
  final String brandName;
  final String? tagline;
  final IconData? brandIcon;

  const SplashBrandedFooter({
    super.key,
    required this.brandName,
    this.tagline,
    this.brandIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brand row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (brandIcon != null) ...[
                Icon(
                  brandIcon,
                  size: 16.sp,
                  color: ThemeManager.of(context).primaryColor,
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                brandName,
                style: TextStyle(
                  fontFamily: ThemeManager.fontFamilyPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: ThemeManager.of(context).primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // Tagline
          if (tagline != null) ...[
            SizedBox(height: 4.h),
            Text(
              tagline!,
              style: TextStyle(
                fontFamily: ThemeManager.fontFamilyPrimary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: ThemeManager.of(context).textSecondary,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
