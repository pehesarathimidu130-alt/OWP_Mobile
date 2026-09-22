import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../details/vendor_details_screen.dart';
import '../../data/dummy_vendors.dart';
import '../../models/vendor.dart';

/// Favorites screen – shows all vendors the user has marked as favourite.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Vendor> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = dummyVendors.where((v) => v.isFavorite).toList();
  }

  void _removeFavorite(Vendor vendor) {
    setState(() {
      vendor.isFavorite = false;
      _favorites.remove(vendor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F9),
      appBar: AppBar(
        title: Text(
          'My Favourites',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 64, color: Color(0xFFE8A0BF)),
                  const SizedBox(height: 16),
                  Text(
                    'No favourites yet',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      color: const Color(0xFF9E6B8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the ❤️ on any vendor to save them here.',
                    style: GoogleFonts.lato(color: const Color(0xFFBB8FAE)),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final vendor = _favorites[i];
                return _FavoriteListTile(
                  vendor: vendor,
                  onRemove: () => _removeFavorite(vendor),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VendorDetailsScreen(
                        vendor: vendor,
                        onFavoriteToggled: () => _removeFavorite(vendor),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _FavoriteListTile extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FavoriteListTile({
    required this.vendor,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  vendor.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFFF8BBD9),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D0C2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vendor.categoryIcon}  ${vendor.category}',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: const Color(0xFFB03A6E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC107), size: 14),
                        Text(
                          ' ${vendor.rating}  ·  ${vendor.formattedPrice}',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: const Color(0xFF9E6B8A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_rounded,
                    color: Color(0xFFE91E63)),
                onPressed: onRemove,
                tooltip: 'Remove from favourites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
