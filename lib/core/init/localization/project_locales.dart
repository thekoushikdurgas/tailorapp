import 'package:flutter/material.dart';
import 'package:tailorapp/core/services/debug_logger.dart';

/// Enhanced ProjectLocales with comprehensive Indian language support
///
/// Supports 10 languages total:
/// - English (en-US) - Primary/Default
/// - 9 Indian regional languages with native script display
class ProjectLocales {
  const ProjectLocales._();

  /// Comprehensive language mapping with native script names
  static final Map<Locale, String> localesMap = {
    // English - Primary/Default
    const Locale('en', 'US'): 'English',

    // Indian Languages with native script names
    const Locale('hi', 'IN'): 'हिन्दी (Hindi)',
    const Locale('bn', 'IN'): 'বাংলা (Bengali)',
    const Locale('te', 'IN'): 'తెలుగు (Telugu)',
    const Locale('mr', 'IN'): 'मराठी (Marathi)',
    const Locale('ta', 'IN'): 'தமிழ் (Tamil)',
    const Locale('gu', 'IN'): 'ગુજરાતી (Gujarati)',
    const Locale('kn', 'IN'): 'ಕನ್ನಡ (Kannada)',
    const Locale('ml', 'IN'): 'മലയാളം (Malayalam)',
    const Locale('pa', 'IN'): 'ਪੰਜਾਬੀ (Punjabi)',
  };

  /// Get list of supported locales
  static List<Locale> get supportedLocales => localesMap.keys.toList();

  /// Default locale (English)
  static const Locale defaultLocale = Locale('en', 'US');

  /// Assets path for translation files
  static const String translationsPath = 'assets/translations';

  /// Check if a locale is supported
  static bool isSupported(Locale locale) {
    return localesMap.containsKey(locale);
  }

  /// Get display name for a locale
  static String getDisplayName(Locale locale) {
    return localesMap[locale] ?? 'Unknown Language';
  }

  /// Get locale from language code string (e.g., 'hi-IN' -> Locale('hi', 'IN'))
  static Locale? getLocaleFromString(String languageCode) {
    try {
      final parts = languageCode.split('-');
      if (parts.length != 2) return null;

      final locale = Locale(parts[0], parts[1]);
      return isSupported(locale) ? locale : null;
    } catch (e) {
      DebugLogger.error('Failed to parse locale string: $languageCode - $e');
      return null;
    }
  }

  /// Get language code string from locale (e.g., Locale('hi', 'IN') -> 'hi-IN')
  static String getStringFromLocale(Locale locale) {
    return '${locale.languageCode}-${locale.countryCode}';
  }

  /// Get flag emoji for a locale
  static String getFlagForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'hi':
      case 'bn':
      case 'te':
      case 'mr':
      case 'ta':
      case 'gu':
      case 'kn':
      case 'ml':
      case 'pa':
        return '🇮🇳';
      default:
        return '🌐';
    }
  }

  /// Get language family for a locale
  static String getLanguageFamily(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Germanic';
      case 'hi':
      case 'mr':
      case 'gu':
      case 'pa':
        return 'Indo-Aryan';
      case 'bn':
        return 'Indo-Aryan (Eastern)';
      case 'te':
      case 'kn':
      case 'ta':
      case 'ml':
        return 'Dravidian';
      default:
        return 'Unknown';
    }
  }

  /// Get region name for a locale
  static String getRegionName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Global';
      case 'hi':
        return 'National (India)';
      case 'bn':
        return 'West Bengal';
      case 'te':
        return 'Andhra Pradesh/Telangana';
      case 'mr':
        return 'Maharashtra';
      case 'ta':
        return 'Tamil Nadu';
      case 'gu':
        return 'Gujarat';
      case 'kn':
        return 'Karnataka';
      case 'ml':
        return 'Kerala';
      case 'pa':
        return 'Punjab';
      default:
        return 'Unknown';
    }
  }

  /// Get writing script for a locale
  static String getWritingScript(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'Latin';
      case 'hi':
      case 'mr':
        return 'Devanagari';
      case 'bn':
        return 'Bengali';
      case 'te':
        return 'Telugu';
      case 'ta':
        return 'Tamil';
      case 'gu':
        return 'Gujarati';
      case 'kn':
        return 'Kannada';
      case 'ml':
        return 'Malayalam';
      case 'pa':
        return 'Gurmukhi';
      default:
        return 'Unknown';
    }
  }

  /// Get sorted locales by name
  static List<Locale> getSortedLocales() {
    final locales = supportedLocales.toList();
    locales.sort((a, b) {
      // English first, then alphabetical by display name
      if (a.languageCode == 'en') return -1;
      if (b.languageCode == 'en') return 1;
      return getDisplayName(a).compareTo(getDisplayName(b));
    });
    return locales;
  }

  /// Get Indian languages only
  static List<Locale> getIndianLanguages() {
    return supportedLocales
        .where((locale) => locale.countryCode == 'IN')
        .toList();
  }

  /// Get total number of supported languages
  static int get totalLanguages => localesMap.length;

  /// Get total number of Indian languages
  static int get totalIndianLanguages => getIndianLanguages().length;

  /// Check if locale is Indian language
  static bool isIndianLanguage(Locale locale) {
    return locale.countryCode == 'IN';
  }

  /// Get language statistics
  static Map<String, dynamic> getLanguageStats() {
    return {
      'totalLanguages': totalLanguages,
      'indianLanguages': totalIndianLanguages,
      'languageFamilies': {
        'Indo-Aryan': getIndianLanguages()
            .where(
              (l) => ['hi', 'bn', 'mr', 'gu', 'pa'].contains(l.languageCode),
            )
            .length,
        'Dravidian': getIndianLanguages()
            .where((l) => ['te', 'kn', 'ta', 'ml'].contains(l.languageCode))
            .length,
        'Germanic': 1,
      },
      'scripts': {
        'Devanagari': 2, // Hindi, Marathi
        'Bengali': 1,
        'Telugu': 1,
        'Tamil': 1,
        'Gujarati': 1,
        'Kannada': 1,
        'Malayalam': 1,
        'Gurmukhi': 1,
        'Latin': 1,
      },
    };
  }

  /// Log comprehensive supported locales information
  static void logSupportedLocales() {
    DebugLogger.intro(
      'ProjectLocales: ====== COMPREHENSIVE LANGUAGE SUPPORT ======',
    );
    DebugLogger.intro('ProjectLocales: Total languages: $totalLanguages');
    DebugLogger.intro(
      'ProjectLocales: Indian languages: $totalIndianLanguages',
    );
    DebugLogger.intro(
      'ProjectLocales: Default locale: ${getStringFromLocale(defaultLocale)}',
    );

    DebugLogger.intro('ProjectLocales: Supported languages:');
    for (final locale in getSortedLocales()) {
      final name = getDisplayName(locale);
      final flag = getFlagForLocale(locale);
      final region = getRegionName(locale);
      final script = getWritingScript(locale);
      DebugLogger.intro(
        'ProjectLocales:   $flag ${getStringFromLocale(locale)} - $name ($region, $script)',
      );
    }

    final stats = getLanguageStats();
    DebugLogger.intro(
      'ProjectLocales: Language families: ${stats['languageFamilies']}',
    );
    DebugLogger.intro('ProjectLocales: Writing scripts: ${stats['scripts']}');
    DebugLogger.intro(
      'ProjectLocales: ===============================================',
    );
  }

  /// Validate locale support
  static bool validateLocaleSupport() {
    try {
      // Basic validation checks
      if (localesMap.isEmpty) return false;
      if (!localesMap.containsKey(defaultLocale)) return false;
      if (totalLanguages < 1) return false;

      // Check all locales have proper country codes
      for (final locale in supportedLocales) {
        if (locale.languageCode.isEmpty ||
            locale.countryCode?.isEmpty == true) {
          return false;
        }
      }

      DebugLogger.success('ProjectLocales: Locale support validation passed');
      return true;
    } catch (e) {
      DebugLogger.error('ProjectLocales: Locale support validation failed: $e');
      return false;
    }
  }

  /// Get locales grouped by language family
  static Map<String, List<Locale>> getLocalesByFamily() {
    final Map<String, List<Locale>> grouped = {};

    for (final locale in supportedLocales) {
      final family = getLanguageFamily(locale);
      grouped[family] ??= [];
      grouped[family]!.add(locale);
    }

    return grouped;
  }

  /// Get locales grouped by writing script
  static Map<String, List<Locale>> getLocalesByScript() {
    final Map<String, List<Locale>> grouped = {};

    for (final locale in supportedLocales) {
      final script = getWritingScript(locale);
      grouped[script] ??= [];
      grouped[script]!.add(locale);
    }

    return grouped;
  }
}
