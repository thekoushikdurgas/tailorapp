import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tailorapp/core/services/ai_service.dart';

class GeminiServiceImpl implements GeminiService {
  final GenerativeModel _model;

  GeminiServiceImpl({
    required String apiKey,
  }) : _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
        );

  @override
  Future<List<Map<String, dynamic>>> generateDesignSuggestions(
      String prompt) async {
    try {
      final enhancedPrompt = _buildDesignPrompt(prompt);
      final content = [Content.text(enhancedPrompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('No response from Gemini AI');
      }

      return _parseDesignResponse(response.text!);
    } catch (e) {
      throw Exception('Gemini AI design generation failed: $e');
    }
  }

  @override
  Future<List<String>> generateColorPalette(String prompt) async {
    try {
      final enhancedPrompt = '''
$prompt

Please respond with ONLY a JSON array of color names (strings), like this:
["Navy Blue", "Cream White", "Gold", "Forest Green", "Burgundy"]

No explanations, just the JSON array.
      ''';

      final content = [Content.text(enhancedPrompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        return ['Navy', 'White', 'Gray', 'Black', 'Beige']; // Fallback colors
      }

      return _parseColorResponse(response.text!);
    } catch (e) {
      // Return fallback colors in case of error
      return ['Navy', 'White', 'Gray', 'Black', 'Beige'];
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeFabric({
    required String fabricType,
    required String garmentType,
    required String occasion,
  }) async {
    try {
      final prompt = '''
Analyze the suitability of $fabricType fabric for a $garmentType for $occasion.

Provide your response as a JSON object with this exact structure:
{
  "score": 0.8,
  "reasons": ["reason1", "reason2"],
  "alternatives": ["fabric1", "fabric2"],
  "care": ["care instruction 1", "care instruction 2"]
}

Score should be between 0.0 and 1.0. Include 3-5 reasons, 3-5 alternatives, and 3-5 care instructions.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        return _getFallbackFabricAnalysis();
      }

      return _parseFabricResponse(response.text!);
    } catch (e) {
      return _getFallbackFabricAnalysis();
    }
  }

  @override
  Future<List<String>> suggestPatterns({
    required String garmentType,
    required List<String> stylePreferences,
  }) async {
    try {
      final prompt = '''
Suggest patterns for a $garmentType based on these style preferences: ${stylePreferences.join(', ')}.

Respond with ONLY a JSON array of pattern names:
["Solid", "Stripes", "Checkered", "Polka Dots"]

No explanations, just the JSON array.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        return ['Solid', 'Stripes', 'Checkered'];
      }

      return _parsePatternResponse(response.text!);
    } catch (e) {
      return ['Solid', 'Stripes', 'Checkered'];
    }
  }

  String _buildDesignPrompt(String userPrompt) {
    return '''
You are a professional fashion designer and AI assistant. Based on the following request, generate creative garment design suggestions.

User Request: $userPrompt

Please provide 3 distinct design suggestions in this EXACT JSON format:
[
  {
    "title": "Design Name",
    "description": "Detailed description of the garment design",
    "garmentType": "shirt/dress/suit/jacket/trousers/skirt/blouse",
    "colors": ["color1", "color2", "color3"],
    "fabrics": ["fabric1", "fabric2"],
    "patterns": ["pattern1", "pattern2"],
    "confidence": 0.85,
    "parameters": {
      "style": "modern/classic/vintage",
      "fit": "slim/regular/loose",
      "occasion": "casual/formal/business",
      "features": ["feature1", "feature2"]
    },
    "imageUrls": []
  }
]

Ensure the response is valid JSON only, no additional text or explanations.
    ''';
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
      return _getFallbackDesigns();
    }
  }

  List<String> _parseColorResponse(String response) {
    try {
      String cleanResponse = response.trim();

      // Remove markdown code blocks if present
      if (cleanResponse.startsWith('```')) {
        cleanResponse =
            cleanResponse.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
        cleanResponse = cleanResponse.replaceFirst(RegExp(r'\s*```$'), '');
      }

      final decoded = jsonDecode(cleanResponse);
      return List<String>.from(decoded);
    } catch (e) {
      // Fallback to extracting colors from text
      return _extractColorsFromText(response);
    }
  }

  Map<String, dynamic> _parseFabricResponse(String response) {
    try {
      String cleanResponse = response.trim();

      if (cleanResponse.startsWith('```')) {
        cleanResponse =
            cleanResponse.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
        cleanResponse = cleanResponse.replaceFirst(RegExp(r'\s*```$'), '');
      }

      return jsonDecode(cleanResponse) as Map<String, dynamic>;
    } catch (e) {
      return _getFallbackFabricAnalysis();
    }
  }

  List<String> _parsePatternResponse(String response) {
    try {
      String cleanResponse = response.trim();

      if (cleanResponse.startsWith('```')) {
        cleanResponse =
            cleanResponse.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
        cleanResponse = cleanResponse.replaceFirst(RegExp(r'\s*```$'), '');
      }

      final decoded = jsonDecode(cleanResponse);
      return List<String>.from(decoded);
    } catch (e) {
      return ['Solid', 'Stripes', 'Checkered'];
    }
  }

  List<String> _extractColorsFromText(String text) {
    final colors = <String>[];
    final colorRegex = RegExp(
        r'\b(?:red|blue|green|yellow|black|white|gray|grey|brown|pink|purple|orange|navy|beige|cream|gold|silver|maroon|teal|olive|lime|aqua|fuchsia)\b',
        caseSensitive: false);

    final matches = colorRegex.allMatches(text.toLowerCase());
    for (final match in matches) {
      final color = match.group(0)!;
      if (!colors.contains(color)) {
        colors.add(color);
      }
      if (colors.length >= 5) break;
    }

    if (colors.isEmpty) {
      return ['Navy', 'White', 'Gray', 'Black', 'Beige'];
    }

    return colors;
  }

  List<Map<String, dynamic>> _getFallbackDesigns() {
    return [
      {
        'title': 'Classic Business Shirt',
        'description':
            'A timeless white business shirt with clean lines and professional styling',
        'garmentType': 'shirt',
        'colors': ['White', 'Light Blue', 'Cream'],
        'fabrics': ['Cotton', 'Cotton Blend'],
        'patterns': ['Solid', 'Subtle Texture'],
        'confidence': 0.8,
        'parameters': {
          'style': 'classic',
          'fit': 'regular',
          'occasion': 'business',
          'features': ['Button-down collar', 'Chest pocket', 'French cuffs']
        },
        'imageUrls': []
      },
      {
        'title': 'Modern Casual Dress',
        'description':
            'A contemporary A-line dress with comfortable fit and versatile styling',
        'garmentType': 'dress',
        'colors': ['Navy', 'Black', 'Burgundy'],
        'fabrics': ['Jersey', 'Cotton'],
        'patterns': ['Solid', 'Subtle Print'],
        'confidence': 0.75,
        'parameters': {
          'style': 'modern',
          'fit': 'regular',
          'occasion': 'casual',
          'features': ['A-line cut', 'Knee length', 'Short sleeves']
        },
        'imageUrls': []
      }
    ];
  }

  Map<String, dynamic> _getFallbackFabricAnalysis() {
    return {
      'score': 0.7,
      'reasons': [
        'Good durability for everyday wear',
        'Easy to care for and maintain',
        'Comfortable against skin'
      ],
      'alternatives': ['Cotton blend', 'Linen', 'Modal'],
      'care': ['Machine wash cold', 'Tumble dry low', 'Iron on medium heat']
    };
  }
}
