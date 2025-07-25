import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:tailorapp/core/services/ai_service.dart';
import 'package:tailorapp/core/services/gemini_service_impl.dart';
import 'package:tailorapp/core/services/openai_service_impl.dart';
import 'package:tailorapp/core/services/mlkit_service_impl.dart';
import 'package:tailorapp/core/services/production_gemini_service_impl.dart';
import 'package:tailorapp/core/services/production_openai_service_impl.dart';
import 'package:tailorapp/core/services/auth_service.dart';
import 'package:tailorapp/core/repositories/customer_repository.dart';
import 'package:tailorapp/core/repositories/order_repository.dart';
import 'package:tailorapp/core/repositories/garment_repository.dart';

final GetIt serviceLocator = GetIt.instance;

class ServiceLocator {
  static Future<void> setupServiceLocator() async {
    // Repositories
    _setupRepositories();

    // Authentication Services
    _setupAuthServices();

    // AI Services
    _setupAIServices();
  }

  static void _setupRepositories() {
    // Register repository implementations
    serviceLocator.registerLazySingleton<CustomerRepository>(
      () => FirebaseCustomerRepository(),
    );

    serviceLocator.registerLazySingleton<OrderRepository>(
      () => FirebaseOrderRepository(),
    );

    serviceLocator.registerLazySingleton<GarmentRepository>(
      () => FirebaseGarmentRepository(),
    );
  }

  static void _setupAuthServices() {
    // Register Firebase Auth instance
    serviceLocator.registerLazySingleton<FirebaseAuth>(
      () => FirebaseAuth.instance,
    );

    // Register auth service implementation
    serviceLocator.registerLazySingleton<AuthService>(
      () => FirebaseAuthService(
        firebaseAuth: serviceLocator<FirebaseAuth>(),
        customerRepository: serviceLocator<CustomerRepository>(),
      ),
    );
  }

  static void _setupAIServices() {
    // Register AI service implementations
    serviceLocator.registerLazySingleton<GeminiService>(
      () => GeminiServiceImpl(
        apiKey: _getGeminiApiKey(),
      ),
    );

    serviceLocator.registerLazySingleton<OpenAIService>(
      () => OpenAIServiceImpl(
        apiKey: _getOpenAIApiKey(),
      ),
    );

    serviceLocator.registerLazySingleton<MLKitService>(
      () => MLKitServiceImpl(),
    );

    // Register main AI service that orchestrates all others
    serviceLocator.registerLazySingleton<AIService>(
      () => AIServiceImpl(
        openAIService: serviceLocator<OpenAIService>(),
        geminiService: serviceLocator<GeminiService>(),
        mlKitService: serviceLocator<MLKitService>(),
      ),
    );
  }

  // API Key management - In production, these should come from secure storage or environment variables
  static String _getGeminiApiKey() {
    // For development, you can add your API key here
    // In production, use secure storage or environment variables
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (apiKey.isEmpty) {
      // Return a mock key for development
      return 'GEMINI_API_KEY_HERE';
    }
    return apiKey;
  }

  static String _getOpenAIApiKey() {
    // For development, you can add your API key here
    // In production, use secure storage or environment variables
    const apiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    if (apiKey.isEmpty) {
      // Return a mock key for development
      return 'OPENAI_API_KEY_HERE';
    }
    return apiKey;
  }

  // Helper methods to get services
  static AIService get aiService => serviceLocator<AIService>();
  static GeminiService get geminiService => serviceLocator<GeminiService>();
  static OpenAIService get openAIService => serviceLocator<OpenAIService>();
  static MLKitService get mlKitService => serviceLocator<MLKitService>();

  // Helper methods to get repositories
  static CustomerRepository get customerRepository =>
      serviceLocator<CustomerRepository>();
  static OrderRepository get orderRepository =>
      serviceLocator<OrderRepository>();
  static GarmentRepository get garmentRepository =>
      serviceLocator<GarmentRepository>();

  // Mock service setup for development/testing
  static void setupMockServices() {
    // Clear existing registrations if they exist
    if (serviceLocator.isRegistered<AIService>()) {
      serviceLocator.unregister<AIService>();
    }
    if (serviceLocator.isRegistered<GeminiService>()) {
      serviceLocator.unregister<GeminiService>();
    }
    if (serviceLocator.isRegistered<OpenAIService>()) {
      serviceLocator.unregister<OpenAIService>();
    }
    if (serviceLocator.isRegistered<MLKitService>()) {
      serviceLocator.unregister<MLKitService>();
    }

    // Register mock implementations for development
    serviceLocator.registerLazySingleton<GeminiService>(
      () => MockGeminiService(),
    );

    serviceLocator.registerLazySingleton<OpenAIService>(
      () => MockOpenAIService(),
    );

    serviceLocator.registerLazySingleton<MLKitService>(
      () => MLKitServiceImpl(), // This one doesn't need external API
    );

    serviceLocator.registerLazySingleton<AIService>(
      () => AIServiceImpl(
        openAIService: serviceLocator<OpenAIService>(),
        geminiService: serviceLocator<GeminiService>(),
        mlKitService: serviceLocator<MLKitService>(),
      ),
    );
  }

  // Production AI service setup with real APIs
  static void setupProductionAIServices() {
    // Clear existing AI service registrations
    if (serviceLocator.isRegistered<AIService>()) {
      serviceLocator.unregister<AIService>();
    }
    if (serviceLocator.isRegistered<GeminiService>()) {
      serviceLocator.unregister<GeminiService>();
    }
    if (serviceLocator.isRegistered<OpenAIService>()) {
      serviceLocator.unregister<OpenAIService>();
    }
    if (serviceLocator.isRegistered<MLKitService>()) {
      serviceLocator.unregister<MLKitService>();
    }

    // Register production implementations with fallback to mock
    serviceLocator.registerLazySingleton<GeminiService>(
      () => ProductionGeminiServiceImpl(
        apiKey: _getGeminiApiKey(),
        fallbackService: MockGeminiService(),
      ),
    );

    serviceLocator.registerLazySingleton<OpenAIService>(
      () => ProductionOpenAIServiceImpl(
        apiKey: _getOpenAIApiKey(),
        fallbackService: MockOpenAIService(),
      ),
    );

    serviceLocator.registerLazySingleton<MLKitService>(
      () => MLKitServiceImpl(),
    );

    serviceLocator.registerLazySingleton<AIService>(
      () => AIServiceImpl(
        openAIService: serviceLocator<OpenAIService>(),
        geminiService: serviceLocator<GeminiService>(),
        mlKitService: serviceLocator<MLKitService>(),
      ),
    );
  }

  static void dispose() {
    serviceLocator.reset();
  }
}

// Mock implementations for development
class MockGeminiService implements GeminiService {
  @override
  Future<List<Map<String, dynamic>>> generateDesignSuggestions(
    String prompt,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'title': 'AI Classic Business Shirt',
        'description':
            'A professionally tailored shirt perfect for business environments.',
        'garmentType': 'shirt',
        'colors': ['Navy', 'White', 'Light Blue'],
        'fabrics': ['Cotton', 'Cotton Blend'],
        'patterns': ['Solid', 'Subtle Texture'],
        'confidence': 0.92,
        'parameters': {
          'style': 'classic',
          'fit': 'regular',
          'occasion': 'business',
          'features': ['Wrinkle resistant', 'Moisture wicking', 'Easy care'],
        },
        'imageUrls': [],
      },
      {
        'title': 'Modern Casual Shirt',
        'description':
            'Contemporary design with a relaxed fit for everyday comfort.',
        'garmentType': 'shirt',
        'colors': ['Light Blue', 'Grey', 'White'],
        'fabrics': ['Linen', 'Cotton'],
        'patterns': ['Solid', 'Micro Print'],
        'confidence': 0.87,
        'parameters': {
          'style': 'modern',
          'fit': 'relaxed',
          'occasion': 'casual',
          'features': ['Breathable', 'Comfortable', 'Versatile'],
        },
        'imageUrls': [],
      }
    ];
  }

  @override
  Future<List<String>> generateColorPalette(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      'Navy Blue',
      'Crisp White',
      'Sky Blue',
      'Charcoal Grey',
      'Forest Green',
    ];
  }

  @override
  Future<Map<String, dynamic>> analyzeFabric({
    required String fabricType,
    required String garmentType,
    required String occasion,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'score': 0.85,
      'reasons': [
        'Excellent breathability for all-day comfort',
        'Durable construction for long-lasting wear',
        'Easy care and maintenance',
      ],
      'alternatives': ['Cotton blend', 'Linen', 'Modal'],
      'care': [
        'Machine wash cold',
        'Tumble dry low',
        'Iron on medium heat if needed',
      ],
    };
  }

  @override
  Future<List<String>> suggestPatterns({
    required String garmentType,
    required List<String> stylePreferences,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['Solid', 'Subtle Stripes', 'Micro Check', 'Textured Weave'];
  }
}

class MockOpenAIService implements OpenAIService {
  @override
  Future<List<Map<String, dynamic>>> generateDesignVariations(
    String prompt,
    List<Map<String, dynamic>> baseDesigns,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'title': 'Refined Professional',
        'description':
            'Elevated business attire with premium details and exceptional fit.',
        'garmentType': 'shirt',
        'colors': ['Crisp White', 'Navy'],
        'fabrics': ['Premium Cotton', 'Supima Cotton'],
        'patterns': ['Solid', 'Herringbone'],
        'confidence': 0.89,
        'parameters': {
          'style': 'refined',
          'fit': 'tailored',
          'occasion': 'formal',
          'features': [
            'French cuffs',
            'Mother-of-pearl buttons',
            'Reinforced collar',
          ],
        },
        'imageUrls': [],
      }
    ];
  }

  @override
  Future<String> generateDescription({
    required Map<String, dynamic> designParameters,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'A meticulously crafted garment that combines timeless elegance with modern functionality. Each piece is tailored to perfection using premium materials and expert craftsmanship.';
  }

  @override
  Future<Uint8List?> generateDesignImage({
    required Map<String, dynamic> designParameters,
  }) async {
    // Return null for mock - image generation requires actual API
    return null;
  }
}
