import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      eyebrow: 'CURATED VENDORS',
      icon: Icons.storefront_rounded,
      title: 'Find Wedding Vendors',
      description:
          'Discover photographers, musicians, caterers and hotels.',
    ),
    _OnboardingSlideData(
      eyebrow: 'EFFORTLESS COORDINATION',
      icon: Icons.assignment_turned_in_rounded,
      title: 'Plan Your Wedding',
      description:
          'Organize your budget, tasks, timeline and vendors.',
    ),
    _OnboardingSlideData(
      eyebrow: 'INTELLIGENT PLANNING',
      icon: Icons.auto_awesome_rounded,
      title: 'Get AI Recommendations',
      description:
          'Let AI help create a wedding plan based on your requirements.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    context.go('/home');
  }

  void _onNextPressed() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastSlide = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: OleenaTheme.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Monogram + Skip button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Monogram
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: OleenaTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OLEENA',
                        style: OleenaTheme.eyebrow.copyWith(
                          color: OleenaTheme.textDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  // Skip Button
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: OleenaTheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: OleenaTheme.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: OleenaTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView with 3 soft-shadow card slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 36,
                      ),
                      decoration: BoxDecoration(
                        color: OleenaTheme.background,
                        borderRadius: OleenaTheme.cardBorderRadius,
                        boxShadow: OleenaTheme.cardShadow,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Soft badge icon container
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: OleenaTheme.primaryTint,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: OleenaTheme.primary
                                      .withValues(alpha: 0.14),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                slide.icon,
                                size: 52,
                                color: OleenaTheme.primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Eyebrow
                          Text(
                            slide.eyebrow,
                            style: OleenaTheme.eyebrow,
                          ),

                          const SizedBox(height: 10),

                          // Serif Headline
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: OleenaTheme.display.copyWith(
                              fontSize: 24,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Sans-serif Description
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: OleenaTheme.body.copyWith(
                              color: OleenaTheme.textMuted,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Section: Dots and CTA with trailing arrow
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
              child: Column(
                children: [
                  // Dot Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? OleenaTheme.primary
                              : OleenaTheme.borderSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Action Button with trailing arrow icon
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLastSlide ? _completeOnboarding : _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OleenaTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: OleenaTheme.primary.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: OleenaTheme.buttonBorderRadius,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastSlide ? 'Get Started' : 'Next',
                            style: OleenaTheme.body.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlideData {
  final String eyebrow;
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingSlideData({
    required this.eyebrow,
    required this.icon,
    required this.title,
    required this.description,
  });
}
