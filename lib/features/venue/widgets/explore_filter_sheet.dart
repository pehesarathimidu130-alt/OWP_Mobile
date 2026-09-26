import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

/// Available sort options for explore listings.
/// Note: 'Newest' sort is intentionally omitted as 'createdAt' is not returned
/// by the GET /api/listings endpoint or Listing model (flagged per API Contract Rule).
enum ExploreSortOption {
  recommended('Recommended', Icons.auto_awesome_rounded, 'Order as returned by the API'),
  priceLowToHigh('Price: Low to High', Icons.arrow_upward_rounded, 'Most affordable first'),
  priceHighToLow('Price: High to Low', Icons.arrow_downward_rounded, 'Premium packages first'),
  ratingHighToLow('Rating: High to Low', Icons.star_rounded, 'Highest customer satisfaction');

  final String label;
  final IconData icon;
  final String description;

  const ExploreSortOption(this.label, this.icon, this.description);
}

/// Budget price range tiers based on listing starting price (LKR).
enum ExplorePriceRange {
  all('All Prices', 0, double.infinity),
  under100k('Under LKR 100K', 0, 100000),
  from100kTo250k('LKR 100K – 250K', 100000, 250000),
  above250k('Above LKR 250K', 250000, double.infinity);

  final String label;
  final double minPrice;
  final double maxPrice;

  const ExplorePriceRange(this.label, this.minPrice, this.maxPrice);
}

/// Immutable state container for Explore sorting and filtering criteria.
class ExploreFilterCriteria {
  final ExploreSortOption sortOption;
  final double minRating; // 0.0 = any rating
  final ExplorePriceRange priceRange;

  const ExploreFilterCriteria({
    this.sortOption = ExploreSortOption.recommended,
    this.minRating = 0.0,
    this.priceRange = ExplorePriceRange.all,
  });

  bool get isFiltered =>
      sortOption != ExploreSortOption.recommended ||
      minRating > 0.0 ||
      priceRange != ExplorePriceRange.all;

  int get activeFilterCount {
    int count = 0;
    if (sortOption != ExploreSortOption.recommended) count++;
    if (minRating > 0.0) count++;
    if (priceRange != ExplorePriceRange.all) count++;
    return count;
  }

  ExploreFilterCriteria copyWith({
    ExploreSortOption? sortOption,
    double? minRating,
    ExplorePriceRange? priceRange,
  }) {
    return ExploreFilterCriteria(
      sortOption: sortOption ?? this.sortOption,
      minRating: minRating ?? this.minRating,
      priceRange: priceRange ?? this.priceRange,
    );
  }
}

/// Self-contained modal bottom sheet for adjusting sorting and filter criteria on Explore.
class ExploreSortFilterSheet extends StatefulWidget {
  final ExploreFilterCriteria currentCriteria;

  const ExploreSortFilterSheet({
    super.key,
    required this.currentCriteria,
  });

  @override
  State<ExploreSortFilterSheet> createState() => _ExploreSortFilterSheetState();
}

class _ExploreSortFilterSheetState extends State<ExploreSortFilterSheet> {
  late ExploreSortOption _tempSort;
  late double _tempMinRating;
  late ExplorePriceRange _tempPriceRange;

  @override
  void initState() {
    super.initState();
    _tempSort = widget.currentCriteria.sortOption;
    _tempMinRating = widget.currentCriteria.minRating;
    _tempPriceRange = widget.currentCriteria.priceRange;
  }

  bool get _hasActiveFilters =>
      _tempSort != ExploreSortOption.recommended ||
      _tempMinRating > 0.0 ||
      _tempPriceRange != ExplorePriceRange.all;

  void _resetAll() {
    setState(() {
      _tempSort = ExploreSortOption.recommended;
      _tempMinRating = 0.0;
      _tempPriceRange = ExplorePriceRange.all;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      ExploreFilterCriteria(
        sortOption: _tempSort,
        minRating: _tempMinRating,
        priceRange: _tempPriceRange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxSheetHeight = media.size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag Handle ──
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Sort & Filter',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: OleenaTheme.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (_hasActiveFilters)
                    TextButton(
                      onPressed: _resetAll,
                      style: TextButton.styleFrom(
                        foregroundColor: OleenaTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Reset All',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: OleenaTheme.textDark,
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // ── Scrollable Body ──
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Sort Section ──
                    _buildSectionHeader(
                      icon: Icons.swap_vert_rounded,
                      title: 'Sort By',
                    ),
                    const SizedBox(height: 12),
                    ...ExploreSortOption.values.map(_buildSortOptionTile),
                    const SizedBox(height: 24),

                    // ── 2. Rating Section (Additional Filter) ──
                    _buildSectionHeader(
                      icon: Icons.star_rounded,
                      title: 'Customer Rating',
                    ),
                    const SizedBox(height: 12),
                    _buildRatingOptions(),
                    const SizedBox(height: 24),

                    // ── 3. Price Range Section ──
                    _buildSectionHeader(
                      icon: Icons.payments_outlined,
                      title: 'Starting Budget',
                    ),
                    const SizedBox(height: 12),
                    _buildPriceRangeOptions(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Footer Apply Action ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_hasActiveFilters)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _resetAll,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: OleenaTheme.textDark,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Clear',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (_hasActiveFilters) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OleenaTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: OleenaTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: OleenaTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptionTile(ExploreSortOption option) {
    final isSelected = _tempSort == option;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _tempSort = option;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? OleenaTheme.primaryTint : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? OleenaTheme.primary : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                size: 20,
                color: isSelected ? OleenaTheme.primary : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? OleenaTheme.primary : OleenaTheme.textDark,
                      ),
                    ),
                    Text(
                      option.description,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isSelected ? OleenaTheme.primary.withValues(alpha: 0.8) : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? OleenaTheme.primary : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: OleenaTheme.primary,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingOptions() {
    final ratings = [
      {'label': 'Any Rating', 'value': 0.0},
      {'label': '4.0+ ★', 'value': 4.0},
      {'label': '4.5+ ★', 'value': 4.5},
      {'label': '4.8+ ★', 'value': 4.8},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ratings.map((r) {
        final val = r['value'] as double;
        final label = r['label'] as String;
        final isSelected = (_tempMinRating - val).abs() < 0.01;

        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _tempMinRating = val;
            });
          },
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
          showCheckmark: isSelected && val > 0.0,
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExplorePriceRange.values.map((range) {
        final isSelected = _tempPriceRange == range;
        return ChoiceChip(
          label: Text(range.label),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _tempPriceRange = range;
            });
          },
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
      }).toList(),
    );
  }
}
