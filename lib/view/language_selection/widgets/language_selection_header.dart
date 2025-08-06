import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tailorapp/core/icons/prbal_icons.dart';
import 'package:tailorapp/core/theme/theme_manager.dart';
import 'package:tailorapp/core/localization/project_locales.dart';
import 'package:tailorapp/product/lang/locale_keys.g.dart';

/// Language Selection Header Widget
///
/// **FEATURES:**
/// - App branding with logo and title
/// - Language statistics display
/// - Multilingual content support
/// - Theme-aware styling
class LanguageSelectionHeader extends StatelessWidget {
  const LanguageSelectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
                    LocaleKeys.localization_languageSelection_title.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: ThemeManager.of(context).textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    LocaleKeys.localization_languageSelection_subtitle.tr(),
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
                      LocaleKeys.localization_availableLanguages.tr(),
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
}
