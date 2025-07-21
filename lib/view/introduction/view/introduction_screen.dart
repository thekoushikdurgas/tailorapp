import 'package:flutter/material.dart';
import 'package:tailorapp/core/init/cache/onboarding/intro_caching.dart';
import 'package:tailorapp/core/init/navigation/navigation_route.dart';
import 'package:tailorapp/view/introduction/view/pages/first_page.dart';
import 'package:tailorapp/view/introduction/view/pages/second_page.dart';
import 'package:tailorapp/view/introduction/view/pages/third_page.dart';
import 'package:tailorapp/view/introduction/view/pages/fourth_page.dart';
import 'package:tailorapp/view/introduction/view/pages/fifth_page.dart';
import 'package:tailorapp/view/introduction/view/pages/sixth_page.dart';
// import 'package:easy_localization/easy_localization.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Widget> _pages = [
    FirstPage.page.titleWidget!,
    SecondPage.page.titleWidget!,
    ThirdPage.page.titleWidget!,
    FourthPage.page.titleWidget!,
    FifthPage.page.titleWidget!,
    SixthPage.page.titleWidget!,
  ];

  final List<Widget> _descriptions = [
    FirstPage.page.bodyWidget!,
    SecondPage.page.bodyWidget!,
    ThirdPage.page.bodyWidget!,
    FourthPage.page.bodyWidget!,
    FifthPage.page.bodyWidget!,
    SixthPage.page.bodyWidget!,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onDone();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onSkip() {
    IntroCaching.watchIntro();
    NavigationRoute.clearAndGoHome(context);
  }

  void _onDone() {
    IntroCaching.watchIntro();
    NavigationRoute.clearAndGoHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content area
          Column(
            children: [
              // Top section with animation
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _pages[index];
                  },
                ),
              ),
              // Bottom section with description
              Expanded(
                flex: 2,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _descriptions.length,
                  itemBuilder: (context, index) {
                    return _descriptions[index];
                  },
                ),
              ),
            ],
          ),

          // Vertical dots indicator on the right side
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_pages.length, (index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    width: _currentPage == index ? 8 : 6,
                    height: _currentPage == index ? 32 : 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: _currentPage == index
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),

          // Navigation controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button (only show after first page)
                _currentPage > 0
                    ? GestureDetector(
                        onTap: _previousPage,
                        child: _buildNavButton(Icons.arrow_back),
                      )
                    : const SizedBox(width: 56),

                // Skip or Done button
                Row(
                  children: [
                    if (_currentPage < _pages.length - 1) ...[
                      GestureDetector(
                        onTap: _onSkip,
                        child: _buildSkipButton(),
                      ),
                      const SizedBox(width: 16),
                    ],
                    GestureDetector(
                      onTap: _currentPage == _pages.length - 1
                          ? _onDone
                          : _nextPage,
                      child: _currentPage == _pages.length - 1
                          ? _buildDoneButton()
                          : _buildNavButton(Icons.arrow_forward),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: const Text(
        'Skip',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8B80FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Get Started',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: const Color(0xFF6C63FF),
        size: 24,
      ),
    );
  }


}
