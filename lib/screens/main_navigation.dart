import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_gate.dart';
import '../core/theme.dart';
import 'explore/explore_screen.dart';
import 'favorites/favorites_screen.dart';
import 'home/home_screen.dart';
import 'placeholders/inquiries_screen.dart';
import 'placeholders/profile_placeholder_screen.dart';

/// Root navigation shell with a 5-tab BottomNavigationBar.
///
/// • Public tabs: Home (0), Explore (1) – Always open to guests without login.
/// • Protected tabs: Favourites (2), Inquiries (3), Profile (4) – Protected via action-based [requireLogin].
class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  static const List<_NavItem> _navItems = [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Explore',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
    ),
    _NavItem(
      label: 'Favourites',
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
    ),
    _NavItem(
      label: 'Inquiries',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  List<Widget> _buildScreens() => [
        HomeScreen(onExploreTap: () => setState(() => _selectedIndex = 1)),
        const ExploreScreen(),
        FavoritesScreen(onExploreTap: () => setState(() => _selectedIndex = 1)),
        const InquiriesScreen(),
        const ProfileScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    // Public tabs: index 0 (Home) and index 1 (Explore)
    if (index == 0 || index == 1) {
      setState(() => _selectedIndex = index);
      return;
    }

    // Protected tab: Favourites
    if (index == 2) {
      requireLogin(
        context,
        reason: 'Sign in to save and manage your favourite wedding vendors',
        icon: Icons.favorite_border_rounded,
        onSuccess: () {
          setState(() => _selectedIndex = 2);
        },
      );
      return;
    }

    // Protected tab: Inquiries
    if (index == 3) {
      requireLogin(
        context,
        reason: 'Sign in to send inquiries and chat directly with vendors',
        icon: Icons.chat_bubble_outline_rounded,
        onSuccess: () {
          setState(() => _selectedIndex = 3);
        },
      );
      return;
    }

    // Protected tab: Profile
    if (index == 4) {
      requireLogin(
        context,
        reason: 'Sign in to view your profile and wedding planning dashboard',
        icon: Icons.person_outline_rounded,
        onSuccess: () {
          setState(() => _selectedIndex = 4);
        },
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _buildScreens(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: OleenaTheme.primary,
          unselectedItemColor: OleenaTheme.textMuted,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: _navItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
