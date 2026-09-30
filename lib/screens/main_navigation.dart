import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'explore/explore_screen.dart';
import 'favorites/favorites_screen.dart';
import 'inquiries/my_inquiries_screen.dart';
import 'profile/profile_screen.dart';

// ---------------------------------------------------------------------------
// Icon for the centre AI FAB — change this one constant to swap the icon.
// ---------------------------------------------------------------------------
const IconData _kAiIcon = Icons.smart_toy_rounded;

/// Root navigation shell with a 4-tab BottomAppBar and a central AI FAB:
///   [Explore] [Favourites]  (AI button)  [Inquiries] [Profile]
///
/// The AI button is NOT a tab — it has no selected state and opens a
/// separate full-screen route (/ai-chat) via context.push(), so back
/// navigation returns to the same tab with its IndexedStack state intact.
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

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color color =
        isSelected ? OleenaTheme.primary : OleenaTheme.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();

    return Scaffold(
      // --------------- body -----------------------------------------------
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),

      // --------------- bottom bar -----------------------------------------
      // BottomAppBar with CircularNotchedRectangle creates the notch for
      // the docked FAB.  The two left tabs go in the left half and the two
      // right tabs go in the right half, with a ~72 px gap in the centre.
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        notchMargin: 8,
        // Explicit height so the icon+label pair fits without overflow.
        height: 68,
        shape: const CircularNotchedRectangle(),
        // padding: EdgeInsets.zero removes BottomAppBar's default 12px
        // horizontal padding, giving full width to the tab items.
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // Left pair: Explore (0) + Favourites (1)
            _buildTabItem(
              index: 0,
              icon: _navItems[0].icon,
              activeIcon: _navItems[0].activeIcon,
              label: _navItems[0].label,
            ),
            _buildTabItem(
              index: 1,
              icon: _navItems[1].icon,
              activeIcon: _navItems[1].activeIcon,
              label: _navItems[1].label,
            ),

            // Centre gap reserved for the docked FAB (~72 logical px)
            const SizedBox(width: 72),

            // Right pair: Inquiries (2) + Profile (3)
            _buildTabItem(
              index: 2,
              icon: _navItems[2].icon,
              activeIcon: _navItems[2].activeIcon,
              label: _navItems[2].label,
            ),
            _buildTabItem(
              index: 3,
              icon: _navItems[3].icon,
              activeIcon: _navItems[3].activeIcon,
              label: _navItems[3].label,
            ),
          ],
        ),
      ),

      // --------------- AI CTA button --------------------------------------
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Semantics(
        label: 'AI Wedding Planner',
        button: true,
        child: FloatingActionButton(
          tooltip: 'AI Wedding Planner',
          backgroundColor: OleenaTheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          highlightElevation: 6,
          shape: const CircleBorder(),
          // Push (not go) so back button returns to the current tab.
          onPressed: () => context.push('/ai-chat'),
          child: const Icon(_kAiIcon, size: 30),
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
