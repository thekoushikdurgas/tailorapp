import 'package:flutter/material.dart';
import 'package:tailorapp/product/enum/intro_enums.dart';
import 'package:tailorapp/view/introduction/model/page_model.dart';
import 'package:tailorapp/view/introduction/view/pages/first_page.dart';
import 'package:tailorapp/view/introduction/view/pages/second_page.dart';
import 'package:tailorapp/view/introduction/view/pages/third_page.dart';
import 'package:tailorapp/view/introduction/view/pages/fourth_page.dart';
import 'package:tailorapp/view/introduction/view/pages/fifth_page.dart';
import 'package:tailorapp/view/introduction/view/pages/sixth_page.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroPages {
  const IntroPages._();

  // Page 1: Body Measurement
  static final IntroPage firstPage = IntroPage(
    path: IntroEnums.bodyMeasurement.toJson,
    title: 'Measure Body Parts',
    body:
        'Get precise measurements with our AI-powered body scanning technology for perfect fit every time.',
    primaryColor: const Color(0xFF6C63FF),
    secondaryColor: const Color(0xFF8B80FF),
    icon: Icons.straighten,
  );

  // Page 2: Design Studio with AI
  static final IntroPage secondPage = IntroPage(
    path: IntroEnums.designStudio.toJson,
    title: 'Design Studio with AI',
    body:
        'Create stunning designs with the help of artificial intelligence and professional design tools.',
    primaryColor: const Color(0xFF26C6DA),
    secondaryColor: const Color(0xFF4DD0E1),
    icon: Icons.auto_awesome,
  );

  // Page 3: Virtual Fitting
  static final IntroPage thirdPage = IntroPage(
    path: IntroEnums.virtuallyFitting.toJson,
    title: 'Virtual Fitting Check',
    body:
        'See how your design looks on you before it\'s made using our advanced virtual fitting technology.',
    primaryColor: const Color(0xFFFF6B6B),
    secondaryColor: const Color(0xFFFF8A80),
    icon: Icons.view_in_ar,
  );

  // Page 4: Sell Design
  static final IntroPage fourthPage = IntroPage(
    path: IntroEnums.designMarketing.toJson,
    title: 'Sell Your Design',
    body:
        'Turn your creativity into profit by selling your unique designs to customers worldwide.',
    primaryColor: const Color(0xFF4CAF50),
    secondaryColor: const Color(0xFF66BB6A),
    icon: Icons.storefront,
  );

  // Page 5: Assign Tailor
  static final IntroPage fifthPage = IntroPage(
    path: IntroEnums.hardWorkingTailor.toJson,
    title: 'Assign a Tailor',
    body:
        'Connect with skilled professional tailors who will bring your design to life with expertise.',
    primaryColor: const Color(0xFFFF9800),
    secondaryColor: const Color(0xFFFFB74D),
    icon: Icons.person_4,
  );

  // Page 6: Delivery Service
  static final IntroPage sixthPage = IntroPage(
    path: IntroEnums.warehouseDelivery.toJson,
    title: 'Doorstep Delivery',
    body:
        'No need to visit stores. We deliver your custom-made garments right to your doorstep.',
    primaryColor: const Color(0xFF9C27B0),
    secondaryColor: const Color(0xFFBA68C8),
    icon: Icons.local_shipping,
  );

  static List<PageViewModel> pageList = [
    FirstPage.page,
    SecondPage.page,
    ThirdPage.page,
    FourthPage.page,
    FifthPage.page,
    SixthPage.page,
  ];
}
