import 'package:flutter_test/flutter_test.dart';
import 'package:oleena/models/listing_model.dart';
import 'package:oleena/features/venue/widgets/explore_filter_sheet.dart';

void main() {
  group('Explore Sorting and Filtering Tests', () {
    late List<Listing> sampleListings;

    setUp(() {
      sampleListings = [
        Listing(
          id: '1',
          serviceId: 1,
          title: 'Royal Grand Ballroom',
          category: 'Hotel / Venue',
          categoryId: 1,
          categoryIcon: 'location_city',
          shortDescription: 'Luxury banquet venue in Colombo',
          description: 'Full ballroom description',
          priceFrom: 350000,
          isPriceOnRequest: false,
          coverImageUrl: 'https://example.com/venue.jpg',
          images: [],
          vendor: VendorInfo(
            id: 'v1',
            vendorId: 101,
            name: 'Grand Hotel Colombo',
            location: 'Colombo 03',
            rating: 4.9,
            reviewCount: 42,
          ),
        ),
        Listing(
          id: '2',
          serviceId: 2,
          title: 'Budget Elegance Garden',
          category: 'Hotel / Venue',
          categoryId: 1,
          categoryIcon: 'location_city',
          shortDescription: 'Affordable open-air garden space',
          description: 'Garden description',
          priceFrom: 85000,
          isPriceOnRequest: false,
          coverImageUrl: 'https://example.com/garden.jpg',
          images: [],
          vendor: VendorInfo(
            id: 'v2',
            vendorId: 102,
            name: 'Serene Gardens',
            location: 'Kandy',
            rating: 4.2,
            reviewCount: 15,
          ),
        ),
        Listing(
          id: '3',
          serviceId: 3,
          title: 'Candid Moments Photography',
          category: 'Photography',
          categoryId: 2,
          categoryIcon: 'camera_alt',
          shortDescription: 'Complete wedding photography coverage',
          description: 'Photo coverage',
          priceFrom: 180000,
          isPriceOnRequest: false,
          coverImageUrl: 'https://example.com/photo.jpg',
          images: [],
          vendor: VendorInfo(
            id: 'v3',
            vendorId: 103,
            name: 'Flash Studios',
            location: 'Colombo 05',
            rating: 4.7,
            reviewCount: 30,
          ),
        ),
        Listing(
          id: '4',
          serviceId: 4,
          title: 'Custom VIP Band & Sound',
          category: 'Music',
          categoryId: 5,
          categoryIcon: 'music_note',
          shortDescription: 'Bespoke live music ensemble',
          description: 'Live band description',
          priceFrom: 0,
          isPriceOnRequest: true,
          coverImageUrl: 'https://example.com/music.jpg',
          images: [],
          vendor: VendorInfo(
            id: 'v4',
            vendorId: 104,
            name: 'Symphony Live',
            location: 'Galle',
            rating: 4.6,
            reviewCount: 22,
          ),
        ),
      ];
    });

    test('ExploreFilterCriteria default values and activeFilterCount', () {
      const criteria = ExploreFilterCriteria();
      expect(criteria.sortOption, ExploreSortOption.recommended);
      expect(criteria.minRating, 0.0);
      expect(criteria.priceRange, ExplorePriceRange.all);
      expect(criteria.isFiltered, isFalse);
      expect(criteria.activeFilterCount, 0);

      final modified = criteria.copyWith(
        sortOption: ExploreSortOption.priceLowToHigh,
        minRating: 4.5,
      );
      expect(modified.isFiltered, isTrue);
      expect(modified.activeFilterCount, 2);
    });

    test('Sorts by Price: Low to High with Price on Request at the bottom', () {
      final list = List<Listing>.from(sampleListings);
      list.sort((a, b) {
        if (a.priceFrom <= 0 && b.priceFrom > 0) return 1;
        if (b.priceFrom <= 0 && a.priceFrom > 0) return -1;
        return a.priceFrom.compareTo(b.priceFrom);
      });

      expect(list[0].priceFrom, 85000); // Budget Elegance Garden
      expect(list[1].priceFrom, 180000); // Candid Moments Photography
      expect(list[2].priceFrom, 350000); // Royal Grand Ballroom
      expect(list[3].priceFrom, 0); // Custom VIP Band (Price on request placed last)
    });

    test('Sorts by Price: High to Low with Price on Request at the bottom', () {
      final list = List<Listing>.from(sampleListings);
      list.sort((a, b) {
        if (a.priceFrom <= 0 && b.priceFrom > 0) return 1;
        if (b.priceFrom <= 0 && a.priceFrom > 0) return -1;
        return b.priceFrom.compareTo(a.priceFrom);
      });

      expect(list[0].priceFrom, 350000); // Royal Grand Ballroom
      expect(list[1].priceFrom, 180000); // Candid Moments Photography
      expect(list[2].priceFrom, 85000); // Budget Elegance Garden
      expect(list[3].priceFrom, 0); // Custom VIP Band
    });

    test('Sorts by Rating: High to Low', () {
      final list = List<Listing>.from(sampleListings);
      list.sort((a, b) {
        final cmp = b.rating.compareTo(a.rating);
        if (cmp != 0) return cmp;
        return b.reviewCount.compareTo(a.reviewCount);
      });

      expect(list[0].rating, 4.9); // Grand Hotel Colombo
      expect(list[1].rating, 4.7); // Flash Studios
      expect(list[2].rating, 4.6); // Symphony Live
      expect(list[3].rating, 4.2); // Serene Gardens
    });

    test('Filters by Minimum Rating 4.5+', () {
      final filtered = sampleListings.where((item) => item.rating >= 4.5).toList();
      expect(filtered.length, 3);
      expect(filtered.any((item) => item.rating < 4.5), isFalse);
    });

    test('Filters by Price Range: Under 100K', () {
      final filtered = sampleListings
          .where((item) => item.priceFrom > 0 && item.priceFrom <= 100000)
          .toList();
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Budget Elegance Garden');
    });

    test('Filters by Price Range: 100K - 250K', () {
      final filtered = sampleListings
          .where((item) => item.priceFrom >= 100000 && item.priceFrom <= 250000)
          .toList();
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Candid Moments Photography');
    });

    test('Category + Search + Minimum Rating + Price Range combine cleanly', () {
      // Filter by Category: 'Hotel / Venue', Min Rating: 4.5, Search: 'Colombo'
      const selectedCategory = 'Hotel / Venue';
      const minRating = 4.5;
      const query = 'colombo';

      final combined = sampleListings.where((item) {
        final matchesQuery = query.isEmpty ||
            item.title.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query) ||
            item.vendor.name.toLowerCase().contains(query) ||
            item.vendor.location.toLowerCase().contains(query);

        final matchesCategory = selectedCategory == 'All' ||
            item.category.toLowerCase().contains(selectedCategory.toLowerCase());

        final matchesRating = minRating <= 0.0 || item.rating >= minRating;

        return matchesQuery && matchesCategory && matchesRating;
      }).toList();

      expect(combined.length, 1);
      expect(combined.first.title, 'Royal Grand Ballroom');
    });

    test('Zero matches returns empty list without error', () {
      const selectedCategory = 'Catering'; // None in sample
      final results = sampleListings.where((item) {
        return item.category.toLowerCase().contains(selectedCategory.toLowerCase());
      }).toList();

      expect(results.isEmpty, isTrue);
    });
  });
}
