/// Model representing customer profile data returned by OWP Backend.
class CustomerProfile {
  final int customerId;
  final int userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final DateTime? createdAt;
  final int favoritesCount;
  final int inquiriesCount;

  CustomerProfile({
    required this.customerId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.createdAt,
    this.favoritesCount = 0,
    this.inquiriesCount = 0,
  });

  /// User-friendly initials for avatar display
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (fullName.trim().isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : 'O';
  }

  /// Display name prioritizing fullName, then combined first and last, then email
  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return email.split('@').first;
  }

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString());
    }

    return CustomerProfile(
      customerId: json['customerId'] is int
          ? json['customerId']
          : int.tryParse(json['customerId']?.toString() ?? '0') ?? 0,
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      createdAt: parsedDate,
      favoritesCount: json['favoritesCount'] is int
          ? json['favoritesCount']
          : int.tryParse(json['favoritesCount']?.toString() ?? '0') ?? 0,
      inquiriesCount: json['inquiriesCount'] is int
          ? json['inquiriesCount']
          : int.tryParse(json['inquiriesCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': createdAt?.toIso8601String(),
        'favoritesCount': favoritesCount,
        'inquiriesCount': inquiriesCount,
      };

  CustomerProfile copyWith({
    int? customerId,
    int? userId,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
    int? favoritesCount,
    int? inquiriesCount,
  }) {
    return CustomerProfile(
      customerId: customerId ?? this.customerId,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      inquiriesCount: inquiriesCount ?? this.inquiriesCount,
    );
  }
}
