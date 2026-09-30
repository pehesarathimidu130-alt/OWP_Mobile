import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vendor.dart';

// ─── Brand Tokens ────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFFB05C70);      // Deep Rose / Mauve
const _kTextDark = Color(0xFF1A1A2E);     // Near-black
const _kStar = Color(0xFFFFC107);         // Amber star
// ─────────────────────────────────────────────────────────────────────────────

/// Premium vendor card for the Oleena 2-column grid.
class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const VendorCard({
    super.key,
    required this.vendor,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover Image ─────────────────────────────────────────
            _CoverImage(vendor: vendor, onFavoriteTap: onFavoriteTap),

            // ── Info ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category label
                    Text(
                      '${vendor.categoryIcon}  ${vendor.category}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kPrimary,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Vendor name
                    Text(
                      vendor.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kTextDark,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // ── Bottom row: rating + price ──────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: _kStar, size: 13),
                        const SizedBox(width: 2),
                        Text(
                          vendor.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _kTextDark,
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            vendor.formattedPrice,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}

// ─── Private sub-widget: cover image with overlays ───────────────────────────

class _CoverImage extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onFavoriteTap;

  const _CoverImage({required this.vendor, required this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: AspectRatio(
            aspectRatio: 1.15,
            child: Image.network(
              vendor.imageUrl,
              fit: BoxFit.cover,
              // ── Loading shimmer ────────────────────────────────
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFF3E8EC),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kPrimary,
                      ),
                    ),
                  ),
                );
              },
              // ── Error fallback ─────────────────────────────────
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF3E8EC),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFFCCA8B0),
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Subtle bottom gradient (legibility)
        Positioned.fill(
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.22),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Favorite button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onFavoriteTap,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                vendor.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 15,
                color: vendor.isFavorite
                    ? const Color(0xFFE91E63)
                    : const Color(0xFFB05C70),
              ),
            ),
          ),
        ),

        // Rating badge (bottom-left)
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: _kStar, size: 11),
                const SizedBox(width: 3),
                Text(
                  vendor.rating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
