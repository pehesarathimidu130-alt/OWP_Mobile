import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/auth_provider.dart';
import '../../core/favorites_provider.dart';
import '../../core/theme.dart';
import '../../widgets/listing_card.dart';

/// Dynamic "My Favourites" screen showing saved listings from the Neon PostgreSQL database.
class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onExploreTap;

  const FavoritesScreen({super.key, this.onExploreTap});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.isAuthenticated) {
          context.read<FavoritesProvider>().fetchFavorites();
        }
      }
    });
  }

  void _navigateToExplore(BuildContext context) {
    if (widget.onExploreTap != null) {
      widget.onExploreTap!();
    } else {
      context.go('/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final favProvider = context.watch<FavoritesProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      appBar: AppBar(
        title: Text(
          'My Favourites',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: OleenaTheme.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          if (isAuthenticated)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: OleenaTheme.primary),
              tooltip: 'Refresh favourites',
              onPressed: () => favProvider.fetchFavorites(),
            ),
        ],
      ),
      body: SafeArea(
        child: _buildContent(context, isAuthenticated, favProvider),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isAuthenticated,
    FavoritesProvider favProvider,
  ) {
    // 1. Unauthenticated State
    if (!isAuthenticated) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: OleenaTheme.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 46,
                  color: OleenaTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Save Your Favourites',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: OleenaTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Log in to view your saved favorites, shortlist dream packages, and sync across all your devices.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: OleenaTheme.textMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text(
                    'Log In to View Favourites',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OleenaTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Loading State
    if (favProvider.isLoading && favProvider.favoriteListings.isEmpty) {
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
              'Loading your saved favourites...',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: OleenaTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Error State
    if (favProvider.errorMessage != null && favProvider.favoriteListings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 54, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Unable to Load Favourites',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OleenaTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                favProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: OleenaTheme.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => favProvider.fetchFavorites(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OleenaTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Empty State
    if (favProvider.favoriteListings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 46,
                  color: Color(0xFFE57373),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No favorites yet',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: OleenaTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start exploring wedding packages and tap the heart icon to save your favourites!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: OleenaTheme.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _navigateToExplore(context),
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: Text(
                  'Start Exploring',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OleenaTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 5. Populated State (renders using exact same ListingCard)
    final items = favProvider.favoriteListings;
    return RefreshIndicator(
      onRefresh: () => favProvider.fetchFavorites(),
      color: OleenaTheme.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final listing = items[index];
          return ListingCard(
            key: ValueKey(listing.serviceId),
            listing: listing,
          );
        },
      ),
    );
  }
}
