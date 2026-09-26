// TODO(architecture): Explore screen uses local State instead of Provider/ChangeNotifier,
// inconsistent with team stack decision. Revisit before final submission if time allows.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_service.dart';
import '../../core/auth_provider.dart';
import '../../core/favorites_provider.dart';
import '../../core/theme.dart';
import '../../features/venue/widgets/explore_filter_sheet.dart';
import '../../models/listing_model.dart';
import '../../widgets/listing_card.dart';

/// Primary discovery screen showing specific business services (listings) added by vendors.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Listing> _allListings = [];
  List<Listing> _filteredListings = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';
  ExploreFilterCriteria _filterCriteria = const ExploreFilterCriteria();

  static const List<String> _categories = [
    'All',
    'Hotel / Venue',
    'Photography',
    'Decorations',
    'Catering',
    'Music',
  ];

  @override
  void initState() {
    super.initState();
    _fetchListings();
    _searchController.addListener(_applyFilters);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<AuthProvider>().isAuthenticated) {
        context.read<FavoritesProvider>().fetchFavorites();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Sends a GET request to /api/listings
  Future<void> _fetchListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final listings = await _apiService.fetchListings();
      if (!mounted) return;

      setState(() {
        _allListings = listings;
        _isLoading = false;
        _errorMessage = null;
      });
      _applyFilters();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _allListings = [];
        _filteredListings = [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while loading listings: $e';
        _allListings = [];
        _filteredListings = [];
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _allListings.where((item) {
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.shortDescription.toLowerCase().contains(query) ||
          item.vendor.name.toLowerCase().contains(query) ||
          item.vendor.location.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'All' ||
          item.category.toLowerCase().contains(_selectedCategory.toLowerCase());

      final matchesRating = _filterCriteria.minRating <= 0.0 ||
          item.rating >= _filterCriteria.minRating;

      final matchesPrice = switch (_filterCriteria.priceRange) {
        ExplorePriceRange.all => true,
        ExplorePriceRange.under100k =>
          item.priceFrom > 0 && item.priceFrom <= 100000,
        ExplorePriceRange.from100kTo250k =>
          item.priceFrom >= 100000 && item.priceFrom <= 250000,
        ExplorePriceRange.above250k => item.priceFrom >= 250000,
      };

      return matchesQuery && matchesCategory && matchesRating && matchesPrice;
    }).toList();

    // Apply Sorting
    switch (_filterCriteria.sortOption) {
      case ExploreSortOption.recommended:
        // Preserves default order as returned by the API
        break;
      case ExploreSortOption.priceLowToHigh:
        filtered.sort((a, b) {
          if (a.priceFrom <= 0 && b.priceFrom > 0) return 1;
          if (b.priceFrom <= 0 && a.priceFrom > 0) return -1;
          return a.priceFrom.compareTo(b.priceFrom);
        });
        break;
      case ExploreSortOption.priceHighToLow:
        filtered.sort((a, b) {
          if (a.priceFrom <= 0 && b.priceFrom > 0) return 1;
          if (b.priceFrom <= 0 && a.priceFrom > 0) return -1;
          return b.priceFrom.compareTo(a.priceFrom);
        });
        break;
      case ExploreSortOption.ratingHighToLow:
        filtered.sort((a, b) {
          final cmp = b.rating.compareTo(a.rating);
          if (cmp != 0) return cmp;
          return b.reviewCount.compareTo(a.reviewCount);
        });
        break;
    }

    setState(() {
      _filteredListings = filtered;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  Future<void> _openSortFilterSheet() async {
    final result = await showModalBottomSheet<ExploreFilterCriteria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExploreSortFilterSheet(
        currentCriteria: _filterCriteria,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _filterCriteria = result;
      });
      _applyFilters();
    }
  }

  void _resetSort() {
    setState(() {
      _filterCriteria = _filterCriteria.copyWith(sortOption: ExploreSortOption.recommended);
    });
    _applyFilters();
  }

  void _resetRatingFilter() {
    setState(() {
      _filterCriteria = _filterCriteria.copyWith(minRating: 0.0);
    });
    _applyFilters();
  }

  void _resetPriceFilter() {
    setState(() {
      _filterCriteria = _filterCriteria.copyWith(priceRange: ExplorePriceRange.all);
    });
    _applyFilters();
  }

  void _resetAllFilters() {
    setState(() {
      _filterCriteria = const ExploreFilterCriteria();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Explore Listings',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: OleenaTheme.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: OleenaTheme.primary),
            tooltip: 'Refresh listings',
            onPressed: _fetchListings,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search & Category Filter Header ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  // Search Bar with Sort & Filter trigger
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search packages, venues, photography...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                            prefixIcon: const Icon(Icons.search, size: 20, color: OleenaTheme.primary),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF5F3F1),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildSortFilterTrigger(),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => _onCategorySelected(cat),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : OleenaTheme.textDark,
                          ),
                          selectedColor: OleenaTheme.primary,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? OleenaTheme.primary : Colors.grey.shade300,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Results count & active sort indicator
                  Row(
                    children: [
                      Text(
                        _isLoading
                            ? 'Finding listings...'
                            : '${_filteredListings.length} ${_filteredListings.length == 1 ? 'package' : 'packages'} found',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _openSortFilterSheet,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _filterCriteria.sortOption.icon,
                                size: 14,
                                color: _filterCriteria.sortOption != ExploreSortOption.recommended
                                    ? OleenaTheme.primary
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _filterCriteria.sortOption.label,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: _filterCriteria.sortOption != ExploreSortOption.recommended
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: _filterCriteria.sortOption != ExploreSortOption.recommended
                                      ? OleenaTheme.primary
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Active filter removable pill row (if filters are applied)
                  if (_filterCriteria.isFiltered) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 28,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          if (_filterCriteria.sortOption != ExploreSortOption.recommended)
                            _buildActiveFilterPill(
                              label: _filterCriteria.sortOption.label,
                              onRemove: _resetSort,
                            ),
                          if (_filterCriteria.minRating > 0.0)
                            _buildActiveFilterPill(
                              label: '${_filterCriteria.minRating}+ ★',
                              onRemove: _resetRatingFilter,
                            ),
                          if (_filterCriteria.priceRange != ExplorePriceRange.all)
                            _buildActiveFilterPill(
                              label: _filterCriteria.priceRange.label,
                              onRemove: _resetPriceFilter,
                            ),
                          TextButton(
                            onPressed: _resetAllFilters,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: OleenaTheme.primary,
                            ),
                            child: Text(
                              'Clear all',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Main Content Area ──
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // 1. Loading State
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(OleenaTheme.primary),
              strokeWidth: 3,
            ),
            const SizedBox(height: 18),
            Text(
              'Loading live vendor packages...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Error State
    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 40,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Unable to Load Listings',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: OleenaTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchListings,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OleenaTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State
    if (_filteredListings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No listings found',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: OleenaTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try adjusting your search terms, categories, or filters.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              if (_filterCriteria.isFiltered || _selectedCategory != 'All' || _searchController.text.isNotEmpty) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    _selectedCategory = 'All';
                    _resetAllFilters();
                  },
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Reset All Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OleenaTheme.primary,
                    side: const BorderSide(color: OleenaTheme.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 4. Listings List
    return RefreshIndicator(
      onRefresh: _fetchListings,
      color: OleenaTheme.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        itemCount: _filteredListings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final listing = _filteredListings[index];
          return ListingCard(listing: listing);
        },
      ),
    );
  }

  Widget _buildSortFilterTrigger() {
    final hasActive = _filterCriteria.isFiltered;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openSortFilterSheet,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: hasActive ? OleenaTheme.primaryTint : const Color(0xFFF5F3F1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasActive ? OleenaTheme.primary : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 20,
                color: hasActive ? OleenaTheme.primary : OleenaTheme.textDark,
              ),
              if (hasActive)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: OleenaTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterPill({required String label, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.only(left: 10, right: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: OleenaTheme.primaryTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OleenaTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: OleenaTheme.primary,
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(Icons.close_rounded, size: 14, color: OleenaTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
