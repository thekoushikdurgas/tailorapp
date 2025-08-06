import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Language Item Model - Represents a single language option
///
/// **FEATURES:**
/// - Complete language metadata including native names
/// - Flag emoji representations for visual appeal
/// - Regional and script information for context
/// - Locale object for system integration
class LanguageItemModel extends Equatable {
  final Locale locale;
  final String displayName;
  final String nativeName;
  final String flag;
  final String region;
  final String script;
  final String languageFamily;
  final bool isSelected;

  const LanguageItemModel({
    required this.locale,
    required this.displayName,
    required this.nativeName,
    required this.flag,
    required this.region,
    required this.script,
    required this.languageFamily,
    this.isSelected = false,
  });

  LanguageItemModel copyWith({
    Locale? locale,
    String? displayName,
    String? nativeName,
    String? flag,
    String? region,
    String? script,
    String? languageFamily,
    bool? isSelected,
  }) {
    return LanguageItemModel(
      locale: locale ?? this.locale,
      displayName: displayName ?? this.displayName,
      nativeName: nativeName ?? this.nativeName,
      flag: flag ?? this.flag,
      region: region ?? this.region,
      script: script ?? this.script,
      languageFamily: languageFamily ?? this.languageFamily,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        displayName,
        nativeName,
        flag,
        region,
        script,
        languageFamily,
        isSelected,
      ];
}

/// Language Selection State Model - Represents the complete state of language selection
///
/// **FEATURES:**
/// - List of all available language options
/// - Currently selected language tracking
/// - Application state tracking (applying, errors, etc.)
/// - Statistics about available languages
class LanguageSelectionStateModel extends Equatable {
  final List<LanguageItemModel> availableLanguages;
  final LanguageItemModel? selectedLanguage;
  final bool isApplying;
  final String? errorMessage;
  final String? successMessage;
  final int totalLanguages;
  final int totalIndianLanguages;
  final bool isInitialized;

  const LanguageSelectionStateModel({
    this.availableLanguages = const [],
    this.selectedLanguage,
    this.isApplying = false,
    this.errorMessage,
    this.successMessage,
    this.totalLanguages = 0,
    this.totalIndianLanguages = 0,
    this.isInitialized = false,
  });

  LanguageSelectionStateModel copyWith({
    List<LanguageItemModel>? availableLanguages,
    LanguageItemModel? selectedLanguage,
    bool? isApplying,
    String? errorMessage,
    String? successMessage,
    int? totalLanguages,
    int? totalIndianLanguages,
    bool? isInitialized,
  }) {
    return LanguageSelectionStateModel(
      availableLanguages: availableLanguages ?? this.availableLanguages,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isApplying: isApplying ?? this.isApplying,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      totalLanguages: totalLanguages ?? this.totalLanguages,
      totalIndianLanguages: totalIndianLanguages ?? this.totalIndianLanguages,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// Clear any error or success messages
  LanguageSelectionStateModel clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Get available languages sorted by priority (English first, then alphabetical)
  List<LanguageItemModel> get sortedLanguages {
    final languages = List<LanguageItemModel>.from(availableLanguages);

    languages.sort((a, b) {
      // English first
      if (a.locale.languageCode == 'en') return -1;
      if (b.locale.languageCode == 'en') return 1;

      // Then alphabetical by display name
      return a.displayName.compareTo(b.displayName);
    });

    return languages;
  }

  /// Check if a specific locale is selected
  bool isLocaleSelected(Locale locale) {
    return selectedLanguage?.locale == locale;
  }

  /// Get language statistics summary
  String get statisticsSummary {
    return '$totalLanguages languages ($totalIndianLanguages Indian)';
  }

  @override
  List<Object?> get props => [
        availableLanguages,
        selectedLanguage,
        isApplying,
        errorMessage,
        successMessage,
        totalLanguages,
        totalIndianLanguages,
        isInitialized,
      ];
}
