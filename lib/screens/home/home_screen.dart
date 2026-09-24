import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

/// Clean, modern landing screen introducing the Oleena wedding ecosystem.
///
/// Features:
/// • Warm burgundy & soft pink color palette matching the splash screen.
/// • Welcoming hero section with headline and subtitle.
/// • Aesthetic feature highlights and how-it-works cards.
/// • Prominent Call-To-Action (CTA) button transitioning to [ExploreScreen].
/// • Zero vendor/service listings (all catalog browsing is in Explore).
class HomeScreen extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const HomeScreen({super.key, this.onExploreTap});

  void _navigateToExplore(BuildContext context) {
    if (onExploreTap != null) {
      onExploreTap!();
    } else {
      context.go('/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: OleenaTheme.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'O',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: OleenaTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'OLEENA',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: OleenaTheme.textDark,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Hero Section ─────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8E406F), // Oleena Mauve/Burgundy
                      Color(0xFF6B2851), // Deep Burgundy
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: OleenaTheme.primary.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'SRI LANKA\'S WEDDING PLATFORM',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Main Headline
                    Text(
                      'Welcome to Oleena,\nyour perfect wedding planner',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Discover verified venues, talented photographers, floral designers, and caterers crafted for your dream celebration.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Primary CTA Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToExplore(context),
                        icon: const Icon(Icons.search_rounded, size: 20),
                        label: Text(
                          'Explore Services & Packages',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: OleenaTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Popular Categories ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Specialties',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: OleenaTheme.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToExplore(context),
                      child: Text(
                        'View All',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: OleenaTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryCard(
                      context,
                      icon: Icons.location_city_rounded,
                      title: 'Hotels & Venues',
                      subtitle: 'Ballrooms & Estates',
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.camera_alt_rounded,
                      title: 'Photography',
                      subtitle: 'Candid & Cinema',
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.local_florist_rounded,
                      title: 'Floral & Decor',
                      subtitle: 'Arches & Stages',
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.music_note_rounded,
                      title: 'Live Music',
                      subtitle: 'Bands & Acoustic',
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.restaurant_rounded,
                      title: 'Catering',
                      subtitle: 'Sri Lankan & Global',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── 3. Why Couples Love Oleena (Feature Highlights) ────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: OleenaTheme.primaryTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: OleenaTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'The Oleena Advantage',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: OleenaTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildHighlightRow(
                      icon: Icons.verified_user_rounded,
                      title: 'Verified Wedding Vendors',
                      desc: 'Every business is verified with valid business registration and portfolio reviews.',
                    ),
                    const Divider(height: 24),
                    _buildHighlightRow(
                      icon: Icons.payments_rounded,
                      title: 'Transparent Pricing & Packages',
                      desc: 'Browse clear package details with no hidden surcharges or middleman markups.',
                    ),
                    const Divider(height: 24),
                    _buildHighlightRow(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Direct Vendor Inquiries',
                      desc: 'Connect directly with event coordinators, photographers, and caterers instantly.',
                    ),
                    const Divider(height: 24),
                    _buildHighlightRow(
                      icon: Icons.favorite_border_rounded,
                      title: 'Curated Wedding Wishlist',
                      desc: 'Save your favourite services and review them at any time from your account.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── 4. How It Works ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'How Oleena Works',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: OleenaTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStepCard(
                        step: '01',
                        title: 'Browse',
                        desc: 'Search verified packages',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStepCard(
                        step: '02',
                        title: 'Compare',
                        desc: 'Review genuine quotes',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStepCard(
                        step: '03',
                        title: 'Inquire',
                        desc: 'Direct communication',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── 5. Bottom Invitation Card ──────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: OleenaTheme.primaryTint,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: OleenaTheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.celebration_rounded,
                      size: 36,
                      color: OleenaTheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ready to plan your dream day?',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: OleenaTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore hundreds of real wedding listings across Sri Lanka.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: OleenaTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _navigateToExplore(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OleenaTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'Start Exploring Listings',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
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
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () => _navigateToExplore(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: OleenaTheme.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: OleenaTheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: OleenaTheme.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: OleenaTheme.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightRow({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: OleenaTheme.primaryTint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: OleenaTheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: OleenaTheme.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: OleenaTheme.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: OleenaTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: OleenaTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: OleenaTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
