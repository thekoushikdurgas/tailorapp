import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:tailorapp/core/services/ai_service.dart';

class ProductionOpenAIServiceImpl implements OpenAIService {
  final String _apiKey;
  final OpenAIService _fallbackService;
  bool _isApiKeyValid = true;

  ProductionOpenAIServiceImpl({
    required String apiKey,
    required OpenAIService fallbackService,
  })  : _apiKey = apiKey,
        _fallbackService = fallbackService {
    if (!_isApiKeyPlaceholder()) {
      OpenAI.apiKey = apiKey;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> generateDesignVariations(
    String prompt,
    List<Map<String, dynamic>> baseDesigns,
  ) async {
    if (!_isApiKeyValid || _isApiKeyPlaceholder()) {
      return _fallbackService.generateDesignVariations(prompt, baseDesigns);
    }

    try {
      final enhancedPrompt = _buildVariationPrompt(prompt, baseDesigns);

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                enhancedPrompt,
              ),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
        temperature: 0.8,
        maxTokens: 1500,
      );

      final response =
          chatCompletion.choices.first.message.content?.first.text ?? '';
      return _parseDesignResponse(response);
    } catch (e) {
      _handleApiError(e);
      return _fallbackService.generateDesignVariations(prompt, baseDesigns);
    }
  }

  @override
  Future<String> generateDescription({
    required Map<String, dynamic> designParameters,
  }) async {
    if (!_isApiKeyValid || _isApiKeyPlaceholder()) {
      return _fallbackService.generateDescription(
        designParameters: designParameters,
      );
    }

    try {
      final prompt = _buildDescriptionPrompt(designParameters);

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
        temperature: 0.7,
        maxTokens: 500,
      );

      return chatCompletion.choices.first.message.content?.first.text ??
          'A custom-designed garment tailored to your preferences.';
    } catch (e) {
      _handleApiError(e);
      return _fallbackService.generateDescription(
        designParameters: designParameters,
      );
    }
  }

  @override
  Future<Uint8List?> generateDesignImage({
    required Map<String, dynamic> designParameters,
  }) async {
    if (!_isApiKeyValid || _isApiKeyPlaceholder()) {
      return _fallbackService.generateDesignImage(
        designParameters: designParameters,
      );
    }

    try {
      final prompt = _buildImagePrompt(designParameters);

      final imageGeneration = await OpenAI.instance.image.create(
        prompt: prompt,
        n: 1,
        size: OpenAIImageSize.size512,
        responseFormat: OpenAIImageResponseFormat.b64Json,
      );

      final base64Image = imageGeneration.data.first.b64Json;
      if (base64Image != null) {
        return base64Decode(base64Image);
      }

      return null;
    } catch (e) {
      _handleApiError(e);
      // Return null if image generation fails
      return null;
    }
  }

  // Private methods
  bool _isApiKeyPlaceholder() {
    return _apiKey == 'OPENAI_API_KEY_HERE' ||
        _apiKey.isEmpty ||
        _apiKey.startsWith('your_') ||
        _apiKey.startsWith('YOUR_') ||
        _apiKey.startsWith('sk-') == false; // OpenAI keys start with sk-
  }

  void _handleApiError(Object error) {
    debugPrint('OpenAI API Error: $error');

    // Mark API as invalid if it's an authentication error
    if (error.toString().toLowerCase().contains('authentication') ||
        error.toString().toLowerCase().contains('unauthorized') ||
        error.toString().toLowerCase().contains('forbidden') ||
        error.toString().toLowerCase().contains('invalid api key')) {
      _isApiKeyValid = false;
    }
  }

  String _buildVariationPrompt(
      String userPrompt, List<Map<String, dynamic>> baseDesigns) {
    final buffer = StringBuffer();
    buffer.write('Based on this user request: "$userPrompt"\n\n');
    buffer.write('And these existing design suggestions:\n');

    for (int i = 0; i < baseDesigns.length; i++) {
      final design = baseDesigns[i];
      buffer.write('${i + 1}. ${design['title']}: ${design['description']}\n');
    }

    buffer.write(
        '\nCreate 2 additional design variations that complement these suggestions. ');
    buffer.write(
        'Focus on different styles, colors, or approaches while maintaining quality and wearability.\n\n');
    buffer.write('Respond with ONLY a JSON array in this exact format:\n');
    buffer.write('[\n');
    buffer.write('  {\n');
    buffer.write('    "title": "Design Name",\n');
    buffer.write('    "description": "Detailed description",\n');
    buffer.write(
        '    "garmentType": "shirt/dress/suit/jacket/trousers/skirt/blouse",\n');
    buffer.write('    "colors": ["color1", "color2"],\n');
    buffer.write('    "fabrics": ["fabric1", "fabric2"],\n');
    buffer.write('    "patterns": ["pattern1", "pattern2"],\n');
    buffer.write('    "confidence": 0.85,\n');
    buffer.write('    "parameters": {\n');
    buffer.write('      "style": "modern/classic/vintage",\n');
    buffer.write('      "fit": "slim/regular/loose",\n');
    buffer.write('      "occasion": "casual/formal/business",\n');
    buffer.write('      "features": ["feature1", "feature2"]\n');
    buffer.write('    },\n');
    buffer.write('    "imageUrls": []\n');
    buffer.write('  }\n');
    buffer.write(']\n');

    return buffer.toString();
  }

  String _buildDescriptionPrompt(Map<String, dynamic> designParameters) {
    final buffer = StringBuffer();
    buffer.write(
        'Write a compelling, professional description for a custom garment with these specifications:\n\n');

    designParameters.forEach((key, value) {
      buffer.write('$key: $value\n');
    });

    buffer.write(
        '\nThe description should be 2-3 sentences, highlighting the key features, ');
    buffer.write(
        'quality, and style. Make it sound premium and desirable for potential customers. ');
    buffer.write('Focus on craftsmanship, fit, and versatility.');

    return buffer.toString();
  }

  String _buildImagePrompt(Map<String, dynamic> designParameters) {
    final buffer = StringBuffer();
    buffer.write('A professional fashion illustration of ');

    final garmentType = designParameters['garmentType'] ?? 'garment';
    final style = designParameters['style'] ?? 'modern';
    final colors = designParameters['colors'] ?? ['navy'];
    final fabric = designParameters['fabric'] ?? 'cotton';

    buffer.write('a $style $garmentType in ${colors.join(' and ')} ');
    buffer.write('made from $fabric fabric. ');
    buffer.write('Clean, minimalist background. ');
    buffer.write('High-quality fashion photography style. ');
    buffer.write('Professional lighting. ');
    buffer.write('Focus on garment details and silhouette.');

    return buffer.toString();
  }

  List<Map<String, dynamic>> _parseDesignResponse(String response) {
    try {
      // Clean the response and extract JSON
      String cleanResponse = response.trim();

      // Remove markdown code blocks if present
      if (cleanResponse.startsWith('```')) {
        cleanResponse =
            cleanResponse.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
        cleanResponse = cleanResponse.replaceFirst(RegExp(r'\s*```$'), '');
      }

      final decoded = jsonDecode(cleanResponse);

      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else {
        return [decoded as Map<String, dynamic>];
      }
    } catch (e) {
      // Return fallback designs if parsing fails
      return _getFallbackVariations();
    }
  }

  List<Map<String, dynamic>> _getFallbackVariations() {
    return [
      {
        'title': 'Contemporary Classic',
        'description':
            'A timeless design with modern touches, perfect for versatile wear.',
        'garmentType': 'shirt',
        'colors': ['White', 'Light Blue'],
        'fabrics': ['Cotton', 'Linen'],
        'patterns': ['Solid', 'Subtle Texture'],
        'confidence': 0.82,
        'parameters': {
          'style': 'classic',
          'fit': 'regular',
          'occasion': 'versatile',
          'features': ['Quality construction', 'Comfortable fit']
        },
        'imageUrls': []
      },
      {
        'title': 'Urban Modern',
        'description':
            'Sleek and contemporary design for the modern professional.',
        'garmentType': 'shirt',
        'colors': ['Navy', 'Charcoal'],
        'fabrics': ['Cotton Blend', 'Performance'],
        'patterns': ['Solid', 'Micro Pattern'],
        'confidence': 0.79,
        'parameters': {
          'style': 'modern',
          'fit': 'slim',
          'occasion': 'business',
          'features': ['Wrinkle resistant', 'Moisture wicking']
        },
        'imageUrls': []
      }
    ];
  }
}
