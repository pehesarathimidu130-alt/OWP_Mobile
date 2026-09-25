import '../core/app_config.dart';

String resolveMediaUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return '';
  final trimmed = rawUrl.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = AppConfig.baseUrl.replaceAll('/api', '');
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$base$path';
}

class BusinessHoursItem {
  final String day;
  final bool isClosed;
  final String openTime;
  final String closeTime;

  const BusinessHoursItem({
    required this.day,
    required this.isClosed,
    required this.openTime,
    required this.closeTime,
  });

  factory BusinessHoursItem.fromJson(Map<String, dynamic> json) {
    return BusinessHoursItem(
      day: (json['day'] ?? '').toString(),
      isClosed: json['isClosed'] == true,
      openTime: (json['openTime'] ?? '09:00').toString(),
      closeTime: (json['closeTime'] ?? '18:00').toString(),
    );
  }

  String get displayLine {
    if (isClosed) return 'Closed';
    return '$openTime – $closeTime';
  }
}

class VendorPerformanceItem {
  final int performanceId;
  final String title;
  final String category;
  final String? description;
  final String? photoUrl;
  final String? customerName;
  final String? customerFeedback;
  final DateTime? eventDate;

  const VendorPerformanceItem({
    required this.performanceId,
    required this.title,
    required this.category,
    this.description,
    this.photoUrl,
    this.customerName,
    this.customerFeedback,
    this.eventDate,
  });

  factory VendorPerformanceItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['eventDate'];
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    }

    return VendorPerformanceItem(
      performanceId: json['performanceId'] is int
          ? json['performanceId'] as int
          : int.tryParse('${json['performanceId']}') ?? 0,
      title: (json['title'] ?? 'Past event').toString(),
      category: (json['category'] ?? '').toString(),
      description: json['description']?.toString(),
      photoUrl: resolveMediaUrl(json['photoUrl']?.toString()),
      customerName: json['customerName']?.toString(),
      customerFeedback: json['customerFeedback']?.toString(),
      eventDate: parsedDate,
    );
  }
}

class PublicVendorServiceItem {
  final int serviceId;
  final String title;
  final String? category;
  final String? shortDescription;
  final double? price;
  final bool isPriceOnRequest;
  final String? coverImageUrl;

  const PublicVendorServiceItem({
    required this.serviceId,
    required this.title,
    this.category,
    this.shortDescription,
    this.price,
    this.isPriceOnRequest = false,
    this.coverImageUrl,
  });

  factory PublicVendorServiceItem.fromJson(Map<String, dynamic> json) {
    double? parsedPrice;
    final priceVal = json['price'];
    if (priceVal is num) {
      parsedPrice = priceVal.toDouble();
    } else if (priceVal is String) {
      parsedPrice = double.tryParse(priceVal);
    }

    return PublicVendorServiceItem(
      serviceId: json['serviceId'] is int
          ? json['serviceId'] as int
          : int.tryParse('${json['serviceId']}') ?? 0,
      title: (json['title'] ?? 'Service').toString(),
      category: json['category']?.toString(),
      shortDescription: json['shortDescription']?.toString(),
      price: parsedPrice,
      isPriceOnRequest: json['isPriceOnRequest'] == true,
      coverImageUrl: resolveMediaUrl(json['coverImageUrl']?.toString()),
    );
  }

  String get formattedPrice {
    if (isPriceOnRequest || price == null || price! <= 0) return 'Price on request';
    return 'LKR ${price!.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }
}

class PublicVendorProfile {
  final int vendorId;
  final String businessName;
  final String? category;
  final String? tagline;
  final String? description;
  final String? ownerName;
  final String? contactNumber;
  final String? altPhoneNumber;
  final String? email;
  final String? websiteUrl;
  final String? address;
  final String location;
  final String? serviceAreas;
  final String? travelPolicy;
  final int? yearsInBusiness;
  final bool isApproved;
  final String? logoUrl;
  final String? coverImageUrl;
  final int reviewCount;
  final List<BusinessHoursItem> businessHours;
  final List<String> galleryImages;
  final List<VendorPerformanceItem> performances;
  final List<PublicVendorServiceItem> services;

  const PublicVendorProfile({
    required this.vendorId,
    required this.businessName,
    this.category,
    this.tagline,
    this.description,
    this.ownerName,
    this.contactNumber,
    this.altPhoneNumber,
    this.email,
    this.websiteUrl,
    this.address,
    required this.location,
    this.serviceAreas,
    this.travelPolicy,
    this.yearsInBusiness,
    this.isApproved = false,
    this.logoUrl,
    this.coverImageUrl,
    this.reviewCount = 0,
    this.businessHours = const [],
    this.galleryImages = const [],
    this.performances = const [],
    this.services = const [],
  });

  factory PublicVendorProfile.fromJson(Map<String, dynamic> json) {
    final hours = <BusinessHoursItem>[];
    if (json['businessHours'] is List) {
      for (final item in json['businessHours'] as List) {
        if (item is Map<String, dynamic>) {
          hours.add(BusinessHoursItem.fromJson(item));
        }
      }
    }

    final performances = <VendorPerformanceItem>[];
    if (json['performances'] is List) {
      for (final item in json['performances'] as List) {
        if (item is Map<String, dynamic>) {
          performances.add(VendorPerformanceItem.fromJson(item));
        }
      }
    }

    final services = <PublicVendorServiceItem>[];
    if (json['services'] is List) {
      for (final item in json['services'] as List) {
        if (item is Map<String, dynamic>) {
          services.add(PublicVendorServiceItem.fromJson(item));
        }
      }
    }

    final gallery = <String>[];
    if (json['galleryImages'] is List) {
      for (final item in json['galleryImages'] as List) {
        if (item is Map<String, dynamic>) {
          final url = resolveMediaUrl(item['imageUrl']?.toString());
          if (url.isNotEmpty) gallery.add(url);
        } else if (item != null) {
          final url = resolveMediaUrl(item.toString());
          if (url.isNotEmpty) gallery.add(url);
        }
      }
    }

    return PublicVendorProfile(
      vendorId: json['vendorId'] is int
          ? json['vendorId'] as int
          : int.tryParse('${json['vendorId']}') ?? 0,
      businessName: (json['businessName'] ?? 'Vendor').toString(),
      category: json['category']?.toString(),
      tagline: json['tagline']?.toString(),
      description: json['description']?.toString(),
      ownerName: json['ownerName']?.toString(),
      contactNumber: json['contactNumber']?.toString(),
      altPhoneNumber: json['altPhoneNumber']?.toString(),
      email: json['email']?.toString(),
      websiteUrl: json['websiteUrl']?.toString(),
      address: json['address']?.toString(),
      location: (json['location'] ?? json['city'] ?? 'Sri Lanka').toString(),
      serviceAreas: json['serviceAreas']?.toString(),
      travelPolicy: json['travelPolicy']?.toString(),
      yearsInBusiness: json['yearsInBusiness'] is num
          ? (json['yearsInBusiness'] as num).toInt()
          : int.tryParse('${json['yearsInBusiness'] ?? ''}'),
      isApproved: json['isApproved'] == true,
      logoUrl: resolveMediaUrl(json['logoUrl']?.toString()),
      coverImageUrl: resolveMediaUrl(json['coverImageUrl']?.toString()),
      reviewCount: json['reviewCount'] is num
          ? (json['reviewCount'] as num).toInt()
          : performances.where((p) => (p.customerFeedback ?? '').isNotEmpty).length,
      businessHours: hours,
      galleryImages: gallery,
      performances: performances,
      services: services,
    );
  }
}
