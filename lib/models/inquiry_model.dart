import '../core/app_config.dart';

/// Data model representing a customer inquiry sent to a wedding vendor.
class Inquiry {
  final int inquiryId;
  final int? vendorId;
  final String vendorName;
  final String? vendorImage;
  final int? serviceId;
  final String? serviceName;
  final DateTime? weddingDate;
  final int? guestCount;
  final double? budget;
  final String? message;
  final String? attachmentUrl;
  final String status;
  final DateTime? createdAt;

  const Inquiry({
    required this.inquiryId,
    this.vendorId,
    required this.vendorName,
    this.vendorImage,
    this.serviceId,
    this.serviceName,
    this.weddingDate,
    this.guestCount,
    this.budget,
    this.message,
    this.attachmentUrl,
    required this.status,
    this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isReplied => status.toLowerCase() == 'replied';

  String get formattedBudget {
    if (budget == null || budget! <= 0) return 'Not specified';
    return 'LKR ${budget!.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String get formattedWeddingDate {
    if (weddingDate == null) return 'Flexible';
    final d = weddingDate!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get formattedCreatedDate {
    if (createdAt == null) return '';
    final d = createdAt!.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String? _resolveMediaUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = AppConfig.baseUrl.replaceAll('/api', '');
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString());
    }

    return Inquiry(
      inquiryId: parseInt(json['inquiryId']) ?? 0,
      vendorId: parseInt(json['vendorId']),
      vendorName: json['vendorName']?.toString() ?? 'Wedding Vendor',
      vendorImage: _resolveMediaUrl(json['vendorImage']?.toString()),
      serviceId: parseInt(json['serviceId']),
      serviceName: json['serviceName']?.toString(),
      weddingDate: parseDate(json['weddingDate']),
      guestCount: parseInt(json['guestCount']),
      budget: parseDouble(json['budget']),
      message: json['message']?.toString(),
      attachmentUrl: _resolveMediaUrl(json['attachmentUrl']?.toString()),
      status: json['status']?.toString() ?? 'Pending',
      createdAt: parseDate(json['createdAt']),
    );
  }
}
