import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/view/language_selection/model/language_selection_model.dart';
import 'package:tailorapp/view/language_selection/widgets/language_item_widget.dart';

/// Language List Widget - Displays all available languages
///
/// **FEATURES:**
/// - Scrollable list of language options
/// - Staggered animations for smooth entrance
/// - Proper selection handling
/// - Performance optimized for large lists
class LanguageListWidget extends StatelessWidget {
  final List<LanguageItemModel> languages;
  final Function(LanguageItemModel) onLanguageSelect;

  const LanguageListWidget({
    super.key,
    required this.languages,
    required this.onLanguageSelect,
  });

  @override
  Widget build(BuildContext context) {
    DebugLogger.info(
      'LanguageListWidget: Building list with ${languages.length} languages',
    );

    if (languages.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildLanguageList();
  }

  /// Build the main language list
  Widget _buildLanguageList() {
    return Column(
      children: [
        // Languages list
        ...languages.asMap().entries.map((entry) {
          final index = entry.key;
          final language = entry.value;
          final isLast = index == languages.length - 1;

          return LanguageItemWidget(
            key: ValueKey(language.locale.toString()),
            language: language,
            isLast: isLast,
            animationDelay: Duration(milliseconds: index * 100),
            onTap: () => onLanguageSelect(language),
          );
        }),
      ],
    );
  }

  /// Build empty state when no languages available
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.language,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No languages available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your app configuration',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
