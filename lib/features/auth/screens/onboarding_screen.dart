import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_config.dart';
import '../../../core/theme.dart';

/// Redesigned mobile onboarding screen based on Stitch AI designs.
///
/// Features:
/// - Animated Wedding Envelope Intro Loading Overlay
/// - Animated luxury satin mesh & floating shimmer particles background
/// - Onboarding Page 1: "DISCOVER" with interactive vendor card carousel
/// - Onboarding Page 2: "SHORTLIST" with layered cards, pulsing heart, and chat inquiry bubble
/// - Onboarding Page 3: "INTELLIGENT PLANNING" with AI plan card and curated services
class OnboardingScreen extends StatefulWidget {
  final bool showIntroAnimation;

  const OnboardingScreen({super.key, this.showIntroAnimation = true});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.kHasSeenOnboarding, true);
    if (!mounted) return;
    context.go('/home');
  }

  void _onNextPressed() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
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
    final isLastSlide = _currentPage == 2;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: Stack(
        children: [
          // ── 1. Animated Ambient Luxury Satin Background ──────────
          const Positioned.fill(child: _AnimatedSatinBackground()),

          // ── 2. Onboarding Main Content ───────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top Shared Navigation Bar
                _buildTopBar(),

                // Slide PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: const [
                      _OnboardingSlide1(),
                      _OnboardingSlide2(),
                      _OnboardingSlide3(),
                    ],
                  ),
                ),

                // Bottom Progress Indicator & Action Pill Button
                _buildBottomControls(isLastSlide),
              ],
            ),
          ),

          // (Envelope intro removed)
        ],
      ),
    );
  }

  /// Shared Top Bar with Brand Monogram and Skip Button
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Monogram & Brand Name
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
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          // Skip Action
          TextButton(
            onPressed: _completeOnboarding,
            style: TextButton.styleFrom(
              foregroundColor: OleenaTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: OleenaTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Dots Indicator and CTA Pill Button
  Widget _buildBottomControls(bool isLastSlide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        children: [
          // 3 Page Dots: Active is a long mauve pill (24x6), Inactive is 6x6 circle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 24 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? OleenaTheme.primary
                      : const Color(0xFFE5D7DE),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Full-width pill action button in rich Mauve
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: OleenaTheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: OleenaTheme.primary.withValues(alpha: 0.38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastSlide ? 'Get Started' : 'Next',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SLIDE 1: DISCOVER
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingSlide1 extends StatelessWidget {
  const _OnboardingSlide1();

  @override
  Widget build(BuildContext context) {
    final vendorCards = const [
      _Slide1CardData(
        title: 'Grand Orchid Ballroom',
        subtitle: 'Orchid Hotels',
        category: 'Venue',
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=600&auto=format&fit=crop',
      ),
      _Slide1CardData(
        title: 'Golden Hour Wedding Photography',
        subtitle: 'Lens & Lace Studio',
        category: 'Photography',
        imageUrl: 'https://images.unsplash.com/photo-1606800052052-a08af7148866?q=80&w=600&auto=format&fit=crop',
      ),
      _Slide1CardData(
        title: 'Rose Garden Floral Arches',
        subtitle: 'Oleena Florals',
        category: 'Florals',
        imageUrl: 'https://images.unsplash.com/photo-1525258946800-98ccd7da4076?q=80&w=600&auto=format&fit=crop',
      ),
      _Slide1CardData(
        title: 'Royal Lotus Wedding Feast',
        subtitle: 'Lotus Kitchen',
        category: 'Catering',
        imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=600&auto=format&fit=crop',
      ),
      _Slide1CardData(
        title: 'Acoustic Sunset Romance Set',
        subtitle: 'Symphony Strings & Soul',
        category: 'Music',
        imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=600&auto=format&fit=crop',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DISCOVER',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: OleenaTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Everything for your big day, in one place',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  height: 1.22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Venues, photographers, florists, caterers and bands, all waiting to meet you.',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: const Color(0xFF6B7280),
                  height: 1.48,
                ),
              ),
            ],
          ),
        ),

        // Carousel Section
        Expanded(
          child: Center(
            child: SizedBox(
              height: 310,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: vendorCards.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final card = vendorCards[index];
                  return Container(
                    width: 240,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFF3D9E5).withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: OleenaTheme.primary.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Soft photo gradient block with category pill
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFFDF0F4),
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    card.imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: const Color(0xFFFDF0F4),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  OleenaTheme.primary,
                                                ),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, _, _) => Container(
                                      color: const Color(0xFFFDF0F4),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: OleenaTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      card.category,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: OleenaTheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Title & Subtitle
                        Text(
                          card.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.storefront_outlined,
                              size: 13,
                              color: OleenaTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                card.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Slide1CardData {
  final String title;
  final String subtitle;
  final String category;
  final String imageUrl;

  const _Slide1CardData({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.imageUrl,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SLIDE 2: SHORTLIST
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingSlide2 extends StatelessWidget {
  const _OnboardingSlide2();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SHORTLIST',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: OleenaTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Save what you love, ask the vendor directly',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  height: 1.22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the heart on your favourites, then send an inquiry in a few taps.',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: const Color(0xFF6B7280),
                  height: 1.48,
                ),
              ),
            ],
          ),
        ),

        // Visual Section: Layered Floating Cards & Inquiry Bubble
        Expanded(
          child: Center(
            child: SizedBox(
              width: 310,
              height: 310,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Soft central aura glow
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFDF0F4).withValues(alpha: 0.85),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFDF0F4).withValues(alpha: 0.9),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  // Back Card (Lens & Lace Studio) rotated +7 degrees
                  Positioned(
                    top: 10,
                    right: 20,
                    child: Transform.rotate(
                      angle: 0.12,
                      child: Container(
                        width: 190,
                        height: 230,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFF3D9E5)
                                .withValues(alpha: 0.75),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFFFDF0F4),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?q=80&w=600&auto=format&fit=crop',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Photography',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: OleenaTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Lens & Lace Studio',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Colombo, LK',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Foreground Front Card (Grand Orchid Ballroom) rotated -3 degrees
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Transform.rotate(
                      angle: -0.05,
                      child: Container(
                        width: 210,
                        height: 250,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFF3D9E5)),
                          boxShadow: [
                            BoxShadow(
                              color: OleenaTheme.primary.withValues(
                                alpha: 0.18,
                              ),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 145,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: const Color(0xFFFDF0F4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=600&auto=format&fit=crop',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Venue',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: OleenaTheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                // Floating Mauve Heart Badge
                                Positioned(
                                  bottom: -14,
                                  right: 8,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: OleenaTheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: OleenaTheme.primary.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.favorite_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Grand Orchid Ballroom',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Orchid Hotels',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Inquiry Message Bubble at bottom right
                  Positioned(
                    bottom: -8,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                          bottomLeft: Radius.circular(4),
                        ),
                        border: Border.all(color: const Color(0xFFF3D9E5)),
                        boxShadow: [
                          BoxShadow(
                            color: OleenaTheme.primary.withValues(alpha: 0.16),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDF0F4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 14,
                              color: OleenaTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '“Is 14 December available?”',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                'Direct vendor inquiry',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                  color: OleenaTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SLIDE 3: INTELLIGENT PLANNING
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingSlide3 extends StatelessWidget {
  const _OnboardingSlide3();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INTELLIGENT PLANNING',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: OleenaTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Plan together with AI',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  height: 1.22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us your date, budget and style. We\'ll suggest a plan, step by step.',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: const Color(0xFF6B7280),
                  height: 1.48,
                ),
              ),
            ],
          ),
        ),

        // Visual Section: Mock Chat with AI Plan
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sparkle Icon Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0F4),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF3D9E5)),
                        boxShadow: [
                          BoxShadow(
                            color: OleenaTheme.primary.withValues(alpha: 0.14),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 22,
                          color: OleenaTheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // User Message Bubble (Right aligned, Mauve)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: OleenaTheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: OleenaTheme.primary.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Beach wedding, 150 guests, LKR 2.5M',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // AI Reply Card: "Your plan" with 4 structured rows
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFF3D9E5).withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: OleenaTheme.primary.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: OleenaTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Your plan',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF0F4),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFF3D9E5)
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                child: Text(
                                  'Curated by Oleena',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: OleenaTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          const Divider(height: 1, thickness: 0.5),

                          // 4 Rows
                          _buildPlanRow(
                            'Venue',
                            'Coastal Lawn, Galle',
                            Icons.apartment_rounded,
                          ),
                          const Divider(height: 1, thickness: 0.5),
                          _buildPlanRow(
                            'Photography',
                            'Golden Hour & Sunset',
                            Icons.camera_alt_outlined,
                          ),
                          const Divider(height: 1, thickness: 0.5),
                          _buildPlanRow(
                            'Catering',
                            'Bespoke Island Buffet',
                            Icons.restaurant_outlined,
                          ),
                          const Divider(height: 1, thickness: 0.5),
                          _buildPlanRow(
                            'Music',
                            'Sunset Acoustic Trio',
                            Icons.music_note_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFDF0F4), Color(0xFFF3D9E5)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: OleenaTheme.primary),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFFFDF0F4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 12,
              color: OleenaTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED SATIN & MESH BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedSatinBackground extends StatefulWidget {
  const _AnimatedSatinBackground();

  @override
  State<_AnimatedSatinBackground> createState() =>
      _AnimatedSatinBackgroundState();
}

class _AnimatedSatinBackgroundState extends State<_AnimatedSatinBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    final isTest = WidgetsBinding.instance is! WidgetsFlutterBinding;
    if (!isTest) {
      _controller.repeat();
      _loadShader();
    }
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/background.frag',
      );
      if (mounted) {
        setState(() {
          _program = program;
        });
      }
    } catch (e) {
      debugPrint('Failed to load background shader: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_program != null) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ShaderPainter(
              shader: _program!.fragmentShader(),
              time: _controller.value * 14.0, // map to time in seconds
            ),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final offset1 = math.sin(t * math.pi * 2) * 80.0;
        final offset2 = math.cos(t * math.pi * 2) * 100.0;

        return Stack(
          children: [
            // Solid base matching Stitch WebGL (Ivory cream)
            Container(color: const Color(0xFFFFF9F6)),

            // Ambient Orb 1 (Top Left) - Blush Rose
            Positioned(
              top: -200 + offset1,
              left: -150 + offset2 * 0.8,
              child: Container(
                width: 900,
                height: 900,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFDF0F4).withValues(alpha: 1.0),
                      const Color(0xFFFDF0F4).withValues(alpha: 0.6),
                      const Color(0xFFFFF9F6).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Ambient Orb 2 (Middle Right) - Champagne Mauve
            Positioned(
              top: 150 + offset2,
              right: -250 - offset1 * 0.9,
              child: Container(
                width: 1000,
                height: 1000,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF5DDE7).withValues(alpha: 1.0),
                      const Color(0xFFF5DDE7).withValues(alpha: 0.7),
                      const Color(0xFFFFF9F6).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Ambient Orb 3 (Bottom Left) - Deep Wine / Mauve Glow
            Positioned(
              bottom: -300 - offset1,
              left: -200 - offset2 * 0.7,
              child: Container(
                width: 850,
                height: 850,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFDFA9C4).withValues(alpha: 0.85),
                      const Color(0xFFDFA9C4).withValues(alpha: 0.4),
                      const Color(0xFFFFF9F6).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Shimmer Sparkles
            Positioned(
              top: 190 + offset1 * 0.5,
              left: 50 + offset2 * 0.3,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: OleenaTheme.primary.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 360 - offset2 * 0.4,
              right: 60 - offset1 * 0.3,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFD48EA8).withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 210 + offset1 * 0.3,
              left: 70 - offset2 * 0.4,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: OleenaTheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;

  _ShaderPainter({required this.shader, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED LOADING SCREEN: WEDDING ENVELOPE INTRO (EXACT STITCH AI MATCH)
// ─────────────────────────────────────────────────────────────────────────────

class _PetalData {
  final double angle;
  final double distance;
  final Color color;
  final double size;
  final double rotation;
  final double delay;

  _PetalData({
    required this.angle,
    required this.distance,
    required this.color,
    required this.size,
    required this.rotation,
    required this.delay,
  });
}

class _WeddingEnvelopeIntro extends StatefulWidget {
  final VoidCallback onDismissed;

  const _WeddingEnvelopeIntro({required this.onDismissed});

  @override
  State<_WeddingEnvelopeIntro> createState() => _WeddingEnvelopeIntroState();
}

class _WeddingEnvelopeIntroState extends State<_WeddingEnvelopeIntro>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _envController;

  late final Animation<double> _sealScale;
  late final Animation<double> _flapRotation;
  late final Animation<double> _letterTranslate;
  late final Animation<double> _petalProgress;
  late final Animation<double> _fadeAnimation;

  bool _isOpen = false;
  bool _isTransitioned = false;

  final List<_PetalData> _petals = [];

  @override
  void initState() {
    super.initState();
    // Pulse animation for the wax seal
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    final isTest = WidgetsBinding.instance is! WidgetsFlutterBinding;
    if (!isTest) {
      _pulseController.repeat(reverse: true);
    }

    // Envelope opening sequence controller
    _envController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 1. Break wax seal
    _sealScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 80),
    ]).animate(CurvedAnimation(parent: _envController, curve: Curves.linear));

    // 2. Open top flap (rotate X 180 deg)
    _flapRotation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(
        parent: _envController,
        curve: const Interval(0.05, 0.35, curve: Curves.easeInOutCubic),
      ),
    );

    // 3. Shoot petals
    _petalProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _envController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // 4. Slide letter up
    _letterTranslate = Tween<double>(begin: 0.0, end: -165.0).animate(
      CurvedAnimation(
        parent: _envController,
        curve: const Interval(0.32, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // 5. Fade out entire overlay
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _envController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    // Generate 22 confetti petals matching Stitch AI JS
    final random = math.Random(42); // fixed seed for consistency
    final colors = const [
      Color(0xFF8E406F),
      Color(0xFFDFA9C4),
      Color(0xFFF5DDE7),
      Color(0xFFD4AF37),
      Color(0xFFFFF0F5),
    ];
    for (int i = 0; i < 22; i++) {
      _petals.add(
        _PetalData(
          angle: random.nextDouble() * math.pi * 2,
          distance: random.nextDouble() * 160 + 80,
          color: colors[random.nextInt(colors.length)],
          size: random.nextDouble() * 12 + 8,
          rotation: random.nextDouble() * 4 * math.pi,
          delay: random.nextDouble() * 0.2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _envController.dispose();
    super.dispose();
  }

  void _openEnvelope() {
    if (_isOpen) return;
    setState(() => _isOpen = true);
    _pulseController.stop();
    _envController.forward().then((_) {
      if (!_isTransitioned) {
        _isTransitioned = true;
        widget.onDismissed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openEnvelope,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _envController]),
        builder: (context, child) {
          final opacity = _fadeAnimation.value.clamp(0.0, 1.0);
          final pulseScale = 1.0 + (_pulseController.value * 0.04);
          final isFlapOpened = _envController.value > 0.15;

          return Opacity(
            opacity: opacity,
            child: Container(
              color: const Color(0xFFFFF9F6).withValues(alpha: 0.98),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Hint
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Column(
                        children: [
                          Text(
                            'YOUR SPECIAL INVITATION',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.4,
                              color: OleenaTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You\'re Invited to Begin',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap the gold-sealed envelope to unseal\nyour personalized wedding journey.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Interactive Envelope 3D Wrapper
                    SizedBox(
                      width: 320,
                      height: 225,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Shadow under envelope
                          Positioned(
                            bottom: -24,
                            child: Container(
                              width: 280,
                              height: 24,
                              decoration: BoxDecoration(
                                color: OleenaTheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: OleenaTheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Main Envelope Assembly
                          Transform.scale(
                            scale: _isOpen ? 1.0 : pulseScale,
                            child: Container(
                              width: 320,
                              height: 225,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAEFF4),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 24,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Back pocket inside
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5DDE7),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE9C2D5),
                                      ),
                                    ),
                                  ),

                                  // Letter Card
                                  Positioned(
                                    left: 14,
                                    right: 14,
                                    top: 14,
                                    bottom: 14,
                                    child: Transform.translate(
                                      offset: Offset(0, _letterTranslate.value),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFF3D9E5),
                                          ),
                                          boxShadow: [
                                            if (_envController.value > 0.4)
                                              BoxShadow(
                                                color: OleenaTheme.primary
                                                    .withValues(alpha: 0.35),
                                                blurRadius: 50,
                                                offset: const Offset(0, 25),
                                              ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'OLEENA WEDDINGS',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 2.0,
                                                    color: OleenaTheme.primary,
                                                  ),
                                                ),
                                                const Text(
                                                  '✨',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  'A celebration of love',
                                                  style:
                                                      GoogleFonts.playfairDisplay(
                                                        fontSize: 12,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: const Color(
                                                          0xFFA8728F,
                                                        ),
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Let Us Plan Your\nSpecial Day',
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      GoogleFonts.playfairDisplay(
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF1F2937,
                                                        ),
                                                        height: 1.2,
                                                      ),
                                                ),
                                                Container(
                                                  width: 40,
                                                  height: 2,
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: OleenaTheme.primary
                                                        .withValues(alpha: 0.3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                ),
                                                Text(
                                                  'Venues, photographers, florists, and bespoke wedding artisans curated for you.',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: const Color(
                                                      0xFF6B7280,
                                                    ),
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Opacity(
                                              opacity:
                                                  _envController.value > 0.6
                                                  ? 1.0
                                                  : 0.0,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Enter Experience',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          OleenaTheme.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 14,
                                                    color: OleenaTheme.primary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Front Flaps (Left, Right, Bottom)
                                  ClipPath(
                                    clipper: _LeftFlapClipper(),
                                    child: Container(
                                      color: const Color(0xFFFDF3F7),
                                    ),
                                  ),
                                  ClipPath(
                                    clipper: _RightFlapClipper(),
                                    child: Container(
                                      color: const Color(0xFFFBF0F5),
                                    ),
                                  ),
                                  ClipPath(
                                    clipper: _BottomFlapClipper(),
                                    child: Container(
                                      color: const Color(0xFFFFF8FB),
                                    ),
                                  ),

                                  // Top Flap (Rotates in 3D)
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Transform(
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.002) // Perspective
                                        ..rotateX(_flapRotation.value),
                                      alignment: Alignment.topCenter,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ClipPath(
                                            clipper: _TopFlapClipper(),
                                            child: Container(
                                              height: 125,
                                              decoration: BoxDecoration(
                                                color: isFlapOpened
                                                    ? const Color(0xFFFDF3F7)
                                                    : const Color(0xFFFFF5F8),
                                                boxShadow: [
                                                  if (!isFlapOpened)
                                                    BoxShadow(
                                                      color: OleenaTheme.primary
                                                          .withValues(
                                                            alpha: 0.12,
                                                          ),
                                                      blurRadius: 6,
                                                      offset: const Offset(
                                                        0,
                                                        6,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Wax Seal
                                          if (!isFlapOpened)
                                            Positioned(
                                              bottom: -20,
                                              left:
                                                  160 -
                                                  24, // center minus half width
                                              child: Transform.scale(
                                                scale: _sealScale.value,
                                                child: Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient:
                                                        const LinearGradient(
                                                          begin: Alignment
                                                              .bottomLeft,
                                                          end: Alignment
                                                              .topRight,
                                                          colors: [
                                                            Color(0xFF962A5A),
                                                            Color(0xFF8E406F),
                                                            Color(0xFFB05B8D),
                                                          ],
                                                        ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFFF7E7CE,
                                                      ),
                                                      width: 2,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: OleenaTheme
                                                            .primary
                                                            .withValues(
                                                              alpha: 0.4,
                                                            ),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black12,
                                                        border: Border.all(
                                                          color:
                                                              const Color(
                                                                0xFFF7E7CE,
                                                              ).withValues(
                                                                alpha: 0.6,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'O',
                                                          style:
                                                              GoogleFonts.playfairDisplay(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    const Color(
                                                                      0xFFFFF2D8,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Petals / Confetti
                          if (_envController.isAnimating ||
                              _envController.isCompleted)
                            ..._petals.map((p) {
                              final progress = _petalProgress.value;
                              final effectiveProgress = math.max(
                                0.0,
                                (progress - p.delay) / (1.0 - p.delay),
                              );
                              if (effectiveProgress == 0)
                                return const SizedBox.shrink();

                              final x =
                                  math.cos(p.angle) *
                                  p.distance *
                                  effectiveProgress;
                              // Add gravity to Y
                              final y =
                                  math.sin(p.angle) *
                                      p.distance *
                                      effectiveProgress +
                                  (100 * math.pow(effectiveProgress, 2));

                              return Positioned(
                                top: 225 / 2 - 20 + y,
                                left: 320 / 2 - 10 + x,
                                child: Transform.rotate(
                                  angle: p.rotation * effectiveProgress,
                                  child: Opacity(
                                    opacity:
                                        1.0 -
                                        math
                                            .pow(effectiveProgress, 3)
                                            .toDouble(),
                                    child: Container(
                                      width: p.size,
                                      height: p.size * 1.3,
                                      decoration: BoxDecoration(
                                        color: p.color,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          topRight: Radius.circular(0),
                                          bottomLeft: Radius.circular(50),
                                          bottomRight: Radius.circular(50),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                    // Tap Hint
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isOpen
                                ? Icons.arrow_upward_rounded
                                : Icons.touch_app_rounded,
                            size: 16,
                            color: OleenaTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isOpen
                                ? 'Tap card to explore Discover'
                                : 'Tap envelope to open',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: OleenaTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LeftFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _RightFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BottomFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.533)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TopFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.5, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
