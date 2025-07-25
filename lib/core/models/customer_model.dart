import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final CustomerAddress? address;
  final BodyMeasurements? measurements;
  final StylePreferences stylePreferences;
  final List<String> orderHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final Map<String, dynamic>? preferences;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.measurements,
    required this.stylePreferences,
    required this.orderHistory,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.preferences,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      address: json['address'] != null
          ? CustomerAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      measurements: json['measurements'] != null
          ? BodyMeasurements.fromJson(
              json['measurements'] as Map<String, dynamic>,
            )
          : null,
      stylePreferences: StylePreferences.fromJson(
        json['stylePreferences'] as Map<String, dynamic>,
      ),
      orderHistory: List<String>.from(json['orderHistory'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address?.toJson(),
      'measurements': measurements?.toJson(),
      'stylePreferences': stylePreferences.toJson(),
      'orderHistory': orderHistory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
      'preferences': preferences,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    CustomerAddress? address,
    BodyMeasurements? measurements,
    StylePreferences? stylePreferences,
    List<String>? orderHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    Map<String, dynamic>? preferences,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      measurements: measurements ?? this.measurements,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      orderHistory: orderHistory ?? this.orderHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        profileImageUrl,
        dateOfBirth,
        gender,
        address,
        measurements,
        stylePreferences,
        orderHistory,
        createdAt,
        updatedAt,
        isVerified,
        preferences,
      ];
}

class CustomerAddress extends Equatable {
  final String street;
  final String? apartment;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  const CustomerAddress({
    required this.street,
    this.apartment,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      street: json['street'] as String,
      apartment: json['apartment'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'apartment': apartment,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  @override
  List<Object?> get props => [
        street,
        apartment,
        city,
        state,
        postalCode,
        country,
        isDefault,
      ];
}

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
