enum IntroEnums {
  bodyMeasurement('body_measurement'),
  designStudio('design_studio'),
  virtuallyFitting('virtually_fitting'),
  designMarketing('design_marketing'),
  hardWorkingTailor('hard_working_tailor'),
  warehouseDelivery('warehouse_delivery'),
  ;

  final String value;

  const IntroEnums(this.value);

  String get toJson => 'assets/intro/$value.json';
}
