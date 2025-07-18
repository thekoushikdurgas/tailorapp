import 'package:equatable/equatable.dart';

class GarmentModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final GarmentType type;
  final String? imageUrl;
  final List<String> colors;
  final String fabric;
  final String pattern;
  final Map<String, double> measurements;
  final double price;
  final GarmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? aiSuggestionId;
  final Map<String, dynamic>? customizations;

  const GarmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.imageUrl,
    required this.colors,
    required this.fabric,
    required this.pattern,
    required this.measurements,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.aiSuggestionId,
    this.customizations,
  });

  factory GarmentModel.fromJson(Map<String, dynamic> json) {
    return GarmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: GarmentType.fromString(json['type'] as String),
      imageUrl: json['imageUrl'] as String?,
      colors: List<String>.from(json['colors'] as List),
      fabric: json['fabric'] as String,
      pattern: json['pattern'] as String,
      measurements: Map<String, double>.from(json['measurements'] as Map),
      price: (json['price'] as num).toDouble(),
      status: GarmentStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      aiSuggestionId: json['aiSuggestionId'] as String?,
      customizations: json['customizations'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.value,
      'imageUrl': imageUrl,
      'colors': colors,
      'fabric': fabric,
      'pattern': pattern,
      'measurements': measurements,
      'price': price,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'aiSuggestionId': aiSuggestionId,
      'customizations': customizations,
    };
  }

  GarmentModel copyWith({
    String? id,
    String? name,
    String? description,
    GarmentType? type,
    String? imageUrl,
    List<String>? colors,
    String? fabric,
    String? pattern,
    Map<String, double>? measurements,
    double? price,
    GarmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? aiSuggestionId,
    Map<String, dynamic>? customizations,
  }) {
    return GarmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      colors: colors ?? this.colors,
      fabric: fabric ?? this.fabric,
      pattern: pattern ?? this.pattern,
      measurements: measurements ?? this.measurements,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aiSuggestionId: aiSuggestionId ?? this.aiSuggestionId,
      customizations: customizations ?? this.customizations,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        imageUrl,
        colors,
        fabric,
        pattern,
        measurements,
        price,
        status,
        createdAt,
        updatedAt,
        aiSuggestionId,
        customizations,
      ];
}

enum GarmentType {
  shirt('shirt'),
  dress('dress'),
  suit('suit'),
  jacket('jacket'),
  trousers('trousers'),
  skirt('skirt'),
  blouse('blouse'),
  other('other');

  const GarmentType(this.value);
  final String value;

  static GarmentType fromString(String value) {
    return GarmentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GarmentType.other,
    );
  }
}

enum GarmentStatus {
  draft('draft'),
  designing('designing'),
  aiProcessing('ai_processing'),
  readyForReview('ready_for_review'),
  approved('approved'),
  inProduction('in_production'),
  completed('completed'),
  delivered('delivered'),
  cancelled('cancelled');

  const GarmentStatus(this.value);
  final String value;

  static GarmentStatus fromString(String value) {
    return GarmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => GarmentStatus.draft,
    );
  }
}
