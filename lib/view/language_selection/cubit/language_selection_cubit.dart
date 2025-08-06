import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tailorapp/core/localization/project_locales.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/view/language_selection/model/language_selection_model.dart';

/// Language Selection States
abstract class LanguageSelectionState extends Equatable {
  const LanguageSelectionState();

  @override
  List<Object?> get props => [];
}

class LanguageSelectionInitial extends LanguageSelectionState {
  const LanguageSelectionInitial();
}

class LanguageSelectionLoading extends LanguageSelectionState {
  const LanguageSelectionLoading();
}

class LanguageSelectionLoaded extends LanguageSelectionState {
  final LanguageSelectionStateModel data;

  const LanguageSelectionLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class LanguageSelectionError extends LanguageSelectionState {
  final String message;

  const LanguageSelectionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LanguageSelectionApplying extends LanguageSelectionState {
  final LanguageSelectionStateModel data;

  const LanguageSelectionApplying({required this.data});

  @override
  List<Object?> get props => [data];
}

class LanguageSelectionApplied extends LanguageSelectionState {
  final LanguageSelectionStateModel data;
  final String successMessage;

  const LanguageSelectionApplied({
    required this.data,
    required this.successMessage,
  });

  @override
  List<Object?> get props => [data, successMessage];
}

/// Language Selection Cubit - State Management for Language Selection
///
/// **RESPONSIBILITIES:**
/// - Manage language selection state
/// - Handle language initialization and detection
/// - Apply language changes with proper validation
/// - Coordinate with storage and localization services
/// - Provide error handling and user feedback
class LanguageSelectionCubit extends Cubit<LanguageSelectionState> {
  LanguageSelectionCubit() : super(const LanguageSelectionInitial()) {
    DebugLogger.info('LanguageSelectionCubit: Initializing...');
    initializeLanguages();
  }

  /// Initialize available languages and detect current selection
  Future<void> initializeLanguages() async {
    DebugLogger.intro(
      'LanguageSelectionCubit: === INITIALIZING LANGUAGE SELECTION ===',
    );

    try {
      emit(const LanguageSelectionLoading());

      // Step 1: Create language items from ProjectLocales
      final availableLanguages = _createLanguageItems();
      DebugLogger.info(
        'LanguageSelectionCubit: Created ${availableLanguages.length} language items',
      );

      // Step 2: Detect current device locale
      final currentLocale = _detectCurrentLocale();
      DebugLogger.info(
        'LanguageSelectionCubit: Detected locale: ${ProjectLocales.getStringFromLocale(currentLocale)}',
      );

      // Step 3: Update selection state
      final selectedLanguage = availableLanguages.firstWhere(
        (lang) => lang.locale == currentLocale,
        orElse: () => availableLanguages.first, // Default to first (English)
      );

      final updatedLanguages = availableLanguages
          .map(
            (lang) => lang.copyWith(
              isSelected: lang.locale == selectedLanguage.locale,
            ),
          )
          .toList();

      // Step 4: Create state model
      final stateModel = LanguageSelectionStateModel(
        availableLanguages: updatedLanguages,
        selectedLanguage: selectedLanguage,
        totalLanguages: ProjectLocales.totalLanguages,
        totalIndianLanguages: ProjectLocales.totalIndianLanguages,
        isInitialized: true,
      );

      DebugLogger.success(
        'LanguageSelectionCubit: Initialization completed - Selected: ${selectedLanguage.displayName}',
      );

      emit(LanguageSelectionLoaded(data: stateModel));
    } catch (e, stackTrace) {
      DebugLogger.error(
        'LanguageSelectionCubit: Initialization failed: $e',
      );
      DebugLogger.debug(
        'LanguageSelectionCubit: Stack trace: $stackTrace',
      );

      emit(
        LanguageSelectionError(
          message: 'Failed to initialize languages: ${e.toString()}',
        ),
      );
    }
  }

  /// Create language items from ProjectLocales
  List<LanguageItemModel> _createLanguageItems() {
    DebugLogger.info('LanguageSelectionCubit: Creating language items...');

    final languageItems = ProjectLocales.supportedLocales.map((locale) {
      return LanguageItemModel(
        locale: locale,
        displayName: ProjectLocales.getDisplayName(locale),
        nativeName: ProjectLocales.getDisplayName(locale),
        flag: ProjectLocales.getFlagForLocale(locale),
        region: ProjectLocales.getRegionName(locale),
        script: ProjectLocales.getWritingScript(locale),
        languageFamily: ProjectLocales.getLanguageFamily(locale),
      );
    }).toList();

    DebugLogger.success(
      'LanguageSelectionCubit: Created ${languageItems.length} language items',
    );

    return languageItems;
  }

  /// Detect current locale with fallback logic
  Locale _detectCurrentLocale() {
    DebugLogger.info('LanguageSelectionCubit: Detecting current locale...');

    try {
      // Check if language is already saved
      final savedLanguage = HiveService.getSelectedLanguage();
      final savedLocale = ProjectLocales.getLocaleFromString(savedLanguage);
      if (savedLocale != null) {
        DebugLogger.success(
          'LanguageSelectionCubit: Using saved language: $savedLanguage',
        );
        return savedLocale;
      }

      // Fall back to default locale
      DebugLogger.info(
        'LanguageSelectionCubit: No saved language, using default',
      );
      return ProjectLocales.defaultLocale;
    } catch (e) {
      DebugLogger.error(
        'LanguageSelectionCubit: Error detecting locale: $e',
      );
      return ProjectLocales.defaultLocale;
    }
  }

  /// Select a language
  void selectLanguage(LanguageItemModel language) {
    DebugLogger.info(
      'LanguageSelectionCubit: Selecting language: ${language.displayName}',
    );

    final currentState = state;
    if (currentState is LanguageSelectionLoaded) {
      try {
        // Update selection state
        final updatedLanguages = currentState.data.availableLanguages
            .map(
              (lang) => lang.copyWith(
                isSelected: lang.locale == language.locale,
              ),
            )
            .toList();

        final updatedStateModel = currentState.data.copyWith(
          availableLanguages: updatedLanguages,
          selectedLanguage: language.copyWith(isSelected: true),
        );

        DebugLogger.success(
          'LanguageSelectionCubit: Language selected: ${language.displayName}',
        );

        emit(LanguageSelectionLoaded(data: updatedStateModel));
      } catch (e) {
        DebugLogger.error(
          'LanguageSelectionCubit: Error selecting language: $e',
        );

        final errorStateModel = currentState.data.copyWith(
          errorMessage: 'Failed to select language: ${e.toString()}',
        );

        emit(LanguageSelectionLoaded(data: errorStateModel));
      }
    }
  }

  /// Apply the selected language with proper storage and localization
  Future<void> applyLanguageSelection(BuildContext context) async {
    DebugLogger.intro(
      'LanguageSelectionCubit: === APPLYING LANGUAGE SELECTION ===',
    );

    final currentState = state;
    if (currentState is! LanguageSelectionLoaded) {
      DebugLogger.error(
        'LanguageSelectionCubit: Cannot apply - invalid state: ${currentState.runtimeType}',
      );
      return;
    }

    final selectedLanguage = currentState.data.selectedLanguage;
    if (selectedLanguage == null) {
      DebugLogger.error(
        'LanguageSelectionCubit: Cannot apply - no language selected',
      );

      final errorStateModel = currentState.data.copyWith(
        errorMessage: 'No language selected',
      );

      emit(LanguageSelectionLoaded(data: errorStateModel));
      return;
    }

    try {
      // Step 1: Emit applying state
      final applyingStateModel = currentState.data.copyWith(
        isApplying: true,
        errorMessage: null,
        successMessage: null,
      );

      emit(LanguageSelectionApplying(data: applyingStateModel));

      DebugLogger.info(
        'LanguageSelectionCubit: Applying ${selectedLanguage.displayName}...',
      );

      // Step 2: Save to storage
      final languageCode = ProjectLocales.getStringFromLocale(
        selectedLanguage.locale,
      );

      await HiveService.saveSelectedLanguage(languageCode);
      DebugLogger.success(
        'LanguageSelectionCubit: Language saved to storage: $languageCode',
      );

      // Step 3: Apply to EasyLocalization
      if (context.mounted) {
        await context.setLocale(selectedLanguage.locale);
        DebugLogger.success(
          'LanguageSelectionCubit: EasyLocalization locale updated',
        );
      }

      // Step 4: Emit success state
      final successStateModel = currentState.data.copyWith(
        isApplying: false,
        successMessage: 'Language changed to ${selectedLanguage.displayName}',
      );

      DebugLogger.success(
        'LanguageSelectionCubit: Language application completed successfully',
      );

      emit(
        LanguageSelectionApplied(
          data: successStateModel,
          successMessage: successStateModel.successMessage!,
        ),
      );
    } catch (e, stackTrace) {
      DebugLogger.error(
        'LanguageSelectionCubit: Failed to apply language: $e',
      );
      DebugLogger.debug(
        'LanguageSelectionCubit: Stack trace: $stackTrace',
      );

      // Emit error state
      final errorStateModel = currentState.data.copyWith(
        isApplying: false,
        errorMessage: 'Failed to apply language: ${e.toString()}',
      );

      emit(LanguageSelectionLoaded(data: errorStateModel));
    }
  }

  /// Set default language (English) and save
  Future<void> setDefaultLanguage() async {
    DebugLogger.info('LanguageSelectionCubit: Setting default language...');

    try {
      await HiveService.saveSelectedLanguage('en-US');
      DebugLogger.success(
        'LanguageSelectionCubit: Default language (English) saved',
      );
    } catch (e) {
      DebugLogger.error(
        'LanguageSelectionCubit: Failed to set default language: $e',
      );
    }
  }

  /// Clear any error or success messages
  void clearMessages() {
    final currentState = state;
    if (currentState is LanguageSelectionLoaded) {
      final clearedStateModel = currentState.data.clearMessages();
      emit(LanguageSelectionLoaded(data: clearedStateModel));
    }
  }

  /// Get current selected language
  LanguageItemModel? get selectedLanguage {
    final currentState = state;
    if (currentState is LanguageSelectionLoaded) {
      return currentState.data.selectedLanguage;
    }
    return null;
  }

  /// Check if a language is currently selected
  bool isLanguageSelected(Locale locale) {
    final currentState = state;
    if (currentState is LanguageSelectionLoaded) {
      return currentState.data.isLocaleSelected(locale);
    }
    return false;
  }

  /// Get language statistics
  String getLanguageStatistics() {
    final currentState = state;
    if (currentState is LanguageSelectionLoaded) {
      return currentState.data.statisticsSummary;
    }
    return '0 languages';
  }

  @override
  void onChange(Change<LanguageSelectionState> change) {
    super.onChange(change);
    DebugLogger.debug(
      'LanguageSelectionCubit: State changed from ${change.currentState.runtimeType} to ${change.nextState.runtimeType}',
    );
  }

  @override
  Future<void> close() {
    DebugLogger.info('LanguageSelectionCubit: Closing...');
    return super.close();
  }
}
