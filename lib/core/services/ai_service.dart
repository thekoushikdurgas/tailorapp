// import 'dart:convert';
import 'dart:typed_data';
import 'package:tailorapp/core/models/ai_design_suggestion.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/models/garment_model.dart';

abstract class AIService {
  Future<List<AIDesignSuggestion>> generateDesignSuggestions({
    required DesignPrompt prompt,
    required String userId,
  });

  Future<List<String>> generateColorPalette({
    required String garmentType,
    required String occasion,
    List<String>? preferredColors,
  });

  Future<Map<String, dynamic>> analyzeFabricSuitability({
    required String fabricType,
    required GarmentType garmentType,
    required String occasion,
  });

  Future<List<String>> suggestPatterns({
    required GarmentType garmentType,
    required List<String> stylePreferences,
  });

  Future<Map<String, double>> calculateSizeRecommendations({
    required BodyMeasurements measurements,
    required GarmentType garmentType,
  });

  Future<String> generateDesignDescription({
    required Map<String, dynamic> designParameters,
  });

  Future<Uint8List?> generateDesignVisualization({
    required Map<String, dynamic> designParameters,
  });
}

class AIServiceImpl implements AIService {
  final OpenAIService _openAIService;
  final GeminiService _geminiService;
  final MLKitService _mlKitService;

  AIServiceImpl({
    required OpenAIService openAIService,
    required GeminiService geminiService,
    required MLKitService mlKitService,
  })  : _openAIService = openAIService,
        _geminiService = geminiService,
        _mlKitService = mlKitService;

  @override
  Future<List<AIDesignSuggestion>> generateDesignSuggestions({
    required DesignPrompt prompt,
    required String userId,
  }) async {
    try {
      // Use Gemini for initial design generation
      final geminiResponse = await _geminiService.generateDesignSuggestions(
        prompt.toPromptString(),
      );

      // Use OpenAI for additional refinement and variations
      final openAIResponse = await _openAIService.generateDesignVariations(
        prompt.toPromptString(),
        geminiResponse,
      );

      // Combine and process results
      final suggestions = <AIDesignSuggestion>[];

      for (int i = 0; i < geminiResponse.length && i < 3; i++) {
        final suggestion = await _createDesignSuggestion(
          userId: userId,
          designData: geminiResponse[i],
          aiModel: 'gemini',
          prompt: prompt,
        );
        suggestions.add(suggestion);
      }

      for (int i = 0; i < openAIResponse.length && i < 2; i++) {
        final suggestion = await _createDesignSuggestion(
          userId: userId,
          designData: openAIResponse[i],
          aiModel: 'openai',
          prompt: prompt,
        );
        suggestions.add(suggestion);
      }

      // Sort by confidence score
      suggestions
          .sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

      return suggestions;
    } catch (e) {
      throw AIServiceException('Failed to generate design suggestions: $e');
    }
  }

  @override
  Future<List<String>> generateColorPalette({
    required String garmentType,
    required String occasion,
    List<String>? preferredColors,
  }) async {
    try {
      final prompt = _buildColorPalettePrompt(
        garmentType: garmentType,
        occasion: occasion,
        preferredColors: preferredColors,
      );

      final response = await _geminiService.generateColorPalette(prompt);
      return response;
    } catch (e) {
      throw AIServiceException('Failed to generate color palette: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeFabricSuitability({
    required String fabricType,
    required GarmentType garmentType,
    required String occasion,
  }) async {
    try {
      final analysis = await _geminiService.analyzeFabric(
        fabricType: fabricType,
        garmentType: garmentType.value,
        occasion: occasion,
      );

      return {
        'suitabilityScore': analysis['score'] ?? 0.0,
        'reasons': analysis['reasons'] ?? [],
        'alternatives': analysis['alternatives'] ?? [],
        'careInstructions': analysis['care'] ?? [],
      };
    } catch (e) {
      throw AIServiceException('Failed to analyze fabric suitability: $e');
    }
  }

  @override
  Future<List<String>> suggestPatterns({
    required GarmentType garmentType,
    required List<String> stylePreferences,
  }) async {
    try {
      final patterns = await _geminiService.suggestPatterns(
        garmentType: garmentType.value,
        stylePreferences: stylePreferences,
      );
      return patterns;
    } catch (e) {
      throw AIServiceException('Failed to suggest patterns: $e');
    }
  }

  @override
  Future<Map<String, double>> calculateSizeRecommendations({
    required BodyMeasurements measurements,
    required GarmentType garmentType,
  }) async {
    try {
      // Use ML Kit for size calculation based on measurements
      final recommendations = await _mlKitService.calculateSizeRecommendations(
        measurements: measurements,
        garmentType: garmentType,
      );

      return recommendations;
    } catch (e) {
      throw AIServiceException('Failed to calculate size recommendations: $e');
    }
  }

  @override
  Future<String> generateDesignDescription({
    required Map<String, dynamic> designParameters,
  }) async {
    try {
      final description = await _openAIService.generateDescription(
        designParameters: designParameters,
      );
      return description;
    } catch (e) {
      throw AIServiceException('Failed to generate design description: $e');
    }
  }

  @override
  Future<Uint8List?> generateDesignVisualization({
    required Map<String, dynamic> designParameters,
  }) async {
    try {
      // Use OpenAI DALL-E for image generation
      final imageData = await _openAIService.generateDesignImage(
        designParameters: designParameters,
      );
      return imageData;
    } catch (e) {
      throw AIServiceException('Failed to generate design visualization: $e');
    }
  }

  Future<AIDesignSuggestion> _createDesignSuggestion({
    required String userId,
    required Map<String, dynamic> designData,
    required String aiModel,
    required DesignPrompt prompt,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    return AIDesignSuggestion(
      id: id,
      userId: userId,
      title: designData['title'] ?? 'AI Generated Design',
      description: designData['description'] ?? '',
      imageUrls: List<String>.from(designData['imageUrls'] ?? []),
      designParameters: designData['parameters'] ?? {},
      suggestedColors: List<String>.from(designData['colors'] ?? []),
      suggestedFabrics: List<String>.from(designData['fabrics'] ?? []),
      suggestedPatterns: List<String>.from(designData['patterns'] ?? []),
      confidenceScore: (designData['confidence'] ?? 0.8).toDouble(),
      aiModel: aiModel,
      createdAt: DateTime.now(),
      measurements: prompt.bodyMeasurements,
      garmentType: designData['garmentType'],
      stylePreferences: {
        'preferences': prompt.stylePreferences,
        'occasion': prompt.occasion,
        'budget': prompt.budget,
      },
    );
  }

  String _buildColorPalettePrompt({
    required String garmentType,
    required String occasion,
    List<String>? preferredColors,
  }) {
    final buffer = StringBuffer();
    buffer.write('Generate a color palette for a $garmentType ');
    buffer.write('suitable for $occasion. ');

    if (preferredColors != null && preferredColors.isNotEmpty) {
      buffer.write(
        'Consider these preferred colors: ${preferredColors.join(', ')}. ',
      );
    }

    buffer.write('Provide 5-7 complementary colors that work well together.');

    return buffer.toString();
  }
}

class AIServiceException implements Exception {
  final String message;
  const AIServiceException(this.message);

  @override
  String toString() => 'AIServiceException: $message';
}

// Abstract classes for different AI providers
abstract class OpenAIService {
  Future<List<Map<String, dynamic>>> generateDesignVariations(
    String prompt,
    List<Map<String, dynamic>> baseDesigns,
  );

  Future<String> generateDescription({
    required Map<String, dynamic> designParameters,
  });

  Future<Uint8List?> generateDesignImage({
    required Map<String, dynamic> designParameters,
  });
}

abstract class GeminiService {
  Future<List<Map<String, dynamic>>> generateDesignSuggestions(String prompt);
  Future<List<String>> generateColorPalette(String prompt);
  Future<Map<String, dynamic>> analyzeFabric({
    required String fabricType,
    required String garmentType,
    required String occasion,
  });
  Future<List<String>> suggestPatterns({
    required String garmentType,
    required List<String> stylePreferences,
  });
}

abstract class MLKitService {
  Future<Map<String, double>> calculateSizeRecommendations({
    required BodyMeasurements measurements,
    required GarmentType garmentType,
  });
}
