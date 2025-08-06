import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tailorapp/core/theme/theme_manager.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/mixins/theme_aware_mixin.dart';
import 'package:tailorapp/view/language_selection/cubit/language_selection_cubit.dart';
import 'package:tailorapp/view/language_selection/view-model/language_selection_view_model.dart';
import 'package:tailorapp/view/language_selection/widgets/language_selection_header.dart';
import 'package:tailorapp/view/language_selection/widgets/language_list_widget.dart';
import 'package:tailorapp/view/language_selection/widgets/language_action_buttons.dart';

/// Language Selection Screen - Refactored with Clean Architecture
///
/// **ARCHITECTURE:**
/// - Uses BLoC/Cubit for state management
/// - Modular widget structure with reusable components
/// - Separation of concerns with view-model for business logic
/// - Enhanced error handling and user feedback
/// - Theme-aware design with ThemeManager integration
///
/// **COMPONENTS:**
/// - LanguageSelectionHeader: App branding and language statistics
/// - LanguageListWidget: Scrollable list of language options
/// - LanguageActionButtons: Apply and skip buttons with states
/// - LanguageSelectionCubit: State management
/// - LanguageSelectionViewModel: Business logic
///
/// **FEATURES:**
/// - 10+ supported languages including Indian languages
/// - Smooth entrance animations with staggered timing
/// - Auto-detection of current device locale
/// - Comprehensive error handling and user feedback
/// - Haptic feedback for better user experience
/// - Proper navigation flow integration
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin, ThemeAwareMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late LanguageSelectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    DebugLogger.intro(
      'LanguageSelectionScreen: ====== INITIALIZING REFACTORED LANGUAGE SELECTION ======',
    );

    _viewModel = LanguageSelectionViewModel();
    _initializeAnimations();
  }

  @override
  void dispose() {
    DebugLogger.info('LanguageSelectionScreen: Disposing resources...');
    _animationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// Initialize entrance animations for smooth user experience
  void _initializeAnimations() {
    DebugLogger.info('LanguageSelectionScreen: Initializing animations...');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
    DebugLogger.success('LanguageSelectionScreen: Animations initialized');
  }

  @override
  Widget build(BuildContext context) {
    DebugLogger.info('LanguageSelectionScreen: Building UI...');

    return BlocProvider(
      create: (context) => LanguageSelectionCubit(),
      child: Scaffold(
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
      ),
    );
  }

  /// Build the main body content
  Widget _buildBody(BuildContext context) {
    return BlocConsumer<LanguageSelectionCubit, LanguageSelectionState>(
      listener: _handleStateChanges,
      builder: (context, state) {
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
                    // Header section
                    const LanguageSelectionHeader(),
                    SizedBox(height: 32.h),

                    // Content based on state
                    _buildStateContent(context, state),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Action buttons at bottom
            _buildActionButtons(context, state),
          ],
        );
      },
    );
  }

  /// Build content based on current state
  Widget _buildStateContent(
      BuildContext context, LanguageSelectionState state) {
    return switch (state) {
      LanguageSelectionLoading() => _buildLoadingState(),
      LanguageSelectionLoaded(:final data) => _buildLoadedState(context, data),
      LanguageSelectionApplying(:final data) =>
        _buildLoadedState(context, data),
      LanguageSelectionApplied(:final data) => _buildLoadedState(context, data),
      LanguageSelectionError(:final message) => _buildErrorState(message),
      LanguageSelectionInitial() => _buildLoadingState(),
      _ => _buildLoadingState(),
    };
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: ThemeManager.of(context).primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading languages...',
              style: TextStyle(
                fontSize: 16.sp,
                color: ThemeManager.of(context).textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loaded state with language list
  Widget _buildLoadedState(BuildContext context, data) {
    return LanguageListWidget(
      languages: data.sortedLanguages,
      onLanguageSelect: (language) {
        DebugLogger.info(
          'LanguageSelectionScreen: Language selected: ${language.displayName}',
        );

        _viewModel.provideHapticFeedback();
        context.read<LanguageSelectionCubit>().selectLanguage(language);
      },
    );
  }

  /// Build error state
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Languages',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _viewModel.getUserFriendlyErrorMessage(message),
              style: TextStyle(
                fontSize: 14.sp,
                color: ThemeManager.of(context).textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                context.read<LanguageSelectionCubit>().initializeLanguages();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action buttons based on state
  Widget _buildActionButtons(
      BuildContext context, LanguageSelectionState state) {
    final isApplying = state is LanguageSelectionApplying;
    final hasSelection = switch (state) {
      LanguageSelectionLoaded(:final data) => data.selectedLanguage != null,
      LanguageSelectionApplying(:final data) => data.selectedLanguage != null,
      LanguageSelectionApplied(:final data) => data.selectedLanguage != null,
      _ => false,
    };

    return LanguageActionButtons(
      isApplying: isApplying,
      isEnabled: hasSelection,
      onApply: () => _handleApplyAction(context),
      onSkip: () => _handleSkipAction(context),
    );
  }

  /// Handle state changes and show appropriate feedback
  void _handleStateChanges(BuildContext context, LanguageSelectionState state) {
    switch (state) {
      case LanguageSelectionApplied(:final successMessage):
        DebugLogger.success(
          'LanguageSelectionScreen: Language applied successfully',
        );

        _viewModel.provideHapticFeedback(isSuccess: true);
        _viewModel.showSuccessMessage(context, successMessage);

        // Navigate after short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && context.mounted) {
            _viewModel.navigateToNextScreen(context);
          }
        });
        break;

      case LanguageSelectionLoaded(:final data) when data.errorMessage != null:
        _viewModel.showErrorMessage(
          context,
          _viewModel.getUserFriendlyErrorMessage(data.errorMessage!),
        );
        break;

      case LanguageSelectionError(:final message):
        _viewModel.showErrorMessage(
          context,
          _viewModel.getUserFriendlyErrorMessage(message),
        );
        break;

      default:
        // No action needed for other states
        break;
    }
  }

  /// Handle apply action
  void _handleApplyAction(BuildContext context) {
    DebugLogger.info('LanguageSelectionScreen: Apply action triggered');

    final cubit = context.read<LanguageSelectionCubit>();
    final selectedLanguage = cubit.selectedLanguage;

    if (_viewModel.validateLanguageSelection(selectedLanguage)) {
      cubit.applyLanguageSelection(context);
    } else {
      _viewModel.showErrorMessage(
        context,
        'Please select a language before applying',
      );
    }
  }

  /// Handle skip action
  void _handleSkipAction(BuildContext context) {
    DebugLogger.info('LanguageSelectionScreen: Skip action triggered');
    _viewModel.handleSkipAction(context);
  }
}
