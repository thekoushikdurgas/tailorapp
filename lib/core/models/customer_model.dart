import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/models/shared_models.dart';

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

// BodyMeasurements and StylePreferences classes moved to shared_models.dart
