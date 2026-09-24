import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth_gate.dart';
import '../../core/theme.dart';
import '../../models/listing_model.dart';
import '../placeholders/inquiries_screen.dart';

/// Detailed view for a specific business service / package added by a vendor.
class ListingDetailsScreen extends StatefulWidget {
  final Listing listing;
  final VoidCallback onFavoriteToggled;

  const ListingDetailsScreen({
    super.key,
    required this.listing,
    required this.onFavoriteToggled,
  });

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.listing.isFavorite;

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
      reason: 'Sign in to save ${widget.listing.title} to your favourites',
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
    final listing = widget.listing;
    final vendor = listing.vendor;
    final screenH = MediaQuery.of(context).size.height;
    final imageH = screenH * 0.38;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable Body ─────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero / Gallery Image ─────────────────────────────
                Stack(
                  children: [
                    SizedBox(
                      height: imageH,
                      width: double.infinity,
                      child: Image.network(
                        listing.coverImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 48, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Category Badge on Hero
                    Positioned(
                      bottom: 16,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: OleenaTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          listing.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Service Details Content ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        listing.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: OleenaTheme.textDark,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Price Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: OleenaTheme.primaryTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              listing.formattedPrice,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: OleenaTheme.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Rating
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                vendor.rating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: OleenaTheme.textDark,
                                ),
                              ),
                              Text(
                                ' (${vendor.reviewCount} reviews)',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: OleenaTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Vendor Profile Card ────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Vendor Logo / Avatar
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: OleenaTheme.primaryTint,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: vendor.logoUrl != null && vendor.logoUrl!.isNotEmpty
                                      ? Image.network(
                                          vendor.logoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.storefront_rounded,
                                            color: OleenaTheme.primary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.storefront_rounded,
                                          color: OleenaTheme.primary,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              vendor.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: OleenaTheme.textDark,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (vendor.isApproved) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.verified_rounded,
                                              size: 16,
                                              color: OleenaTheme.primary,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        vendor.location,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: OleenaTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (vendor.ownerName != null && vendor.ownerName!.isNotEmpty) ...[
                              const Divider(height: 20),
                              Row(
                                children: [
                                  Icon(Icons.person_outline_rounded,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Managed by: ${vendor.ownerName}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (vendor.contactNumber != null && vendor.contactNumber!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.phone_outlined,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    vendor.contactNumber!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Service Description ────────────────────────
                      Text(
                        'About This Service',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: OleenaTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        listing.description.isNotEmpty
                            ? listing.description
                            : (listing.shortDescription.isNotEmpty
                                ? listing.shortDescription
                                : 'Experience exceptional service tailored for your special day.'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Service Highlights ─────────────────────────
                      Text(
                        'Service Highlights',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: OleenaTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHighlight(Icons.verified_outlined, 'Direct from Verified Vendor'),
                      _buildHighlight(Icons.chat_bubble_outline, 'Direct Inquiry & Fast Response'),
                      _buildHighlight(Icons.event_available_outlined, 'Customizable Packages Available'),
                      _buildHighlight(Icons.thumb_up_alt_outlined, 'Dedicated Support & Assistance'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Top Navigation (Back & Share) ──────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoundButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                ScaleTransition(
                  scale: _heartScale,
                  child: _RoundButton(
                    icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    iconColor: _isFavorite ? Colors.red : OleenaTheme.textDark,
                    onTap: _toggleHeart,
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Floating Bar (Inquire / Contact) ────────────────
          Positioned(
            bottom: bottomPad + 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Price Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'STARTING AT',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: OleenaTheme.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          listing.formattedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: OleenaTheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Send Inquiry CTA Button
                  ElevatedButton.icon(
                    onPressed: () => requireLogin(
                      context,
                      reason: 'Sign in to send an inquiry for "${listing.title}"',
                      icon: Icons.chat_bubble_outline_rounded,
                      onSuccess: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InquiriesScreen(fromDetails: true),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send Inquiry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OleenaTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlight(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: OleenaTheme.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: OleenaTheme.primary),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    this.iconColor = OleenaTheme.textDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}
