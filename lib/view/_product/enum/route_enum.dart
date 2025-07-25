enum RouteEnum {
  intro,
  setting,
  homePage,
  languageSelection,
  // AI Tailoring Features
  designCanvas,
  virtualFitting,
  aiSuggestions,
  orders,
  orderDetails,
  profile,
  garmentCustomization,
  measurements,
  fabricSelection,
  patternLibrary,
}

extension RouteEnumString on RouteEnum {
  String get rawValue {
    switch (this) {
      case RouteEnum.intro:
        return '/intro';
      case RouteEnum.setting:
        return '/setting';
      case RouteEnum.homePage:
        return '/home';
      case RouteEnum.languageSelection:
        return '/language-selection';
      // AI Tailoring Features
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
      case RouteEnum.fabricSelection:
        return '/fabric-selection';
      case RouteEnum.patternLibrary:
        return '/pattern-library';
    }
  }
}
