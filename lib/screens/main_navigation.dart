import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'explore/explore_screen.dart';
import 'favorites/favorites_screen.dart';
import 'inquiries/my_inquiries_screen.dart';
import 'profile/profile_screen.dart';

/// Root navigation shell with a streamlined 4-tab BottomNavigationBar:
/// 1. Explore (Default / Initial public tab)
/// 2. Favourites
/// 3. Inquiries
/// 4. Profile
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
        const ExploreScreen(),
        FavoritesScreen(onExploreTap: () => setState(() => _selectedIndex = 0)),
        MyInquiriesScreen(onExploreTap: () => setState(() => _selectedIndex = 0)),
        const ProfileScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: _navItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Icon(item.icon),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Icon(item.activeIcon),
                  ),
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
