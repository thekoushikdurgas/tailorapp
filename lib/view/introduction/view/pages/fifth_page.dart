import 'package:tailorapp/core/extension/context/context_extension.dart';
import 'package:tailorapp/view/introduction/view-model/intro_pages.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';

class FifthPage {
  const FifthPage._();
  static final PageViewModel page = PageViewModel(
    titleWidget: const PageContent(),
    bodyWidget: const PageDescription(),
    decoration: PageDecoration(
      fullScreen: true,
      imageFlex: 3,
      bodyFlex: 2,
      pageColor: Colors.transparent,
    ),
  );
}

class PageContent extends StatelessWidget {
  const PageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final introPage = IntroPages.fifthPage;

    return Container(
      height: context.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            introPage.primaryColor ?? const Color(0xFFFF9800),
            introPage.secondaryColor ?? const Color(0xFFFFB74D),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Icon and Animation Container
            Container(
              height: context.height * 0.4,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background crafts decoration
                  Transform.rotate(
                    angle: 0.261799, // 15 degrees in radians
                    child: Container(
                      width: context.width * 0.7,
                      height: context.width * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  // Main circle
                  Container(
                    width: context.width * 0.68,
                    height: context.width * 0.68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 3,
                      ),
                    ),
                  ),
                  // Lottie Animation
                  SizedBox(
                    width: context.width * 0.5,
                    height: context.width * 0.5,
                    child: Lottie.asset(
                      introPage.path,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Floating Tailor Icon
                  Positioned(
                    top: 10,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        introPage.icon,
                        color: introPage.primaryColor,
                        size: 28,
                      ),
                    ),
                  ),
                  // Craft decorative elements
                  Positioned(
                    bottom: 30,
                    left: 30,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 45,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 55,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            // Title Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    introPage.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class PageDescription extends StatelessWidget {
  const PageDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final introPage = IntroPages.fifthPage;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              introPage.body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
