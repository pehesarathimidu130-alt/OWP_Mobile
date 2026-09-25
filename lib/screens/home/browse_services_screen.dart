import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_service.dart';
import '../../data/dummy_vendors.dart';
import '../../models/vendor.dart';
import '../details/vendor_details_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kAccent = Color(0xFFE94B73);
const _kDark = Color(0xFF1F1F2E);
const _kGrey = Color(0xFF8A8A9A);
const _kLightGrey = Color(0xFFF5F5F8);
// ─────────────────────────────────────────────────────────────────────────────

/// Minimalist home / discovery screen connecting live backend vendors & categories.
class BrowseServicesScreen extends StatefulWidget {
  const BrowseServicesScreen({super.key});

  @override
  State<BrowseServicesScreen> createState() => _BrowseServicesScreenState();
}

class _BrowseServicesScreenState extends State<BrowseServicesScreen> {
  final ApiService _apiService = ApiService();

  List<Vendor> _vendors = [];
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors({String? category}) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });

    try {
      final liveVendors = await _apiService.fetchVendors(category: category);
      if (!mounted) return;
      setState(() {
        _vendors = liveVendors.isNotEmpty ? liveVendors : List.from(dummyVendors);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _vendors = List.from(dummyVendors);
        _isLoading = false;
      });
    }
  }

  void _toggleFav(String id) {
    setState(() {
      final i = _vendors.indexWhere((v) => v.id == id);
      if (i != -1) {
        _vendors[i] = _vendors[i].copyWith(isFavorite: !_vendors[i].isFavorite);
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
            SliverToBoxAdapter(
              child: _CategoryGrid(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) => _loadVendors(category: cat),
              ),
            ),

            // ── Category / Vendors Section Header ──────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory != null ? '$_selectedCategory Vendors' : 'Featured Vendors',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _kDark,
                      ),
                    ),
                    if (_selectedCategory != null)
                      GestureDetector(
                        onTap: () => _loadVendors(),
                        child: Text(
                          'Show All',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kAccent,
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _loadVendors(),
                        child: Text(
                          'Refresh',
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

            // ── Vendor Cards List ─────────────────────────────────────
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent),
                  ),
                ),
              )
            else
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
          _DotsIcon(),
          const Spacer(),
          _LocationPill(),
          const Spacer(),
          _NotificationBell(),
        ],
      ),
    );
  }
}

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
            'Sri Lanka',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kDark,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(Icons.keyboard_arrow_down_rounded, color: _kGrey, size: 18),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded, color: _kDark, size: 26),
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
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const _CategoryGrid({
    this.selectedCategory,
    required this.onCategorySelected,
  });

  static const _categories = [
    _CatItem(Icons.person_outline_rounded, 'Vendor', null),
    _CatItem(Icons.location_city_outlined, 'Venue', 'Hotels'),
    _CatItem(Icons.checkroom_outlined, 'Dress', 'Bridal Wear'),
    _CatItem(Icons.cake_outlined, 'Cake', 'Catering'),
    _CatItem(Icons.face_retouching_natural, 'Make up', 'Beauty'),
    _CatItem(Icons.music_note_outlined, 'Music', 'Music'),
    _CatItem(Icons.camera_alt_outlined, 'Photo', 'Photography'),
    _CatItem(Icons.restaurant_outlined, 'Food', 'Catering'),
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
        itemBuilder: (_, i) {
          final item = _categories[i];
          final isSelected = selectedCategory == item.filterKey ||
              (item.filterKey == null && selectedCategory == null);

          return _CategoryCell(
            item: item,
            isSelected: isSelected,
            onTap: () => onCategorySelected(isSelected ? null : item.filterKey),
          );
        },
      ),
    );
  }
}

class _CatItem {
  final IconData icon;
  final String label;
  final String? filterKey;
  const _CatItem(this.icon, this.label, this.filterKey);
}

class _CategoryCell extends StatelessWidget {
  final _CatItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCell({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? _kAccent : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _kAccent : const Color(0xFFEDEDF2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _kAccent.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(item.icon, color: isSelected ? Colors.white : _kAccent, size: 24),
          ),
          const SizedBox(height: 7),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _kAccent : _kGrey,
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.network(
                  vendor.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _kLightGrey,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: Color(0xFFCCCCCC), size: 30),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vendor.isFeatured)
                        const Icon(Icons.verified_rounded, size: 16, color: _kAccent),
                    ],
                  ),
                  const SizedBox(height: 3),

                  Text(
                    '${vendor.category} · ${vendor.location}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _kGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  Text(
                    vendor.description.isNotEmpty ? vendor.description : 'Quality wedding vendor service.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF9B9BAA),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View Details',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kAccent,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(
                            vendor.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _kDark,
                            ),
                          ),
                        ],
                      ),
                    ],
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
