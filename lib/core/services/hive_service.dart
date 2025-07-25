import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/view/_product/enum/route_enum.dart';

/// Comprehensive HiveService for all local storage operations
///
/// This service extends the existing caching patterns used by ThemeCaching
/// and IntroCaching to provide a centralized solution for all local storage
/// needs in the Tailor app including user data, authentication tokens,
/// preferences, and app state.
class HiveService {
  static const String _themeBoxName = 'theme';
  static const String _introBoxName = 'intro';
  static const String _authBoxName = 'auth';
  static const String _userBoxName = 'user';
  static const String _preferencesBoxName = 'preferences';
  static const String _appStateBoxName = 'app_state';

  // Box references
  static late Box _themeBox;
  static late Box _introBox;
  static late Box _authBox;
  static late Box _userBox;
  static late Box _preferencesBox;
  static late Box _appStateBox;

  static bool _isInitialized = false;

  /// Initialize all Hive boxes
  static Future<void> init() async {
    if (_isInitialized) {
      DebugLogger.storage('HiveService already initialized, skipping...');
      return;
    }

    try {
      DebugLogger.storage('Initializing HiveService...');
      final timer = DebugLogger.startTimer('HiveService initialization');

      await Hive.initFlutter();

      // Initialize all boxes
      _themeBox = await Hive.openBox(_themeBoxName);
      _introBox = await Hive.openBox(_introBoxName);
      _authBox = await Hive.openBox(_authBoxName);
      _userBox = await Hive.openBox(_userBoxName);
      _preferencesBox = await Hive.openBox(_preferencesBoxName);
      _appStateBox = await Hive.openBox(_appStateBoxName);

      _isInitialized = true;

      DebugLogger.endTimer('HiveService initialization', timer);
      DebugLogger.success(
        'HiveService initialized successfully with ${_getAllBoxes().length} boxes',
      );

      // Log box status for debugging
      _logBoxStatus();
    } catch (e, stackTrace) {
      DebugLogger.exception('Failed to initialize HiveService', e, stackTrace);
      rethrow;
    }
  }

  /// Get all boxes for debugging
  static List<Box> _getAllBoxes() {
    return [
      _themeBox,
      _introBox,
      _authBox,
      _userBox,
      _preferencesBox,
      _appStateBox,
    ];
  }

  /// Log status of all boxes
  static void _logBoxStatus() {
    DebugLogger.debug('Hive Box Status:');
    DebugLogger.debug('  📱 Theme: ${_themeBox.length} items');
    DebugLogger.debug('  🎯 Intro: ${_introBox.length} items');
    DebugLogger.debug('  🔐 Auth: ${_authBox.length} items');
    DebugLogger.debug('  👤 User: ${_userBox.length} items');
    DebugLogger.debug('  ⚙️ Preferences: ${_preferencesBox.length} items');
    DebugLogger.debug('  📊 App State: ${_appStateBox.length} items');
  }

  // =============================================================================
  // THEME MANAGEMENT (extends ThemeCaching functionality)
  // =============================================================================

  /// Get initial theme mode
  static ThemeMode getInitialTheme() {
    try {
      switch (_themeBox.get('isLight')) {
        case true:
          return ThemeMode.light;
        case false:
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      DebugLogger.error('Failed to get initial theme: $e');
      return ThemeMode.system;
    }
  }

  /// Get initial theme radio value
  static String getInitialRadio() {
    try {
      switch (_themeBox.get('isLight')) {
        case true:
          return 'ThemeMode.light';
        case false:
          return 'ThemeMode.dark';
        default:
          return 'ThemeMode.system';
      }
    } catch (e) {
      DebugLogger.error('Failed to get initial radio: $e');
      return 'ThemeMode.system';
    }
  }

  /// Set light theme
  static Future<void> setLightTheme() async {
    try {
      await _themeBox.put('isLight', true);
      DebugLogger.theme('Theme set to light mode');
    } catch (e) {
      DebugLogger.error('Failed to set light theme: $e');
      rethrow;
    }
  }

  /// Set dark theme
  static Future<void> setDarkTheme() async {
    try {
      await _themeBox.put('isLight', false);
      DebugLogger.theme('Theme set to dark mode');
    } catch (e) {
      DebugLogger.error('Failed to set dark theme: $e');
      rethrow;
    }
  }

  /// Set system theme
  static Future<void> setSystemTheme() async {
    try {
      await _themeBox.put('isLight', null);
      DebugLogger.theme('Theme set to system mode');
    } catch (e) {
      DebugLogger.error('Failed to set system theme: $e');
      rethrow;
    }
  }

  // =============================================================================
  // INTRO/ONBOARDING MANAGEMENT (extends IntroCaching functionality)
  // =============================================================================

  /// Get initial intro route
  static String getInitialIntroRoute() {
    try {
      switch (_introBox.get('introWatched')) {
        case true:
          return RouteEnum.homePage.rawValue;
        default:
          return RouteEnum.intro.rawValue;
      }
    } catch (e) {
      DebugLogger.error('Failed to get initial intro route: $e');
      return RouteEnum.intro.rawValue;
    }
  }

  /// Check if intro was watched
  static bool isIntroWatched() {
    try {
      return _introBox.get('introWatched', defaultValue: false);
    } catch (e) {
      DebugLogger.error('Failed to check intro watched status: $e');
      return false;
    }
  }

  /// Mark intro as watched
  static Future<void> setIntroWatched() async {
    try {
      await _introBox.put('introWatched', true);
      DebugLogger.intro('Intro marked as watched');
    } catch (e) {
      DebugLogger.error('Failed to set intro watched: $e');
      rethrow;
    }
  }

  /// Reset intro status (for testing/debugging)
  static Future<void> resetIntroStatus() async {
    try {
      await _introBox.delete('introWatched');
      DebugLogger.intro('Intro status reset');
    } catch (e) {
      DebugLogger.error('Failed to reset intro status: $e');
      rethrow;
    }
  }

  // =============================================================================
  // AUTHENTICATION MANAGEMENT
  // =============================================================================

  /// Check if user is logged in
  static bool isLoggedIn() {
    try {
      return _authBox.get('isLoggedIn', defaultValue: false);
    } catch (e) {
      DebugLogger.error('Failed to check login status: $e');
      return false;
    }
  }

  /// Set login status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    try {
      await _authBox.put('isLoggedIn', isLoggedIn);
      DebugLogger.auth('Login status set to: $isLoggedIn');
    } catch (e) {
      DebugLogger.error('Failed to set login status: $e');
      rethrow;
    }
  }

  /// Save authentication tokens
  static Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    try {
      await _authBox.put('accessToken', accessToken);
      await _authBox.put('refreshToken', refreshToken);
      if (expiresAt != null) {
        await _authBox.put('tokenExpiresAt', expiresAt.millisecondsSinceEpoch);
      }
      DebugLogger.auth('Auth tokens saved successfully');
    } catch (e) {
      DebugLogger.error('Failed to save auth tokens: $e');
      rethrow;
    }
  }

  /// Get access token
  static String? getAccessToken() {
    try {
      return _authBox.get('accessToken');
    } catch (e) {
      DebugLogger.error('Failed to get access token: $e');
      return null;
    }
  }

  /// Get refresh token
  static String? getRefreshToken() {
    try {
      return _authBox.get('refreshToken');
    } catch (e) {
      DebugLogger.error('Failed to get refresh token: $e');
      return null;
    }
  }

  /// Check if tokens are expired
  static bool areTokensExpired() {
    try {
      final expiresAt = _authBox.get('tokenExpiresAt');
      if (expiresAt == null) return false;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt);
      final isExpired = DateTime.now().isAfter(expiryDate);

      if (isExpired) {
        DebugLogger.auth('Tokens are expired');
      }

      return isExpired;
    } catch (e) {
      DebugLogger.error('Failed to check token expiry: $e');
      return true; // Assume expired on error
    }
  }

  /// Clear all authentication data
  static Future<void> clearAuthData() async {
    try {
      await _authBox.clear();
      DebugLogger.auth('All auth data cleared');
    } catch (e) {
      DebugLogger.error('Failed to clear auth data: $e');
      rethrow;
    }
  }

  // =============================================================================
  // USER DATA MANAGEMENT
  // =============================================================================

  /// Save user data
  static Future<void> saveUserData(CustomerModel user) async {
    try {
      // Convert user model to map for storage
      final userData = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'profileImageUrl': user.profileImageUrl,
        'dateOfBirth': user.dateOfBirth?.millisecondsSinceEpoch,
        'gender': user.gender,
        'isVerified': user.isVerified,
        'createdAt': user.createdAt.millisecondsSinceEpoch,
        'updatedAt': user.updatedAt.millisecondsSinceEpoch,
        // Add other fields as needed
      };

      await _userBox.put('userData', userData);
      DebugLogger.user('User data saved for: ${user.name} (${user.email})');
    } catch (e) {
      DebugLogger.error('Failed to save user data: $e');
      rethrow;
    }
  }

  /// Get user data safely
  static CustomerModel? getUserDataSafe() {
    try {
      final userData = _userBox.get('userData');
      if (userData == null) return null;

      // Convert map back to CustomerModel
      // This is a simplified version - you may need to add more fields
      return CustomerModel(
        id: userData['id'] ?? '',
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'],
        profileImageUrl: userData['profileImageUrl'],
        dateOfBirth: userData['dateOfBirth'] != null
            ? DateTime.fromMillisecondsSinceEpoch(userData['dateOfBirth'])
            : null,
        gender: userData['gender'],
        isVerified: userData['isVerified'] ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(userData['createdAt']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(userData['updatedAt']),
        stylePreferences: const StylePreferences(
          preferredStyles: [],
          preferredColors: [],
          preferredFabrics: [],
          dislikedColors: [],
          dislikedFabrics: [],
          occasions: [],
        ),
        orderHistory: const [],
      );
    } catch (e) {
      DebugLogger.error('Failed to get user data: $e');
      return null;
    }
  }

  /// Clear user data
  static Future<void> clearUserData() async {
    try {
      await _userBox.clear();
      DebugLogger.user('User data cleared');
    } catch (e) {
      DebugLogger.error('Failed to clear user data: $e');
      rethrow;
    }
  }

  // =============================================================================
  // LANGUAGE/LOCALIZATION MANAGEMENT
  // =============================================================================

  /// Check if language is selected
  static bool isLanguageSelected() {
    try {
      return _preferencesBox.get('languageSelected', defaultValue: false);
    } catch (e) {
      DebugLogger.error('Failed to check language selection: $e');
      return false;
    }
  }

  /// Set language selection status
  static Future<void> setLanguageSelected(bool isSelected) async {
    try {
      await _preferencesBox.put('languageSelected', isSelected);
      DebugLogger.info('Language selection status set to: $isSelected');
    } catch (e) {
      DebugLogger.error('Failed to set language selection: $e');
      rethrow;
    }
  }

  /// Save selected language
  static Future<void> saveSelectedLanguage(String languageCode) async {
    try {
      await _preferencesBox.put('selectedLanguage', languageCode);
      await setLanguageSelected(true);
      DebugLogger.info('Selected language saved: $languageCode');
    } catch (e) {
      DebugLogger.error('Failed to save selected language: $e');
      rethrow;
    }
  }

  /// Get selected language
  static String getSelectedLanguage() {
    try {
      return _preferencesBox.get('selectedLanguage', defaultValue: 'en-US');
    } catch (e) {
      DebugLogger.error('Failed to get selected language: $e');
      return 'en-US';
    }
  }

  // =============================================================================
  // EMERGENCY/UTILITY METHODS
  // =============================================================================

  /// Emergency logout - clears all user-related data
  static Future<void> emergencyLogout() async {
    try {
      DebugLogger.auth('Performing emergency logout...');
      await clearAuthData();
      await clearUserData();
      await setLoggedIn(false);
      DebugLogger.success('Emergency logout completed');
    } catch (e) {
      DebugLogger.error('Failed to perform emergency logout: $e');
      rethrow;
    }
  }

  /// Clear all data (for testing/reset)
  static Future<void> clearAllData() async {
    try {
      DebugLogger.storage('Clearing all Hive data...');
      for (final box in _getAllBoxes()) {
        await box.clear();
      }
      DebugLogger.success('All Hive data cleared');
    } catch (e) {
      DebugLogger.error('Failed to clear all data: $e');
      rethrow;
    }
  }

  /// Get storage info for debugging
  static Map<String, dynamic> getStorageInfo() {
    try {
      return {
        'isInitialized': _isInitialized,
        'themeItems': _themeBox.length,
        'introItems': _introBox.length,
        'authItems': _authBox.length,
        'userItems': _userBox.length,
        'preferencesItems': _preferencesBox.length,
        'appStateItems': _appStateBox.length,
        'totalItems': _getAllBoxes().fold(0, (sum, box) => sum + box.length),
      };
    } catch (e) {
      DebugLogger.error('Failed to get storage info: $e');
      return {'error': e.toString()};
    }
  }
}
