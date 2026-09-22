/// Vendor model for Oleena Wedding Planner.
class Vendor {
  final String id;
  final String name;
  final String category;
  final String categoryIcon;
  final double priceFrom;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String location;
  final String description;
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
    required this.location,
    required this.description,
    this.isFavorite = false,
  });

  /// Returns a formatted price string in LKR.
  String get formattedPrice => 'LKR ${priceFrom.toStringAsFixed(0)}';

  /// Returns a copy of this vendor with toggled isFavorite.
  Vendor copyWith({bool? isFavorite}) {
    return Vendor(
      id: id,
      name: name,
      category: category,
      categoryIcon: categoryIcon,
      priceFrom: priceFrom,
      rating: rating,
      reviewCount: reviewCount,
      imageUrl: imageUrl,
      location: location,
      description: description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
