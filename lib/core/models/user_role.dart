enum UserRole {
  customer,
  tailor,
  admin,
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.tailor:
        return 'Tailor';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get value {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.tailor:
        return 'tailor';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.customer:
        return 'Order custom clothing and designs';
      case UserRole.tailor:
        return 'Create garments and manage business';
      case UserRole.admin:
        return 'Manage platform and users';
    }
  }

  String get homeRoute {
    switch (this) {
      case UserRole.customer:
        return '/customer/home';
      case UserRole.tailor:
        return '/tailor/dashboard';
      case UserRole.admin:
        return '/admin/dashboard';
    }
  }

  List<String> get permissions {
    switch (this) {
      case UserRole.customer:
        return [
          'view_designs',
          'create_orders',
          'virtual_fitting',
          'manage_measurements',
          'view_orders',
          'provide_feedback',
        ];
      case UserRole.tailor:
        return [
          'manage_orders',
          'create_patterns',
          'manage_inventory',
          'communicate_customers',
          'quality_control',
          'manage_portfolio',
        ];
      case UserRole.admin:
        return [
          'manage_users',
          'platform_analytics',
          'content_management',
          'system_configuration',
          'manage_campaigns',
        ];
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'tailor':
        return UserRole.tailor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer; // Default to customer
    }
  }
}

class UserRoleSelection {
  final UserRole role;
  final bool isSelected;

  const UserRoleSelection({
    required this.role,
    this.isSelected = false,
  });

  UserRoleSelection copyWith({
    UserRole? role,
    bool? isSelected,
  }) {
    return UserRoleSelection(
      role: role ?? this.role,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class RoleBasedUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final Map<String, dynamic>? customClaims;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;

  const RoleBasedUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.customClaims,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
  });

  factory RoleBasedUser.fromJson(Map<String, dynamic> json) {
    return RoleBasedUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRoleExtension.fromString(json['role'] as String),
      customClaims: json['customClaims'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.value,
      'customClaims': customClaims,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  bool hasPermission(String permission) {
    return role.permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }

  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }

  RoleBasedUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    Map<String, dynamic>? customClaims,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return RoleBasedUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      customClaims: customClaims ?? this.customClaims,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
