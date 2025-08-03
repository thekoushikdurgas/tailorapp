import 'package:equatable/equatable.dart';

/// Shared body measurements model used across customer and user models
class BodyMeasurements extends Equatable {
  final double? height;
  final double? weight;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? shoulders;
  final double? armLength;
  final double? inseam;
  final double? neck;
  final double? bust;
  final double? thigh;
  final String unit; // 'cm' or 'inch'
  final DateTime lastUpdated;
  final Map<String, double>? additionalMeasurements;

  const BodyMeasurements({
    this.height,
    this.weight,
    this.chest,
    this.waist,
    this.hips,
    this.shoulders,
    this.armLength,
    this.inseam,
    this.neck,
    this.bust,
    this.thigh,
    required this.unit,
    required this.lastUpdated,
    this.additionalMeasurements,
  });

  factory BodyMeasurements.fromJson(Map<String, dynamic> json) {
    return BodyMeasurements(
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      chest: json['chest'] as double?,
      waist: json['waist'] as double?,
      hips: json['hips'] as double?,
      shoulders: json['shoulders'] as double?,
      armLength: json['armLength'] as double?,
      inseam: json['inseam'] as double?,
      neck: json['neck'] as double?,
      bust: json['bust'] as double?,
      thigh: json['thigh'] as double?,
      unit: json['unit'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      additionalMeasurements: json['additionalMeasurements'] != null
          ? Map<String, double>.from(json['additionalMeasurements'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'shoulders': shoulders,
      'armLength': armLength,
      'inseam': inseam,
      'neck': neck,
      'bust': bust,
      'thigh': thigh,
      'unit': unit,
      'lastUpdated': lastUpdated.toIso8601String(),
      'additionalMeasurements': additionalMeasurements,
    };
  }

  BodyMeasurements copyWith({
    double? height,
    double? weight,
    double? chest,
    double? waist,
    double? hips,
    double? shoulders,
    double? armLength,
    double? inseam,
    double? neck,
    double? bust,
    double? thigh,
    String? unit,
    DateTime? lastUpdated,
    Map<String, double>? additionalMeasurements,
  }) {
    return BodyMeasurements(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      shoulders: shoulders ?? this.shoulders,
      armLength: armLength ?? this.armLength,
      inseam: inseam ?? this.inseam,
      neck: neck ?? this.neck,
      bust: bust ?? this.bust,
      thigh: thigh ?? this.thigh,
      unit: unit ?? this.unit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      additionalMeasurements:
          additionalMeasurements ?? this.additionalMeasurements,
    );
  }

  @override
  List<Object?> get props => [
        height,
        weight,
        chest,
        waist,
        hips,
        shoulders,
        armLength,
        inseam,
        neck,
        bust,
        thigh,
        unit,
        lastUpdated,
        additionalMeasurements,
      ];
}

/// Shared style preferences model used across customer and user models
class StylePreferences extends Equatable {
  final List<String> preferredStyles;
  final List<String> preferredColors;
  final List<String> preferredFabrics;
  final List<String> dislikedColors;
  final List<String> dislikedFabrics;
  final String? fitPreference; // 'slim', 'regular', 'loose'
  final String? budgetRange;
  final List<String> occasions;
  final Map<String, dynamic>? customPreferences;

  const StylePreferences({
    required this.preferredStyles,
    required this.preferredColors,
    required this.preferredFabrics,
    required this.dislikedColors,
    required this.dislikedFabrics,
    this.fitPreference,
    this.budgetRange,
    required this.occasions,
    this.customPreferences,
  });

  factory StylePreferences.fromJson(Map<String, dynamic> json) {
    return StylePreferences(
      preferredStyles: List<String>.from(json['preferredStyles'] as List),
      preferredColors: List<String>.from(json['preferredColors'] as List),
      preferredFabrics: List<String>.from(json['preferredFabrics'] as List),
      dislikedColors: List<String>.from(json['dislikedColors'] as List),
      dislikedFabrics: List<String>.from(json['dislikedFabrics'] as List),
      fitPreference: json['fitPreference'] as String?,
      budgetRange: json['budgetRange'] as String?,
      occasions: List<String>.from(json['occasions'] as List),
      customPreferences: json['customPreferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredStyles': preferredStyles,
      'preferredColors': preferredColors,
      'preferredFabrics': preferredFabrics,
      'dislikedColors': dislikedColors,
      'dislikedFabrics': dislikedFabrics,
      'fitPreference': fitPreference,
      'budgetRange': budgetRange,
      'occasions': occasions,
      'customPreferences': customPreferences,
    };
  }

  StylePreferences copyWith({
    List<String>? preferredStyles,
    List<String>? preferredColors,
    List<String>? preferredFabrics,
    List<String>? dislikedColors,
    List<String>? dislikedFabrics,
    String? fitPreference,
    String? budgetRange,
    List<String>? occasions,
    Map<String, dynamic>? customPreferences,
  }) {
    return StylePreferences(
      preferredStyles: preferredStyles ?? this.preferredStyles,
      preferredColors: preferredColors ?? this.preferredColors,
      preferredFabrics: preferredFabrics ?? this.preferredFabrics,
      dislikedColors: dislikedColors ?? this.dislikedColors,
      dislikedFabrics: dislikedFabrics ?? this.dislikedFabrics,
      fitPreference: fitPreference ?? this.fitPreference,
      budgetRange: budgetRange ?? this.budgetRange,
      occasions: occasions ?? this.occasions,
      customPreferences: customPreferences ?? this.customPreferences,
    );
  }

  @override
  List<Object?> get props => [
        preferredStyles,
        preferredColors,
        preferredFabrics,
        dislikedColors,
        dislikedFabrics,
        fitPreference,
        budgetRange,
        occasions,
        customPreferences,
      ];
}
