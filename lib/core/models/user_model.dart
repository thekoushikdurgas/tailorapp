import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/core/models/shared_models.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final UserRole role;
  final UserAddress? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  // Role-specific data
  final CustomerData? customerData;
  final TailorData? tailorData;
  final AdminData? adminData;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.dateOfBirth,
    this.gender,
    required this.role,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.isActive = true,
    this.metadata,
    this.customerData,
    this.tailorData,
    this.adminData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = UserRoleExtension.fromString(json['role'] as String);

    return UserModel(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      role: role,
      address: json['address'] != null
          ? UserAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? json['createdAt'] as String),
      updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? json['updatedAt'] as String),
      isVerified: json['email_verified'] as bool? ??
          json['isVerified'] as bool? ??
          false,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
      customerData: role == UserRole.customer &&
              (json['customer_data'] ?? json['customerData']) != null
          ? CustomerData.fromJson((json['customer_data'] ??
              json['customerData']) as Map<String, dynamic>)
          : null,
      tailorData: role == UserRole.tailor &&
              (json['tailor_data'] ?? json['tailorData']) != null
          ? TailorData.fromJson((json['tailor_data'] ?? json['tailorData'])
              as Map<String, dynamic>)
          : null,
      adminData: role == UserRole.admin &&
              (json['admin_data'] ?? json['adminData']) != null
          ? AdminData.fromJson(
              (json['admin_data'] ?? json['adminData']) as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name, // Map to full_name for database compatibility
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'role': role.value,
      'address': address?.toJson(),
      'created_at': createdAt
          .toIso8601String(), // Map to created_at for database compatibility
      'updated_at': updatedAt
          .toIso8601String(), // Map to updated_at for database compatibility
      'email_verified':
          isVerified, // Map to email_verified for database compatibility
      'is_active': isActive, // Map to is_active for database compatibility
      'metadata': metadata,
      if (customerData != null)
        'customer_data': customerData!
            .toJson(), // Map to customer_data for database compatibility
      if (tailorData != null)
        'tailor_data': tailorData!
            .toJson(), // Map to tailor_data for database compatibility
      if (adminData != null)
        'admin_data':
            adminData!.toJson(), // Map to admin_data for database compatibility
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    UserRole? role,
    UserAddress? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isActive,
    Map<String, dynamic>? metadata,
    CustomerData? customerData,
    TailorData? tailorData,
    AdminData? adminData,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      customerData: customerData ?? this.customerData,
      tailorData: tailorData ?? this.tailorData,
      adminData: adminData ?? this.adminData,
    );
  }

  // Static factory methods for creating specific user types
  static UserModel customer({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    UserAddress? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isVerified = false,
    bool isActive = true,
    Map<String, dynamic>? metadata,
    CustomerData? customerData,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      dateOfBirth: dateOfBirth,
      gender: gender,
      role: UserRole.customer,
      address: address,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isVerified: isVerified,
      isActive: isActive,
      metadata: metadata,
      customerData: customerData ?? CustomerData.empty(),
    );
  }

  static UserModel tailor({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    UserAddress? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isVerified = false,
    bool isActive = true,
    Map<String, dynamic>? metadata,
    TailorData? tailorData,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      dateOfBirth: dateOfBirth,
      gender: gender,
      role: UserRole.tailor,
      address: address,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isVerified: isVerified,
      isActive: isActive,
      metadata: metadata,
      tailorData: tailorData ?? TailorData.empty(),
    );
  }

  static UserModel admin({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    UserAddress? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isVerified = false,
    bool isActive = true,
    Map<String, dynamic>? metadata,
    AdminData? adminData,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      dateOfBirth: dateOfBirth,
      gender: gender,
      role: UserRole.admin,
      address: address,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isVerified: isVerified,
      isActive: isActive,
      metadata: metadata,
      adminData: adminData ?? AdminData.empty(),
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
        role,
        address,
        createdAt,
        updatedAt,
        isVerified,
        isActive,
        metadata,
        customerData,
        tailorData,
        adminData,
      ];
}

class UserAddress extends Equatable {
  final String street;
  final String? apartment;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  const UserAddress({
    required this.street,
    this.apartment,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
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

// Customer-specific data
class CustomerData extends Equatable {
  final BodyMeasurements? measurements;
  final StylePreferences stylePreferences;
  final List<String> orderHistory;
  final Map<String, dynamic>? preferences;

  const CustomerData({
    this.measurements,
    required this.stylePreferences,
    required this.orderHistory,
    this.preferences,
  });

  factory CustomerData.empty() {
    return const CustomerData(
      stylePreferences: StylePreferences(
        preferredStyles: [],
        preferredColors: [],
        preferredFabrics: [],
        dislikedColors: [],
        dislikedFabrics: [],
        occasions: [],
      ),
      orderHistory: [],
    );
  }

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      measurements: json['measurements'] != null
          ? BodyMeasurements.fromJson(
              json['measurements'] as Map<String, dynamic>,
            )
          : null,
      stylePreferences: StylePreferences.fromJson(
        json['stylePreferences'] as Map<String, dynamic>,
      ),
      orderHistory: List<String>.from(json['orderHistory'] as List),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'measurements': measurements?.toJson(),
      'stylePreferences': stylePreferences.toJson(),
      'orderHistory': orderHistory,
      'preferences': preferences,
    };
  }

  CustomerData copyWith({
    BodyMeasurements? measurements,
    StylePreferences? stylePreferences,
    List<String>? orderHistory,
    Map<String, dynamic>? preferences,
  }) {
    return CustomerData(
      measurements: measurements ?? this.measurements,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      orderHistory: orderHistory ?? this.orderHistory,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        measurements,
        stylePreferences,
        orderHistory,
        preferences,
      ];
}

// Tailor-specific data
class TailorData extends Equatable {
  final String bio;
  final int experienceYears;
  final List<String> specializations;
  final List<String> certifications;
  final List<String> portfolioImages;
  final TailorRatings ratings;
  final BusinessInfo businessInfo;
  final List<String> activeOrders;
  final List<String> completedOrders;
  final TailorPreferences preferences;

  const TailorData({
    required this.bio,
    required this.experienceYears,
    required this.specializations,
    required this.certifications,
    required this.portfolioImages,
    required this.ratings,
    required this.businessInfo,
    required this.activeOrders,
    required this.completedOrders,
    required this.preferences,
  });

  factory TailorData.empty() {
    return TailorData(
      bio: '',
      experienceYears: 0,
      specializations: const [],
      certifications: const [],
      portfolioImages: const [],
      ratings: const TailorRatings(),
      businessInfo: BusinessInfo.empty(),
      activeOrders: const [],
      completedOrders: const [],
      preferences: TailorPreferences.empty(),
    );
  }

  factory TailorData.fromJson(Map<String, dynamic> json) {
    return TailorData(
      bio: json['bio'] as String,
      experienceYears: json['experienceYears'] as int,
      specializations: List<String>.from(json['specializations'] as List),
      certifications: List<String>.from(json['certifications'] as List),
      portfolioImages: List<String>.from(json['portfolioImages'] as List),
      ratings: TailorRatings.fromJson(json['ratings'] as Map<String, dynamic>),
      businessInfo:
          BusinessInfo.fromJson(json['businessInfo'] as Map<String, dynamic>),
      activeOrders: List<String>.from(json['activeOrders'] as List),
      completedOrders: List<String>.from(json['completedOrders'] as List),
      preferences: TailorPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'experienceYears': experienceYears,
      'specializations': specializations,
      'certifications': certifications,
      'portfolioImages': portfolioImages,
      'ratings': ratings.toJson(),
      'businessInfo': businessInfo.toJson(),
      'activeOrders': activeOrders,
      'completedOrders': completedOrders,
      'preferences': preferences.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        bio,
        experienceYears,
        specializations,
        certifications,
        portfolioImages,
        ratings,
        businessInfo,
        activeOrders,
        completedOrders,
        preferences,
      ];
}

// Admin-specific data
class AdminData extends Equatable {
  final String? department;
  final String? position;
  final List<String> permissions;
  final AdminActivityLog activityLog;
  final Map<String, dynamic>? customSettings;

  const AdminData({
    this.department,
    this.position,
    required this.permissions,
    required this.activityLog,
    this.customSettings,
  });

  factory AdminData.empty() {
    return AdminData(
      permissions: const [],
      activityLog: AdminActivityLog(
        lastLogin: DateTime.now(),
        totalLogins: 0,
        recentActions: const [],
        totalActionsThisMonth: 0,
      ),
    );
  }

  factory AdminData.fromJson(Map<String, dynamic> json) {
    return AdminData(
      department: json['department'] as String?,
      position: json['position'] as String?,
      permissions: List<String>.from(json['permissions'] as List),
      activityLog: AdminActivityLog.fromJson(
        json['activityLog'] as Map<String, dynamic>,
      ),
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department': department,
      'position': position,
      'permissions': permissions,
      'activityLog': activityLog.toJson(),
      'customSettings': customSettings,
    };
  }

  @override
  List<Object?> get props => [
        department,
        position,
        permissions,
        activityLog,
        customSettings,
      ];
}

// Supporting classes moved to shared_models.dart

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

class BusinessInfo extends Equatable {
  final String businessName;
  final String? businessRegistration;
  final String? taxId;
  final bool hasInsurance;
  final String? insuranceProvider;
  final List<String> paymentMethods;
  final String? bankAccount;
  final double minimumOrder;
  final int leadTimeWeeks;

  const BusinessInfo({
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

  factory BusinessInfo.empty() {
    return const BusinessInfo(
      businessName: '',
      paymentMethods: [],
      minimumOrder: 0.0,
      leadTimeWeeks: 1,
    );
  }

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
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

  factory TailorPreferences.empty() {
    return const TailorPreferences(
      preferredGarmentTypes: [],
      preferredFabrics: [],
    );
  }

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

class AdminActivityLog extends Equatable {
  final DateTime lastLogin;
  final int totalLogins;
  final List<AdminAction> recentActions;
  final int totalActionsThisMonth;

  const AdminActivityLog({
    required this.lastLogin,
    this.totalLogins = 0,
    required this.recentActions,
    this.totalActionsThisMonth = 0,
  });

  factory AdminActivityLog.fromJson(Map<String, dynamic> json) {
    return AdminActivityLog(
      lastLogin: DateTime.parse(json['lastLogin'] as String),
      totalLogins: json['totalLogins'] as int? ?? 0,
      recentActions: (json['recentActions'] as List)
          .map((a) => AdminAction.fromJson(a as Map<String, dynamic>))
          .toList(),
      totalActionsThisMonth: json['totalActionsThisMonth'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastLogin': lastLogin.toIso8601String(),
      'totalLogins': totalLogins,
      'recentActions': recentActions.map((a) => a.toJson()).toList(),
      'totalActionsThisMonth': totalActionsThisMonth,
    };
  }

  @override
  List<Object?> get props => [
        lastLogin,
        totalLogins,
        recentActions,
        totalActionsThisMonth,
      ];
}

class AdminAction extends Equatable {
  final String action;
  final String? target;
  final DateTime timestamp;
  final String? ipAddress;
  final Map<String, dynamic>? metadata;

  const AdminAction({
    required this.action,
    this.target,
    required this.timestamp,
    this.ipAddress,
    this.metadata,
  });

  factory AdminAction.fromJson(Map<String, dynamic> json) {
    return AdminAction(
      action: json['action'] as String,
      target: json['target'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipAddress: json['ipAddress'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'target': target,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        action,
        target,
        timestamp,
        ipAddress,
        metadata,
      ];
}
