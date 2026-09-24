import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth_gate.dart';
import '../../models/vendor.dart';
import '../placeholders/inquiries_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kAccent = Color(0xFFE94B73);
const _kDark = Color(0xFF1F1F2E);
const _kGrey = Color(0xFF8A8A9A);
// ─────────────────────────────────────────────────────────────────────────────

/// Kreva-style vendor detail screen.
class VendorDetailsScreen extends StatefulWidget {
  final Vendor vendor;
  final VoidCallback onFavoriteToggled;

  const VendorDetailsScreen({
    super.key,
    required this.vendor,
    required this.onFavoriteToggled,
  });

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.vendor.isFavorite;

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _heartCtrl,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleHeart() {
    requireLogin(
      context,
      reason: 'Sign in to save ${widget.vendor.name} to your favourites',
      icon: Icons.favorite_border_rounded,
      onSuccess: () {
        setState(() => _isFavorite = !_isFavorite);
        _heartCtrl.forward(from: 0);
        widget.onFavoriteToggled();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final screenH = MediaQuery.of(context).size.height;
    final imageH = screenH * 0.38;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable body ───────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Image ─────────────────────────────────────
                _HeroImage(vendor: vendor, height: imageH),

                // ── Content ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vendor Name
                      Text(
                        vendor.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _kDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle row: date · location · guests
                      Text(
                        '${_fakeDate(vendor.id)}; ${vendor.location.split(',').first}; 150–300 Guests;',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _kGrey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Price
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: vendor.formattedPrice,
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _kAccent,
                              ),
                            ),
                            TextSpan(
                              text: '  (Total Cost)',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: _kGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Sub-header
                      Text(
                        'Wonderful Wedding Party',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kDark,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        vendor.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: _kGrey,
                          height: 1.75,
                        ),
                      ),

                      // Extra space for floating bar
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Floating back + share (top) ───────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FloatButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _FloatButton(
                  icon: Icons.ios_share_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ── Custom Floating Action Bar (bottom) ───────────────────
          Positioned(
            bottom: bottomPad + 20,
            left: 30,
            right: 30,
            child: _FloatingActionBar(
              isFavorite: _isFavorite,
              heartScale: _heartScale,
              onHeart: _toggleHeart,
              onCancel: () => Navigator.of(context).pop(),
              onShare: () => requireLogin(
                context,
                reason: 'Sign in to send inquiries to ${vendor.name}',
                icon: Icons.chat_bubble_outline_rounded,
                onSuccess: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const InquiriesScreen(fromDetails: true),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fakeDate(String id) {
    const dates = [
      '05 Mar, 2024', '24 Feb, 2024', '14 Apr, 2024',
      '20 Jan, 2024', '10 May, 2024', '30 Jun, 2024',
    ];
    final idx = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return dates[(idx - 1).clamp(0, dates.length - 1)];
  }
}

// ─── Hero Image ───────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final Vendor vendor;
  final double height;
  const _HeroImage({required this.vendor, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        vendor.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                color: const Color(0xFFF5F5F8),
                child: const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _kAccent),
                ),
              ),
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF5F5F8),
          child: const Icon(Icons.image_not_supported_outlined,
              color: Color(0xFFCCCCCC), size: 60),
        ),
      ),
    );
  }
}

// ─── Floating circular button ─────────────────────────────────────────────────

class _FloatButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _FloatButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: _kDark, size: 20),
      ),
    );
  }
}

// ─── Floating Action Bar (X | ❤ | ★) ─────────────────────────────────────────

class _FloatingActionBar extends StatelessWidget {
  final bool isFavorite;
  final Animation<double> heartScale;
  final VoidCallback onHeart;
  final VoidCallback onCancel;
  final VoidCallback onShare;

  const _FloatingActionBar({
    required this.isFavorite,
    required this.heartScale,
    required this.onHeart,
    required this.onCancel,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.10),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Cancel (X) ─────────────────────────────────────────
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: _kGrey, size: 20),
            ),
          ),

          // ── Heart (primary CTA) ────────────────────────────────
          ScaleTransition(
            scale: heartScale,
            child: GestureDetector(
              onTap: onHeart,
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: _kAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x44E94B73),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),

          // ── Star ───────────────────────────────────────────────
          GestureDetector(
            onTap: onShare,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_border_rounded,
                  color: _kGrey, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
