import '../core/app_config.dart';
import 'vendor.dart';

/// Represents a business service listing added by a vendor.
class Listing {
  final String id;
  final int serviceId;
  final String title;
  final String category;
  final int categoryId;
  final String categoryIcon;
  final String shortDescription;
  final String description;
  final double? price;
  final double priceFrom;
  final bool isPriceOnRequest;
  final String coverImageUrl;
  final List<String> images;
  final VendorInfo vendor;
  bool isFavorite;

  Listing({
    required this.id,
    required this.serviceId,
    required this.title,
    required this.category,
    required this.categoryId,
    required this.categoryIcon,
    required this.shortDescription,
    required this.description,
    this.price,
    required this.priceFrom,
    required this.isPriceOnRequest,
    required this.coverImageUrl,
    required this.images,
    required this.vendor,
    this.isFavorite = false,
  });

  /// Convenience rating delegating to parent vendor rating
  double get rating => vendor.rating;
  int get reviewCount => vendor.reviewCount;

  /// Human-readable price formatted in Sri Lankan Rupees (LKR) or 'Price on request'
  String get formattedPrice {
    if (isPriceOnRequest || priceFrom <= 0) return 'Price on request';
    return 'LKR ${priceFrom.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  static String _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80';
    }
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = AppConfig.baseUrl.replaceAll('/api', '');
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }

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

  factory Listing.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['serviceId'] ?? '';
    final serviceIdVal = json['serviceId'] is int
        ? json['serviceId'] as int
        : (int.tryParse(rawId.toString()) ?? 0);

    final rawTitle = json['title'] ?? json['serviceName'] ?? 'Wedding Service';
    final rawCategory = json['category'] ?? json['categoryName'] ?? 'General';
    final rawCategoryId = json['categoryId'] is int ? json['categoryId'] as int : 0;

    double? parsedPrice;
    final priceVal = json['price'];
    if (priceVal is num) {
      parsedPrice = priceVal.toDouble();
    } else if (priceVal is String) {
      parsedPrice = double.tryParse(priceVal);
    }

    double parsedPriceFrom = parsedPrice ?? 0.0;
    final priceFromVal = json['priceFrom'];
    if (priceFromVal is num) {
      parsedPriceFrom = priceFromVal.toDouble();
    } else if (priceFromVal is String) {
      parsedPriceFrom = double.tryParse(priceFromVal) ?? 0.0;
    }

    final bool isPriceOnReq = json['isPriceOnRequest'] == true ||
        (parsedPrice == null && parsedPriceFrom <= 0);

    final rawCover = json['coverImageUrl'] ?? json['imageUrl'];
    final resolvedCover = _resolveImageUrl(rawCover?.toString());

    List<String> parsedImages = [];
    if (json['images'] is List) {
      for (final item in (json['images'] as List)) {
        if (item != null && item.toString().isNotEmpty) {
          parsedImages.add(_resolveImageUrl(item.toString()));
        }
      }
    }

    final rawVendor = json['vendor'] is Map<String, dynamic>
        ? json['vendor'] as Map<String, dynamic>
        : <String, dynamic>{
            'vendorId': json['vendorId'] ?? 0,
            'name': json['businessName'] ?? 'Verified Vendor',
            'location': json['location'] ?? 'Sri Lanka',
          };

    return Listing(
      id: rawId.toString(),
      serviceId: serviceIdVal,
      title: rawTitle.toString(),
      category: rawCategory.toString(),
      categoryId: rawCategoryId,
      categoryIcon: (json['categoryIcon'] ?? _resolveCategoryIcon(rawCategory.toString())).toString(),
      shortDescription: (json['shortDescription'] ?? '').toString(),
      description: (json['description'] ?? json['shortDescription'] ?? '').toString(),
      price: parsedPrice,
      priceFrom: parsedPriceFrom,
      isPriceOnRequest: isPriceOnReq,
      coverImageUrl: resolvedCover,
      images: parsedImages,
      vendor: VendorInfo.fromJson(rawVendor),
      isFavorite: json['isFavorite'] == true,
    );
  }

  Listing copyWith({
    String? id,
    int? serviceId,
    String? title,
    String? category,
    int? categoryId,
    String? categoryIcon,
    String? shortDescription,
    String? description,
    double? price,
    double? priceFrom,
    bool? isPriceOnRequest,
    String? coverImageUrl,
    List<String>? images,
    VendorInfo? vendor,
    bool? isFavorite,
  }) {
    return Listing(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      title: title ?? this.title,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      price: price ?? this.price,
      priceFrom: priceFrom ?? this.priceFrom,
      isPriceOnRequest: isPriceOnRequest ?? this.isPriceOnRequest,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      images: images ?? this.images,
      vendor: vendor ?? this.vendor,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Represents the parent vendor offering the business service.
class VendorInfo {
  final String id;
  final int vendorId;
  final String name;
  final String? ownerName;
  final String location;
  final String? city;
  final String? address;
  final String? contactNumber;
  final String? email;
  final String? logoUrl;
  final String? coverImageUrl;
  final double rating;
  final int reviewCount;
  final int yearsInBusiness;
  final bool isApproved;

  VendorInfo({
    required this.id,
    required this.vendorId,
    required this.name,
    this.ownerName,
    required this.location,
    this.city,
    this.address,
    this.contactNumber,
    this.email,
    this.logoUrl,
    this.coverImageUrl,
    this.rating = 4.9,
    this.reviewCount = 18,
    this.yearsInBusiness = 3,
    this.isApproved = true,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['vendorId'] ?? 0;
    final vendorIdVal = rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0);

    final rawName = json['name'] ?? json['businessName'] ?? 'Verified Vendor';
    final rawLocation = json['location'] ?? json['city'] ?? json['address'] ?? 'Sri Lanka';

    double parsedRating = 4.9;
    final ratingVal = json['rating'];
    if (ratingVal is num) {
      parsedRating = ratingVal.toDouble();
    } else if (ratingVal is String) {
      parsedRating = double.tryParse(ratingVal) ?? 4.9;
    }

    int parsedReviewCount = 18;
    final revVal = json['reviewCount'] ?? json['reviews'];
    if (revVal is num) {
      parsedReviewCount = revVal.toInt();
    } else if (revVal is String) {
      parsedReviewCount = int.tryParse(revVal) ?? 18;
    }

    int parsedYears = 3;
    final yearsVal = json['yearsInBusiness'];
    if (yearsVal is num) {
      parsedYears = yearsVal.toInt();
    } else if (yearsVal is String) {
      parsedYears = int.tryParse(yearsVal) ?? 3;
    }

    return VendorInfo(
      id: rawId.toString(),
      vendorId: vendorIdVal,
      name: rawName.toString(),
      ownerName: json['ownerName']?.toString(),
      location: rawLocation.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      contactNumber: json['contactNumber']?.toString() ?? json['phone']?.toString(),
      email: json['email']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      rating: parsedRating,
      reviewCount: parsedReviewCount,
      yearsInBusiness: parsedYears,
      isApproved: json['isApproved'] != false,
    );
  }

  /// Converts VendorInfo into a full Vendor object
  Vendor toVendor() {
    return Vendor(
      id: vendorId > 0 ? vendorId.toString() : id,
      name: name,
      category: 'General',
      categoryIcon: 'storefront',
      priceFrom: 0.0,
      rating: rating,
      reviewCount: reviewCount,
      imageUrl: coverImageUrl ?? logoUrl ?? 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
      coverImageUrl: coverImageUrl,
      logoUrl: logoUrl,
      location: location,
      city: city,
      description: '',
      isFeatured: isApproved,
    );
  }
}
