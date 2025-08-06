import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tailorapp/core/icons/prbal_icons.dart';
import 'package:tailorapp/core/theme/theme_manager.dart';
import 'package:tailorapp/product/lang/locale_keys.g.dart';

/// Language Action Buttons - Apply and Skip buttons
///
/// **FEATURES:**
/// - Gradient apply button with proper states
/// - Outline skip button with theme colors
/// - Loading states and animations
/// - Proper spacing and responsive design
class LanguageActionButtons extends StatelessWidget {
  final VoidCallback onApply;
  final VoidCallback onSkip;
  final bool isApplying;
  final bool isEnabled;

  const LanguageActionButtons({
    super.key,
    required this.onApply,
    required this.onSkip,
    this.isApplying = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  /// Build the apply button with gradient styling
  Widget _buildApplyButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52.h,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? ThemeManager.of(context).primaryGradient
            : LinearGradient(
                colors: [
                  ThemeManager.of(context).textTertiary.withValues(alpha: 0.3),
                  ThemeManager.of(context).textTertiary.withValues(alpha: 0.3),
                ],
              ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isEnabled
              ? ThemeManager.of(context).primaryColor.withValues(alpha: 0.3)
              : ThemeManager.of(context).borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isApplying ? onApply : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: isApplying
                ? _buildLoadingIndicator()
                : _buildApplyButtonContent(context),
          ),
        ),
      ),
    );
  }

  /// Build apply button content
  Widget _buildApplyButtonContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Prbal.check,
          color:
              isEnabled ? Colors.white : ThemeManager.of(context).textTertiary,
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            LocaleKeys.localization_languageSelection_applyLanguage.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isEnabled
                  ? Colors.white
                  : ThemeManager.of(context).textTertiary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// Build loading indicator for apply button
  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20.w,
          height: 20.h,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          'Applying...',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Build the skip button with outline styling
  Widget _buildSkipButton(BuildContext context) {
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
          onTap: !isApplying ? onSkip : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Prbal.arrowRight,
                  color: !isApplying
                      ? ThemeManager.of(context).textSecondary
                      : ThemeManager.of(context).textTertiary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Flexible(
                  child: Text(
                    LocaleKeys.localization_languageSelection_skipSelection
                        .tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: !isApplying
                          ? ThemeManager.of(context).textSecondary
                          : ThemeManager.of(context).textTertiary,
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
    );
  }
}
