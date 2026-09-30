import '../core/app_config.dart';

/// Vendor data model with null-safe parsing for .NET backend responses.
class Vendor {
  final String id;
  final String name;
  final String category;
  final String categoryIcon;
  final double priceFrom;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String? coverImageUrl;
  final String? logoUrl;
  final String location;
  final String? city;
  final String description;
  final bool isFeatured;
  bool isFavorite;

  Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryIcon,
    required this.priceFrom,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.coverImageUrl,
    this.logoUrl,
    required this.location,
    this.city,
    required this.description,
    this.isFeatured = false,
    this.isFavorite = false,
  });

  /// Human-readable price formatted in Sri Lankan Rupees (LKR)
  String get formattedPrice {
    if (priceFrom <= 0) return 'Price on request';
    return 'LKR ${priceFrom.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  /// Ensures image URLs are absolute so relative backend paths (e.g. `/uploads/...`) resolve properly
  static String _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80';
    }
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    // Prefix relative paths with the backend host
    final base = AppConfig.baseUrl.replaceAll('/api', '');
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }

  /// Maps category string to an icon identifier
  static String _resolveCategoryIcon(String? category) {
    if (category == null || category.isEmpty) return 'sparkles';
    final cat = category.toLowerCase();
    if (cat.contains('venue') || cat.contains('hotel')) return 'location_city';
    if (cat.contains('photo') || cat.contains('video')) return 'camera_alt';
    if (cat.contains('music') || cat.contains('dj') || cat.contains('band')) return 'music_note';
    if (cat.contains('cater') || cat.contains('food')) return 'restaurant';
    if (cat.contains('decor') || cat.contains('flower') || cat.contains('flora')) return 'local_florist';
    if (cat.contains('attire') || cat.contains('dress')) return 'checkroom';
    return 'stars';
  }

  /// Creates a Vendor instance from a .NET JSON dictionary with full null safety.
  factory Vendor.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['vendorId'] ?? json['serviceId'] ?? '';
    final rawName = json['name'] ?? json['businessName'] ?? json['serviceName'] ?? 'Unnamed Vendor';
    final rawCategory = json['category'] ?? json['categoryName'] ?? 'General';

    // Parse priceFrom safely
    double parsedPrice = 0.0;
    final priceVal = json['priceFrom'] ?? json['price'];
    if (priceVal is num) {
      parsedPrice = priceVal.toDouble();
    } else if (priceVal is String) {
      parsedPrice = double.tryParse(priceVal) ?? 0.0;
    }

    // Parse rating safely
    double parsedRating = 4.8;
    final ratingVal = json['rating'];
    if (ratingVal is num) {
      parsedRating = ratingVal.toDouble();
    } else if (ratingVal is String) {
      parsedRating = double.tryParse(ratingVal) ?? 4.8;
    }

    // Parse review count safely
    int parsedReviewCount = 0;
    final reviewVal = json['reviewCount'] ?? json['reviews'] ?? json['review_count'];
    if (reviewVal is num) {
      parsedReviewCount = reviewVal.toInt();
    } else if (reviewVal is String) {
      parsedReviewCount = int.tryParse(reviewVal) ?? 0;
    }

    // Resolve image URL
    final rawImg = json['imageUrl'] ?? json['coverImageUrl'] ?? json['logoUrl'];
    final resolvedImg = _resolveImageUrl(rawImg?.toString());

    // Location
    final rawLocation = json['location'] ?? json['city'] ?? json['address'] ?? 'Sri Lanka';

    // Description
    final rawDesc = json['description'] ?? json['shortDescription'] ?? '';

    return Vendor(
      id: rawId.toString(),
      name: rawName.toString(),
      category: rawCategory.toString(),
      categoryIcon: (json['categoryIcon'] ?? _resolveCategoryIcon(rawCategory.toString())).toString(),
      priceFrom: parsedPrice,
      rating: parsedRating,
      reviewCount: parsedReviewCount,
      imageUrl: resolvedImg,
      coverImageUrl: json['coverImageUrl']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      location: rawLocation.toString(),
      city: json['city']?.toString(),
      description: rawDesc.toString(),
      isFeatured: json['isFeatured'] == true || json['isApproved'] == true,
      isFavorite: json['isFavorite'] == true,
    );
  }

  /// Converts to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'categoryIcon': categoryIcon,
      'priceFrom': priceFrom,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl,
      'logoUrl': logoUrl,
      'location': location,
      'city': city,
      'description': description,
      'isFeatured': isFeatured,
      'isFavorite': isFavorite,
    };
  }

  /// Creates a copy with modified fields
  Vendor copyWith({
    String? id,
    String? name,
    String? category,
    String? categoryIcon,
    double? priceFrom,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? coverImageUrl,
    String? logoUrl,
    String? location,
    String? city,
    String? description,
    bool? isFeatured,
    bool? isFavorite,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      priceFrom: priceFrom ?? this.priceFrom,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      location: location ?? this.location,
      city: city ?? this.city,
      description: description ?? this.description,
      isFeatured: isFeatured ?? this.isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
