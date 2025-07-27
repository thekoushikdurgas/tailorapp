import 'package:equatable/equatable.dart';

class AdminModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final AdminProfile profile;
  final AdminPreferences preferences;
  final AdminActivityLog activityLog;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isSuperAdmin;

  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.role,
    required this.permissions,
    required this.profile,
    required this.preferences,
    required this.activityLog,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isSuperAdmin = false,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: AdminRoleExtension.fromString(json['role'] as String),
      permissions: (json['permissions'] as List)
          .map((p) => AdminPermissionExtension.fromString(p as String))
          .toList(),
      profile: AdminProfile.fromJson(json['profile'] as Map<String, dynamic>),
      preferences: AdminPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>,
      ),
      activityLog: AdminActivityLog.fromJson(
        json['activityLog'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isSuperAdmin: json['isSuperAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'role': role.value,
      'permissions': permissions.map((p) => p.value).toList(),
      'profile': profile.toJson(),
      'preferences': preferences.toJson(),
      'activityLog': activityLog.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'isSuperAdmin': isSuperAdmin,
    };
  }

  bool hasPermission(AdminPermission permission) {
    return isSuperAdmin || permissions.contains(permission);
  }

  bool hasAnyPermission(List<AdminPermission> requiredPermissions) {
    return isSuperAdmin ||
        requiredPermissions
            .any((permission) => permissions.contains(permission));
  }

  bool hasAllPermissions(List<AdminPermission> requiredPermissions) {
    return isSuperAdmin ||
        requiredPermissions
            .every((permission) => permissions.contains(permission));
  }

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    AdminRole? role,
    List<AdminPermission>? permissions,
    AdminProfile? profile,
    AdminPreferences? preferences,
    AdminActivityLog? activityLog,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isSuperAdmin,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      activityLog: activityLog ?? this.activityLog,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        profileImageUrl,
        role,
        permissions,
        profile,
        preferences,
        activityLog,
        createdAt,
        updatedAt,
        isActive,
        isSuperAdmin,
      ];
}

enum AdminRole {
  superAdmin,
  platformManager,
  contentManager,
  supportManager,
  analyticsManager,
}

extension AdminRoleExtension on AdminRole {
  String get name {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.platformManager:
        return 'Platform Manager';
      case AdminRole.contentManager:
        return 'Content Manager';
      case AdminRole.supportManager:
        return 'Support Manager';
      case AdminRole.analyticsManager:
        return 'Analytics Manager';
    }
  }

  String get value {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.platformManager:
        return 'platform_manager';
      case AdminRole.contentManager:
        return 'content_manager';
      case AdminRole.supportManager:
        return 'support_manager';
      case AdminRole.analyticsManager:
        return 'analytics_manager';
    }
  }

  static AdminRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'super_admin':
        return AdminRole.superAdmin;
      case 'platform_manager':
        return AdminRole.platformManager;
      case 'content_manager':
        return AdminRole.contentManager;
      case 'support_manager':
        return AdminRole.supportManager;
      case 'analytics_manager':
        return AdminRole.analyticsManager;
      default:
        return AdminRole.platformManager;
    }
  }
}

enum AdminPermission {
  // User Management
  manageUsers,
  viewUsers,
  banUsers,
  verifyUsers,

  // Content Management
  manageContent,
  moderateContent,
  manageCampaigns,

  // Platform Analytics
  viewAnalytics,
  exportData,
  generateReports,

  // System Configuration
  configureSystem,
  manageIntegrations,
  manageSecurity,

  // Support
  manageSupport,
  viewTickets,
  respondToTickets,

  // Financial
  viewFinancials,
  managePayments,
  generateInvoices,
}

extension AdminPermissionExtension on AdminPermission {
  String get name {
    switch (this) {
      case AdminPermission.manageUsers:
        return 'Manage Users';
      case AdminPermission.viewUsers:
        return 'View Users';
      case AdminPermission.banUsers:
        return 'Ban Users';
      case AdminPermission.verifyUsers:
        return 'Verify Users';
      case AdminPermission.manageContent:
        return 'Manage Content';
      case AdminPermission.moderateContent:
        return 'Moderate Content';
      case AdminPermission.manageCampaigns:
        return 'Manage Campaigns';
      case AdminPermission.viewAnalytics:
        return 'View Analytics';
      case AdminPermission.exportData:
        return 'Export Data';
      case AdminPermission.generateReports:
        return 'Generate Reports';
      case AdminPermission.configureSystem:
        return 'Configure System';
      case AdminPermission.manageIntegrations:
        return 'Manage Integrations';
      case AdminPermission.manageSecurity:
        return 'Manage Security';
      case AdminPermission.manageSupport:
        return 'Manage Support';
      case AdminPermission.viewTickets:
        return 'View Tickets';
      case AdminPermission.respondToTickets:
        return 'Respond to Tickets';
      case AdminPermission.viewFinancials:
        return 'View Financials';
      case AdminPermission.managePayments:
        return 'Manage Payments';
      case AdminPermission.generateInvoices:
        return 'Generate Invoices';
    }
  }

  String get value {
    switch (this) {
      case AdminPermission.manageUsers:
        return 'manage_users';
      case AdminPermission.viewUsers:
        return 'view_users';
      case AdminPermission.banUsers:
        return 'ban_users';
      case AdminPermission.verifyUsers:
        return 'verify_users';
      case AdminPermission.manageContent:
        return 'manage_content';
      case AdminPermission.moderateContent:
        return 'moderate_content';
      case AdminPermission.manageCampaigns:
        return 'manage_campaigns';
      case AdminPermission.viewAnalytics:
        return 'view_analytics';
      case AdminPermission.exportData:
        return 'export_data';
      case AdminPermission.generateReports:
        return 'generate_reports';
      case AdminPermission.configureSystem:
        return 'configure_system';
      case AdminPermission.manageIntegrations:
        return 'manage_integrations';
      case AdminPermission.manageSecurity:
        return 'manage_security';
      case AdminPermission.manageSupport:
        return 'manage_support';
      case AdminPermission.viewTickets:
        return 'view_tickets';
      case AdminPermission.respondToTickets:
        return 'respond_to_tickets';
      case AdminPermission.viewFinancials:
        return 'view_financials';
      case AdminPermission.managePayments:
        return 'manage_payments';
      case AdminPermission.generateInvoices:
        return 'generate_invoices';
    }
  }

  static AdminPermission fromString(String value) {
    switch (value.toLowerCase()) {
      case 'manage_users':
        return AdminPermission.manageUsers;
      case 'view_users':
        return AdminPermission.viewUsers;
      case 'ban_users':
        return AdminPermission.banUsers;
      case 'verify_users':
        return AdminPermission.verifyUsers;
      case 'manage_content':
        return AdminPermission.manageContent;
      case 'moderate_content':
        return AdminPermission.moderateContent;
      case 'manage_campaigns':
        return AdminPermission.manageCampaigns;
      case 'view_analytics':
        return AdminPermission.viewAnalytics;
      case 'export_data':
        return AdminPermission.exportData;
      case 'generate_reports':
        return AdminPermission.generateReports;
      case 'configure_system':
        return AdminPermission.configureSystem;
      case 'manage_integrations':
        return AdminPermission.manageIntegrations;
      case 'manage_security':
        return AdminPermission.manageSecurity;
      case 'manage_support':
        return AdminPermission.manageSupport;
      case 'view_tickets':
        return AdminPermission.viewTickets;
      case 'respond_to_tickets':
        return AdminPermission.respondToTickets;
      case 'view_financials':
        return AdminPermission.viewFinancials;
      case 'manage_payments':
        return AdminPermission.managePayments;
      case 'generate_invoices':
        return AdminPermission.generateInvoices;
      default:
        return AdminPermission.viewUsers;
    }
  }
}

class AdminProfile extends Equatable {
  final String? department;
  final String? position;
  final DateTime? hireDate;
  final String? managerId;
  final List<String> managedTeams;
  final String? timezone;

  const AdminProfile({
    this.department,
    this.position,
    this.hireDate,
    this.managerId,
    required this.managedTeams,
    this.timezone,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      department: json['department'] as String?,
      position: json['position'] as String?,
      hireDate: json['hireDate'] != null
          ? DateTime.parse(json['hireDate'] as String)
          : null,
      managerId: json['managerId'] as String?,
      managedTeams: List<String>.from(json['managedTeams'] as List),
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department': department,
      'position': position,
      'hireDate': hireDate?.toIso8601String(),
      'managerId': managerId,
      'managedTeams': managedTeams,
      'timezone': timezone,
    };
  }

  @override
  List<Object?> get props => [
        department,
        position,
        hireDate,
        managerId,
        managedTeams,
        timezone,
      ];
}

class AdminPreferences extends Equatable {
  final String theme;
  final String language;
  final bool emailNotifications;
  final bool pushNotifications;
  final String dashboardLayout;
  final List<String> favoriteReports;
  final Map<String, dynamic>? customSettings;

  const AdminPreferences({
    this.theme = 'system',
    this.language = 'en',
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.dashboardLayout = 'default',
    required this.favoriteReports,
    this.customSettings,
  });

  factory AdminPreferences.fromJson(Map<String, dynamic> json) {
    return AdminPreferences(
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      dashboardLayout: json['dashboardLayout'] as String? ?? 'default',
      favoriteReports: List<String>.from(json['favoriteReports'] as List),
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'dashboardLayout': dashboardLayout,
      'favoriteReports': favoriteReports,
      'customSettings': customSettings,
    };
  }

  @override
  List<Object?> get props => [
        theme,
        language,
        emailNotifications,
        pushNotifications,
        dashboardLayout,
        favoriteReports,
        customSettings,
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
