import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/auth_provider.dart';
import '../core/favorites_provider.dart';
import '../core/theme.dart';
import '../models/listing_model.dart';
import '../screens/details/listing_details_screen.dart';
import 'ensure_logged_in.dart';

/// A compact, 2-column grid listing card with integrated Auth-Gated favorite toggle.
class CompactListingCard extends StatefulWidget {
  final Listing listing;
  final ValueChanged<bool>? onFavoriteChanged;

  const CompactListingCard({
    super.key,
    required this.listing,
    this.onFavoriteChanged,
  });

  @override
  State<CompactListingCard> createState() => _CompactListingCardState();
}

class _CompactListingCardState extends State<CompactListingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleFavoriteTap() async {
    final authProvider = context.read<AuthProvider>();
    final favProvider = context.read<FavoritesProvider>();

    if (!authProvider.isAuthenticated) {
      final ok = await ensureLoggedIn(
        context,
        message: 'You need to register or log in to save favourites.',
      );
      if (!ok || !mounted) return;
    }

    if (_isToggling) return;
    _isToggling = true;

    _animController.forward(from: 0.0);

    try {
      final finalState = await favProvider.toggleFavorite(widget.listing);
      await favProvider.fetchFavorites();
      widget.listing.isFavorite = finalState;
      widget.onFavoriteChanged?.call(finalState);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  finalState ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    finalState
                        ? 'Added "${widget.listing.title}" to Favourites'
                        : 'Removed from Favourites',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
              ],
            ),
            backgroundColor: OleenaTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update favourite: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The heart is driven ONLY by FavoritesProvider (no || listing.isFavorite fallback)
    final favProvider = context.watch<FavoritesProvider>();
    final bool isFav = favProvider.isFavorite(widget.listing.serviceId);
    final resolvedImageUrl = Listing.resolveImageUrl(widget.listing.coverImageUrl);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ListingDetailsScreen(listing: widget.listing),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image with Category Chip & Favorite Button ────────
              Stack(
                children: [
                  SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: Image.network(
                      resolvedImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Category Badge (top-left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: OleenaTheme.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.listing.category.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Favorite Button (top-right)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        elevation: 1,
                        child: InkWell(
                          onTap: _handleFavoriteTap,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 16,
                              color: isFav ? Colors.red : OleenaTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Text Details ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title (2 lines max)
                    Text(
                      widget.listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: OleenaTheme.textDark,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Vendor Name + Verified
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.listing.vendor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: OleenaTheme.textMuted,
                            ),
                          ),
                        ),
                        if (widget.listing.vendor.isApproved) ...[
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: OleenaTheme.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Rating & Reviews
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          widget.listing.vendor.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: OleenaTheme.textDark,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            ' (${widget.listing.vendor.reviewCount})',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: OleenaTheme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price
                    Text(
                      widget.listing.formattedPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
  }
}
