enum RouteEnum {
  // Common screens (accessible by all roles)
  intro,
  setting,
  languageSelection,
  auth,
  login,
  register,
  forgotPassword,
  unifiedAuth,
  universalSupport,
  notificationsCenter,

  // Customer-specific routes (12 screens)
  customerHome,
  stylePreferenceSetup,
  designWishlist,
  virtualWardrobe,
  sizeProfileManagement,
  designCollaboration,
  fabricSelection,
  customerOrderTimeline,
  customerFeedbackReviews,
  paymentHistoryBilling,
  styleConsultationBooking,
  customerLoyaltyRewards,

  // Tailor-specific routes (8 screens)
  tailorDashboard,
  orderManagement,
  patternCreationManagement,
  inventoryMaterials,
  productionPlanning,
  customerCommunicationHub,
  qualityControlInspection,
  tailorPortfolioProfile,

  // Admin-specific routes (5 screens)
  superAdminDashboard,
  userManagementRoles,
  platformAnalyticsInsights,
  contentCampaignManagement,
  systemConfigurationSettings,

  // Legacy routes for backward compatibility
  homePage,
  designCanvas,
  virtualFitting,
  aiSuggestions,
  orders,
  orderDetails,
  profile,
  garmentCustomization,
  measurements,
  fabricLibrary,
  patternLibrary,
}

extension RouteEnumString on RouteEnum {
  String get rawValue {
    switch (this) {
      // Common screens
      case RouteEnum.intro:
        return '/intro';
      case RouteEnum.setting:
        return '/setting';
      case RouteEnum.languageSelection:
        return '/language-selection';
      case RouteEnum.auth:
        return '/auth';
      case RouteEnum.login:
        return '/auth/login';
      case RouteEnum.register:
        return '/auth/register';
      case RouteEnum.forgotPassword:
        return '/auth/forgot-password';
      case RouteEnum.unifiedAuth:
        return '/unified-auth';
      case RouteEnum.universalSupport:
        return '/support';
      case RouteEnum.notificationsCenter:
        return '/notifications';

      // Customer-specific routes (12 screens)
      case RouteEnum.customerHome:
        return '/customer/home';
      case RouteEnum.stylePreferenceSetup:
        return '/customer/style-preference-setup';
      case RouteEnum.designWishlist:
        return '/customer/design-wishlist';
      case RouteEnum.virtualWardrobe:
        return '/customer/virtual-wardrobe';
      case RouteEnum.sizeProfileManagement:
        return '/customer/size-profile-management';
      case RouteEnum.designCollaboration:
        return '/customer/design-collaboration';
      case RouteEnum.fabricSelection:
        return '/customer/fabric-selection';
      case RouteEnum.customerOrderTimeline:
        return '/customer/order-timeline';
      case RouteEnum.customerFeedbackReviews:
        return '/customer/feedback-reviews';
      case RouteEnum.paymentHistoryBilling:
        return '/customer/payment-history-billing';
      case RouteEnum.styleConsultationBooking:
        return '/customer/style-consultation-booking';
      case RouteEnum.customerLoyaltyRewards:
        return '/customer/loyalty-rewards';

      // Tailor-specific routes (8 screens)
      case RouteEnum.tailorDashboard:
        return '/tailor/dashboard';
      case RouteEnum.orderManagement:
        return '/tailor/order-management';
      case RouteEnum.patternCreationManagement:
        return '/tailor/pattern-creation-management';
      case RouteEnum.inventoryMaterials:
        return '/tailor/inventory-materials';
      case RouteEnum.productionPlanning:
        return '/tailor/production-planning';
      case RouteEnum.customerCommunicationHub:
        return '/tailor/customer-communication-hub';
      case RouteEnum.qualityControlInspection:
        return '/tailor/quality-control-inspection';
      case RouteEnum.tailorPortfolioProfile:
        return '/tailor/portfolio-profile';

      // Admin-specific routes (5 screens)
      case RouteEnum.superAdminDashboard:
        return '/admin/dashboard';
      case RouteEnum.userManagementRoles:
        return '/admin/user-management-roles';
      case RouteEnum.platformAnalyticsInsights:
        return '/admin/platform-analytics-insights';
      case RouteEnum.contentCampaignManagement:
        return '/admin/content-campaign-management';
      case RouteEnum.systemConfigurationSettings:
        return '/admin/system-configuration-settings';

      // Legacy routes for backward compatibility
      case RouteEnum.homePage:
        return '/home';
      case RouteEnum.designCanvas:
        return '/design-canvas';
      case RouteEnum.virtualFitting:
        return '/virtual-fitting';
      case RouteEnum.aiSuggestions:
        return '/ai-suggestions';
      case RouteEnum.orders:
        return '/orders';
      case RouteEnum.orderDetails:
        return '/order-details';
      case RouteEnum.profile:
        return '/profile';
      case RouteEnum.garmentCustomization:
        return '/garment-customization';
      case RouteEnum.measurements:
        return '/measurements';
      case RouteEnum.fabricLibrary:
        return '/fabric-library';
      case RouteEnum.patternLibrary:
        return '/pattern-library';
    }
  }
}
