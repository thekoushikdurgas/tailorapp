import 'package:equatable/equatable.dart';

class TailorModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final TailorAddress? address;
  final TailorProfile profile;
  final TailorBusinessInfo businessInfo;
  final List<String> specializations;
  final List<String> certifications;
  final TailorRatings ratings;
  final TailorPreferences preferences;
  final List<String> activeOrders;
  final List<String> completedOrders;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final bool isActive;

  const TailorModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    this.dateOfBirth,
    this.gender,
    this.address,
    required this.profile,
    required this.businessInfo,
    required this.specializations,
    required this.certifications,
    required this.ratings,
    required this.preferences,
    required this.activeOrders,
    required this.completedOrders,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.isActive = true,
  });

  factory TailorModel.fromJson(Map<String, dynamic> json) {
    return TailorModel(
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
          ? TailorAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      profile: TailorProfile.fromJson(json['profile'] as Map<String, dynamic>),
      businessInfo: TailorBusinessInfo.fromJson(
        json['businessInfo'] as Map<String, dynamic>,
      ),
      specializations: List<String>.from(json['specializations'] as List),
      certifications: List<String>.from(json['certifications'] as List),
      ratings: TailorRatings.fromJson(json['ratings'] as Map<String, dynamic>),
      preferences: TailorPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>,
      ),
      activeOrders: List<String>.from(json['activeOrders'] as List),
      completedOrders: List<String>.from(json['completedOrders'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
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
      'profile': profile.toJson(),
      'businessInfo': businessInfo.toJson(),
      'specializations': specializations,
      'certifications': certifications,
      'ratings': ratings.toJson(),
      'preferences': preferences.toJson(),
      'activeOrders': activeOrders,
      'completedOrders': completedOrders,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }

  TailorModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    TailorAddress? address,
    TailorProfile? profile,
    TailorBusinessInfo? businessInfo,
    List<String>? specializations,
    List<String>? certifications,
    TailorRatings? ratings,
    TailorPreferences? preferences,
    List<String>? activeOrders,
    List<String>? completedOrders,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isActive,
  }) {
    return TailorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      profile: profile ?? this.profile,
      businessInfo: businessInfo ?? this.businessInfo,
      specializations: specializations ?? this.specializations,
      certifications: certifications ?? this.certifications,
      ratings: ratings ?? this.ratings,
      preferences: preferences ?? this.preferences,
      activeOrders: activeOrders ?? this.activeOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
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
        profile,
        businessInfo,
        specializations,
        certifications,
        ratings,
        preferences,
        activeOrders,
        completedOrders,
        createdAt,
        updatedAt,
        isVerified,
        isActive,
      ];
}

class TailorAddress extends Equatable {
  final String street;
  final String? apartment;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isWorkAddress;

  const TailorAddress({
    required this.street,
    this.apartment,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isWorkAddress = true,
  });

  factory TailorAddress.fromJson(Map<String, dynamic> json) {
    return TailorAddress(
      street: json['street'] as String,
      apartment: json['apartment'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      isWorkAddress: json['isWorkAddress'] as bool? ?? true,
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
      'isWorkAddress': isWorkAddress,
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
        isWorkAddress,
      ];
}

class TailorProfile extends Equatable {
  final String bio;
  final int experienceYears;
  final List<String> portfolioImages;
  final String? workingHours;
  final String? timezone;
  final bool acceptsNewClients;
  final double? hourlyRate;
  final String? websiteUrl;
  final Map<String, String>? socialMedia;

  const TailorProfile({
    required this.bio,
    required this.experienceYears,
    required this.portfolioImages,
    this.workingHours,
    this.timezone,
    this.acceptsNewClients = true,
    this.hourlyRate,
    this.websiteUrl,
    this.socialMedia,
  });

  factory TailorProfile.fromJson(Map<String, dynamic> json) {
    return TailorProfile(
      bio: json['bio'] as String,
      experienceYears: json['experienceYears'] as int,
      portfolioImages: List<String>.from(json['portfolioImages'] as List),
      workingHours: json['workingHours'] as String?,
      timezone: json['timezone'] as String?,
      acceptsNewClients: json['acceptsNewClients'] as bool? ?? true,
      hourlyRate: json['hourlyRate'] as double?,
      websiteUrl: json['websiteUrl'] as String?,
      socialMedia: json['socialMedia'] != null
          ? Map<String, String>.from(json['socialMedia'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'experienceYears': experienceYears,
      'portfolioImages': portfolioImages,
      'workingHours': workingHours,
      'timezone': timezone,
      'acceptsNewClients': acceptsNewClients,
      'hourlyRate': hourlyRate,
      'websiteUrl': websiteUrl,
      'socialMedia': socialMedia,
    };
  }

  @override
  List<Object?> get props => [
        bio,
        experienceYears,
        portfolioImages,
        workingHours,
        timezone,
        acceptsNewClients,
        hourlyRate,
        websiteUrl,
        socialMedia,
      ];
}

class TailorBusinessInfo extends Equatable {
  final String businessName;
  final String? businessRegistration;
  final String? taxId;
  final bool hasInsurance;
  final String? insuranceProvider;
  final List<String> paymentMethods;
  final String? bankAccount;
  final double minimumOrder;
  final int leadTimeWeeks;

  const TailorBusinessInfo({
    required this.businessName,
    this.businessRegistration,
    this.taxId,
    this.hasInsurance = false,
    this.insuranceProvider,
    required this.paymentMethods,
    this.bankAccount,
    required this.minimumOrder,
    required this.leadTimeWeeks,
  });

  factory TailorBusinessInfo.fromJson(Map<String, dynamic> json) {
    return TailorBusinessInfo(
      businessName: json['businessName'] as String,
      businessRegistration: json['businessRegistration'] as String?,
      taxId: json['taxId'] as String?,
      hasInsurance: json['hasInsurance'] as bool? ?? false,
      insuranceProvider: json['insuranceProvider'] as String?,
      paymentMethods: List<String>.from(json['paymentMethods'] as List),
      bankAccount: json['bankAccount'] as String?,
      minimumOrder: json['minimumOrder'] as double,
      leadTimeWeeks: json['leadTimeWeeks'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'businessRegistration': businessRegistration,
      'taxId': taxId,
      'hasInsurance': hasInsurance,
      'insuranceProvider': insuranceProvider,
      'paymentMethods': paymentMethods,
      'bankAccount': bankAccount,
      'minimumOrder': minimumOrder,
      'leadTimeWeeks': leadTimeWeeks,
    };
  }

  @override
  List<Object?> get props => [
        businessName,
        businessRegistration,
        taxId,
        hasInsurance,
        insuranceProvider,
        paymentMethods,
        bankAccount,
        minimumOrder,
        leadTimeWeeks,
      ];
}

class TailorRatings extends Equatable {
  final double overall;
  final double quality;
  final double communication;
  final double timeliness;
  final double value;
  final int totalReviews;
  final int totalOrders;

  const TailorRatings({
    this.overall = 0.0,
    this.quality = 0.0,
    this.communication = 0.0,
    this.timeliness = 0.0,
    this.value = 0.0,
    this.totalReviews = 0,
    this.totalOrders = 0,
  });

  factory TailorRatings.fromJson(Map<String, dynamic> json) {
    return TailorRatings(
      overall: json['overall'] as double,
      quality: json['quality'] as double,
      communication: json['communication'] as double,
      timeliness: json['timeliness'] as double,
      value: json['value'] as double,
      totalReviews: json['totalReviews'] as int,
      totalOrders: json['totalOrders'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'quality': quality,
      'communication': communication,
      'timeliness': timeliness,
      'value': value,
      'totalReviews': totalReviews,
      'totalOrders': totalOrders,
    };
  }

  @override
  List<Object?> get props => [
        overall,
        quality,
        communication,
        timeliness,
        value,
        totalReviews,
        totalOrders,
      ];
}

class TailorPreferences extends Equatable {
  final List<String> preferredGarmentTypes;
  final List<String> preferredFabrics;
  final String? workingStyle;
  final bool acceptsRushOrders;
  final bool providesConsultation;
  final bool acceptsInternationalOrders;
  final Map<String, dynamic>? customPreferences;

  const TailorPreferences({
    required this.preferredGarmentTypes,
    required this.preferredFabrics,
    this.workingStyle,
    this.acceptsRushOrders = false,
    this.providesConsultation = true,
    this.acceptsInternationalOrders = false,
    this.customPreferences,
  });

  factory TailorPreferences.fromJson(Map<String, dynamic> json) {
    return TailorPreferences(
      preferredGarmentTypes:
          List<String>.from(json['preferredGarmentTypes'] as List),
      preferredFabrics: List<String>.from(json['preferredFabrics'] as List),
      workingStyle: json['workingStyle'] as String?,
      acceptsRushOrders: json['acceptsRushOrders'] as bool? ?? false,
      providesConsultation: json['providesConsultation'] as bool? ?? true,
      acceptsInternationalOrders:
          json['acceptsInternationalOrders'] as bool? ?? false,
      customPreferences: json['customPreferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredGarmentTypes': preferredGarmentTypes,
      'preferredFabrics': preferredFabrics,
      'workingStyle': workingStyle,
      'acceptsRushOrders': acceptsRushOrders,
      'providesConsultation': providesConsultation,
      'acceptsInternationalOrders': acceptsInternationalOrders,
      'customPreferences': customPreferences,
    };
  }

  @override
  List<Object?> get props => [
        preferredGarmentTypes,
        preferredFabrics,
        workingStyle,
        acceptsRushOrders,
        providesConsultation,
        acceptsInternationalOrders,
        customPreferences,
      ];
}
