import 'package:equatable/equatable.dart';

class AIDesignSuggestion extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final Map<String, dynamic> designParameters;
  final List<String> suggestedColors;
  final List<String> suggestedFabrics;
  final List<String> suggestedPatterns;
  final double confidenceScore;
  final String aiModel;
  final DateTime createdAt;
  final bool isApplied;
  final Map<String, double>? measurements;
  final String? garmentType;
  final Map<String, dynamic>? stylePreferences;

  const AIDesignSuggestion({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.designParameters,
    required this.suggestedColors,
    required this.suggestedFabrics,
    required this.suggestedPatterns,
    required this.confidenceScore,
    required this.aiModel,
    required this.createdAt,
    this.isApplied = false,
    this.measurements,
    this.garmentType,
    this.stylePreferences,
  });

  factory AIDesignSuggestion.fromJson(Map<String, dynamic> json) {
    return AIDesignSuggestion(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      designParameters:
          Map<String, dynamic>.from(json['designParameters'] as Map),
      suggestedColors: List<String>.from(json['suggestedColors'] as List),
      suggestedFabrics: List<String>.from(json['suggestedFabrics'] as List),
      suggestedPatterns: List<String>.from(json['suggestedPatterns'] as List),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      aiModel: json['aiModel'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isApplied: json['isApplied'] as bool? ?? false,
      measurements: json['measurements'] != null
          ? Map<String, double>.from(json['measurements'] as Map)
          : null,
      garmentType: json['garmentType'] as String?,
      stylePreferences: json['stylePreferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'designParameters': designParameters,
      'suggestedColors': suggestedColors,
      'suggestedFabrics': suggestedFabrics,
      'suggestedPatterns': suggestedPatterns,
      'confidenceScore': confidenceScore,
      'aiModel': aiModel,
      'createdAt': createdAt.toIso8601String(),
      'isApplied': isApplied,
      'measurements': measurements,
      'garmentType': garmentType,
      'stylePreferences': stylePreferences,
    };
  }

  AIDesignSuggestion copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? imageUrls,
    Map<String, dynamic>? designParameters,
    List<String>? suggestedColors,
    List<String>? suggestedFabrics,
    List<String>? suggestedPatterns,
    double? confidenceScore,
    String? aiModel,
    DateTime? createdAt,
    bool? isApplied,
    Map<String, double>? measurements,
    String? garmentType,
    Map<String, dynamic>? stylePreferences,
  }) {
    return AIDesignSuggestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      designParameters: designParameters ?? this.designParameters,
      suggestedColors: suggestedColors ?? this.suggestedColors,
      suggestedFabrics: suggestedFabrics ?? this.suggestedFabrics,
      suggestedPatterns: suggestedPatterns ?? this.suggestedPatterns,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      aiModel: aiModel ?? this.aiModel,
      createdAt: createdAt ?? this.createdAt,
      isApplied: isApplied ?? this.isApplied,
      measurements: measurements ?? this.measurements,
      garmentType: garmentType ?? this.garmentType,
      stylePreferences: stylePreferences ?? this.stylePreferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        imageUrls,
        designParameters,
        suggestedColors,
        suggestedFabrics,
        suggestedPatterns,
        confidenceScore,
        aiModel,
        createdAt,
        isApplied,
        measurements,
        garmentType,
        stylePreferences,
      ];
}

class DesignPrompt extends Equatable {
  final String userInput;
  final Map<String, double>? bodyMeasurements;
  final List<String> stylePreferences;
  final String? preferredFabric;
  final List<String> preferredColors;
  final String? occasion;
  final String? budget;
  final Map<String, dynamic>? additionalRequirements;

  const DesignPrompt({
    required this.userInput,
    this.bodyMeasurements,
    required this.stylePreferences,
    this.preferredFabric,
    required this.preferredColors,
    this.occasion,
    this.budget,
    this.additionalRequirements,
  });

  factory DesignPrompt.fromJson(Map<String, dynamic> json) {
    return DesignPrompt(
      userInput: json['userInput'] as String,
      bodyMeasurements: json['bodyMeasurements'] != null
          ? Map<String, double>.from(json['bodyMeasurements'] as Map)
          : null,
      stylePreferences: List<String>.from(json['stylePreferences'] as List),
      preferredFabric: json['preferredFabric'] as String?,
      preferredColors: List<String>.from(json['preferredColors'] as List),
      occasion: json['occasion'] as String?,
      budget: json['budget'] as String?,
      additionalRequirements:
          json['additionalRequirements'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userInput': userInput,
      'bodyMeasurements': bodyMeasurements,
      'stylePreferences': stylePreferences,
      'preferredFabric': preferredFabric,
      'preferredColors': preferredColors,
      'occasion': occasion,
      'budget': budget,
      'additionalRequirements': additionalRequirements,
    };
  }

  String toPromptString() {
    final buffer = StringBuffer();
    buffer.write('Design a custom garment with the following requirements:\n');
    buffer.write('User request: $userInput\n');

    if (stylePreferences.isNotEmpty) {
      buffer.write('Style preferences: ${stylePreferences.join(', ')}\n');
    }

    if (preferredFabric != null) {
      buffer.write('Preferred fabric: $preferredFabric\n');
    }

    if (preferredColors.isNotEmpty) {
      buffer.write('Preferred colors: ${preferredColors.join(', ')}\n');
    }

    if (occasion != null) {
      buffer.write('Occasion: $occasion\n');
    }

    if (budget != null) {
      buffer.write('Budget range: $budget\n');
    }

    if (bodyMeasurements != null && bodyMeasurements!.isNotEmpty) {
      buffer.write(
        'Body measurements provided: ${bodyMeasurements!.keys.join(', ')}\n',
      );
    }

    buffer.write(
      '\nPlease provide detailed design suggestions including colors, patterns, and styling recommendations.',
    );

    return buffer.toString();
  }

  @override
  List<Object?> get props => [
        userInput,
        bodyMeasurements,
        stylePreferences,
        preferredFabric,
        preferredColors,
        occasion,
        budget,
        additionalRequirements,
      ];
}
