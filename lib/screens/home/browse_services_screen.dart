import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/vendor.dart';
import '../../data/dummy_vendors.dart';
import '../details/vendor_details_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kAccent = Color(0xFFE94B73);
const _kDark = Color(0xFF1F1F2E);
const _kGrey = Color(0xFF8A8A9A);
const _kLightGrey = Color(0xFFF5F5F8);
// ─────────────────────────────────────────────────────────────────────────────

/// Kreva-style minimalist home / discovery screen.
class BrowseServicesScreen extends StatefulWidget {
  const BrowseServicesScreen({super.key});

  @override
  State<BrowseServicesScreen> createState() => _BrowseServicesScreenState();
}

class _BrowseServicesScreenState extends State<BrowseServicesScreen> {
  late List<Vendor> _vendors;

  @override
  void initState() {
    super.initState();
    _vendors = List.from(dummyVendors);
  }

  void _toggleFav(String id) {
    setState(() {
      final i = _vendors.indexWhere((v) => v.id == id);
      if (i != -1) {
        _vendors[i] =
            _vendors[i].copyWith(isFavorite: !_vendors[i].isFavorite);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Custom AppBar ──────────────────────────────────────────
            SliverToBoxAdapter(child: _TopBar()),

            // ── Header ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _kDark,
                      height: 1.3,
                    ),
                    children: const [
                      TextSpan(text: 'Create Your Own Version\nOf Perfect '),
                      TextSpan(
                        text: 'Wedding',
                        style: TextStyle(color: _kAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Category Grid ─────────────────────────────────────────
            const SliverToBoxAdapter(child: _CategoryGrid()),

            // ── Recent Events header ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Events',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _kDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'View All',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _kAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Event Cards list ───────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final vendor = _vendors[index];
                    return _EventCard(
                      vendor: vendor,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VendorDetailsScreen(
                            vendor: vendor,
                            onFavoriteToggled: () => _toggleFav(vendor.id),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _vendors.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Top Bar ───────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          // Four-dot menu icon
          _DotsIcon(),
          const Spacer(),

          // Location dropdown
          _LocationPill(),
          const Spacer(),

          // Notification bell
          _NotificationBell(),
        ],
      ),
    );
  }
}

/// 2×2 grid of small dots (menu icon).
class _DotsIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 28,
        height: 28,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(
            4,
            (_) => Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: _kDark,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tappable location chip.
class _LocationPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded, color: _kAccent, size: 16),
          const SizedBox(width: 4),
          Text(
            'Kandy, LK',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kDark,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: _kGrey, size: 18),
        ],
      ),
    );
  }
}

/// Bell with a small pink dot indicator.
class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_none_rounded, color: _kDark, size: 26),
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _kAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Grid ─────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  static const _categories = [
    _CatItem(Icons.person_outline_rounded, 'Vendor'),
    _CatItem(Icons.location_city_outlined, 'Venue'),
    _CatItem(Icons.checkroom_outlined, 'Dress'),
    _CatItem(Icons.cake_outlined, 'Cake'),
    _CatItem(Icons.face_retouching_natural, 'Make up'),
    _CatItem(Icons.music_note_outlined, 'Music'),
    _CatItem(Icons.camera_alt_outlined, 'Photo'),
    _CatItem(Icons.restaurant_outlined, 'Food'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.95,
        ),
        itemCount: _categories.length,
        itemBuilder: (_, i) => _CategoryCell(item: _categories[i]),
      ),
    );
  }
}

class _CatItem {
  final IconData icon;
  final String label;
  const _CatItem(this.icon, this.label);
}

class _CategoryCell extends StatelessWidget {
  final _CatItem item;
  const _CategoryCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEDEDF2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(item.icon, color: _kAccent, size: 24),
          ),
          const SizedBox(height: 7),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _kGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Event List Card ──────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onTap;

  const _EventCard({required this.vendor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Build a presentable "event date" from the vendor data.
    final dateLine = '${_fakeDate(vendor.id)} · ${vendor.location.split(',').first}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.network(
                  vendor.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: _kLightGrey,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kAccent,
                              ),
                            ),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    color: _kLightGrey,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: const Color(0xFFCCCCCC), size: 30),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Text column ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor name
                  Text(
                    vendor.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Date / location line
                  Text(
                    dateLine,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: _kGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Description snippet
                  Text(
                    vendor.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF9B9BAA),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Read More
                  Text(
                    'Read More',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kAccent,
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

  /// Deterministic fake date for display, derived from the vendor id.
  static String _fakeDate(String id) {
    const dates = [
      '05 Mar, 2024',
      '24 Feb, 2024',
      '14 Apr, 2024',
      '20 Jan, 2024',
      '10 May, 2024',
      '30 Jun, 2024',
    ];
    final idx = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return dates[(idx - 1).clamp(0, dates.length - 1)];
  }
}
