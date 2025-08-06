import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tailorapp/core/icons/prbal_icons.dart';
import 'package:tailorapp/core/theme/theme_manager.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/view/language_selection/model/language_selection_model.dart';

/// Language Item Widget - Individual language selection item
///
/// **FEATURES:**
/// - Modern card design with animations
/// - Flag emoji with proper styling
/// - Native script language names
/// - Regional and script metadata
/// - Selection state indicators
/// - Haptic feedback on interaction
class LanguageItemWidget extends StatelessWidget {
  final LanguageItemModel language;
  final bool isLast;
  final VoidCallback onTap;
  final Duration animationDelay;

  const LanguageItemWidget({
    super.key,
    required this.language,
    required this.isLast,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              DebugLogger.info(
                'LanguageItemWidget: Language tapped: ${language.displayName}',
              );

              // Provide haptic feedback
              HapticFeedback.lightImpact();

              // Execute callback
              onTap();
            },
            borderRadius: BorderRadius.circular(16.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: language.isSelected
                    ? ThemeManager.of(context).primaryColor.withValues(alpha: 0.1)
                    : ThemeManager.of(context).surfaceColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: language.isSelected
                      ? ThemeManager.of(context).primaryColor
                      : ThemeManager.of(context).borderColor,
                  width: language.isSelected ? 2 : 1,
                ),
                boxShadow: language.isSelected
                    ? [
                        BoxShadow(
                          color: ThemeManager.of(context).primaryColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  // Flag container with modern styling
                  _buildFlagContainer(context),
                  SizedBox(width: 16.w),

                  // Language information
                  Expanded(child: _buildLanguageInfo(context)),
                  SizedBox(width: 12.w),

                  // Selection indicator
                  _buildSelectionIndicator(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build flag container with styling
  Widget _buildFlagContainer(BuildContext context) {
    return Container(
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
          language.flag,
          style: TextStyle(fontSize: 24.sp),
        ),
      ),
    );
  }

  /// Build language name and metadata information
  Widget _buildLanguageInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language display name with native script
        Text(
          language.displayName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: language.isSelected ? ThemeManager.of(context).primaryColor : ThemeManager.of(context).textPrimary,
          ),
        ),
        SizedBox(height: 4.h),

        // Language metadata (region and script)
        Row(
          children: [
            // Region tag
            _buildMetadataTag(
              context,
              language.region,
            ),
            SizedBox(width: 8.w),

            // Script tag
            _buildMetadataTag(
              context,
              language.script,
            ),
          ],
        ),
      ],
    );
  }

  /// Build metadata tag (region/script)
  Widget _buildMetadataTag(BuildContext context, String text) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 2.h,
        ),
        decoration: BoxDecoration(
          color: ThemeManager.of(context).textTertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: ThemeManager.of(context).textTertiary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  /// Build selection indicator with animation
  Widget _buildSelectionIndicator(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: language.isSelected ? ThemeManager.of(context).primaryColor : Colors.transparent,
        border: Border.all(
          color: language.isSelected ? ThemeManager.of(context).primaryColor : ThemeManager.of(context).textTertiary,
          width: 2,
        ),
      ),
      child: language.isSelected
          ? Icon(
              Prbal.check,
              color: Colors.white,
              size: 16.sp,
            )
          : null,
    );
  }
}
