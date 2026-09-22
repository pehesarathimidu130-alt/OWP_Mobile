import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home/browse_services_screen.dart';
import 'placeholders/inquiries_screen.dart';
import 'placeholders/ai_planner_screen.dart';
import 'placeholders/tracker_screen.dart';

/// Root navigation shell with a 4-tab BottomNavigationBar.
/// Each tab is lazily preserved via IndexedStack.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      label: 'Explore',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    _NavItem(
      label: 'Messages',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
    ),
    _NavItem(
      label: 'AI Planner',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
    ),
    _NavItem(
      label: 'My Wedding',
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
    ),
  ];

  static const List<Widget> _screens = [
    BrowseServicesScreen(),
    InquiriesScreen(),
    AiPlannerScreen(),
    TrackerScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB03A6E).withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedLabelStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.lato(fontSize: 11),
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

/// Simple data class for bottom nav items.
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
