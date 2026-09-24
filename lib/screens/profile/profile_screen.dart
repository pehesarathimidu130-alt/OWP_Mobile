import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/auth_provider.dart';
import '../../core/favorites_provider.dart';
import '../../core/theme.dart';
import '../../features/profile/providers/customer_profile_provider.dart';
import '../../features/profile/providers/notification_preferences_provider.dart';
import '../../features/profile/widgets/change_password_dialog.dart';
import '../../features/profile/widgets/edit_profile_sheet.dart';
import '../../features/profile/widgets/notification_preferences_card.dart';
import '../../features/profile/widgets/profile_photo_sheet.dart';

/// Customer Profile Screen displaying account details, statistics, and profile management actions.
///
/// Handles all four states: Loading, Error, Empty (Guest), and Success.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      context.read<CustomerProfileProvider>().fetchProfile(authFallback: authProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<CustomerProfileProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    // Watch notification prefs so the card re-renders on toggle
    context.watch<NotificationPreferencesProvider>();

    final isAuthenticated = authProvider.isAuthenticated;
    final profile = profileProvider.profile;
    final isLoading = profileProvider.isLoading;
    final errorMessage = profileProvider.errorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'My Account',
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
          if (isAuthenticated && profile != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: OleenaTheme.primary),
              tooltip: 'Edit Profile',
              onPressed: () => EditProfileSheet.show(context, profile),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: OleenaTheme.primary,
          onRefresh: () async {
            if (isAuthenticated) {
              await context.read<CustomerProfileProvider>().fetchProfile(authFallback: authProvider);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // ── 1. Error Banner (if any) ─────────────────────────
                if (errorMessage != null && isAuthenticated) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: OleenaTheme.caption.copyWith(color: Colors.red.shade900),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadProfile,
                          child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── 2. Loading State Placeholder ─────────────────────
                if (isLoading && profile == null) ...[
                  _buildLoadingShimmer(),
                ]
                // ── 3. Profile Header Card ───────────────────────────
                else ...[
                  _buildHeaderCard(context, isAuthenticated, authProvider, profile),
                ],

                const SizedBox(height: 20),

                // ── 4. Quick Statistics Row (Authenticated) ──────────
                if (isAuthenticated) ...[
                  _buildStatsRow(favoritesProvider.count, profile?.inquiriesCount ?? 0),
                  const SizedBox(height: 20),
                ],

                // ── 5. Guest Notice & Sign In Prompt ─────────────────
                if (!isAuthenticated) ...[
                  _buildGuestPrompt(context),
                  const SizedBox(height: 20),
                ],

                // ── 6. Personal Information Card (Authenticated) ─────
                if (isAuthenticated && profile != null) ...[
                  _buildPersonalInfoCard(context, profile),
                  const SizedBox(height: 20),
                ],

                // ── 7. Notification Preferences Card (Authenticated) ─
                if (isAuthenticated) ...[
                  const NotificationPreferencesCard(),
                  const SizedBox(height: 20),
                ],

                // ── 7. Navigation Actions Menu ───────────────────────
                _MenuItem(
                  icon: Icons.favorite_border_rounded,
                  title: 'Saved Favourites',
                  subtitle: '${favoritesProvider.count} packages shortlisted',
                  onTap: () => context.push('/favorites'),
                ),
                const SizedBox(height: 12),

                if (isAuthenticated) ...[
                  _MenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Security & Password',
                    subtitle: 'Change your account password',
                    onTap: () => ChangePasswordDialog.show(context),
                  ),
                  const SizedBox(height: 12),
                ],

                _MenuItem(
                  icon: Icons.explore_outlined,
                  title: 'Explore Vendors',
                  subtitle: 'Browse venues, catering, and music',
                  onTap: () => context.go('/explore'),
                ),

                const SizedBox(height: 32),

                // ── 8. Sign Out Button ───────────────────────────────
                if (isAuthenticated)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          context.read<FavoritesProvider>().clear();
                          context.read<CustomerProfileProvider>().clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: Text(
                        'Sign Out',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Profile Header Card showing avatar initials, name, and email
  Widget _buildHeaderCard(
    BuildContext context,
    bool isAuthenticated,
    AuthProvider auth,
    dynamic profile,
  ) {
    final initials = profile != null ? profile.initials : auth.userInitials;
    final displayName = profile != null ? profile.displayName : auth.displayName;
    final email = profile != null ? profile.email : (auth.email ?? 'Sign in to sync your wedding planning');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar — tappable to open ProfilePhotoSheet
          GestureDetector(
            onTap: isAuthenticated
                ? () => ProfilePhotoSheet.show(context)
                : null,
            child: Stack(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: OleenaTheme.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isAuthenticated
                        ? Text(
                            initials,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: OleenaTheme.primary,
                            ),
                          )
                        : const Icon(
                            Icons.person_outline_rounded,
                            size: 34,
                            color: OleenaTheme.primary,
                          ),
                  ),
                ),
                if (isAuthenticated)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: OleenaTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAuthenticated ? displayName : 'Guest User',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: OleenaTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: OleenaTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isAuthenticated) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: OleenaTheme.primaryTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 13, color: OleenaTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Customer Member',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: OleenaTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick statistics counter row (Favourites and Inquiries)
  Widget _buildStatsRow(int favCount, int inquiriesCount) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFE91E63),
            label: 'Saved Packages',
            value: '$favCount',
            onTap: () => context.push('/favorites'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.chat_bubble_rounded,
            iconColor: OleenaTheme.primary,
            label: 'Direct Inquiries',
            value: '$inquiriesCount',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  /// Detailed personal information display
  Widget _buildPersonalInfoCard(BuildContext context, dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: OleenaTheme.textDark,
                ),
              ),
              InkWell(
                onTap: () => EditProfileSheet.show(context, profile),
                child: Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OleenaTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'First Name',
            value: profile.firstName.isNotEmpty ? profile.firstName : '—',
          ),
          const Divider(height: 18),
          _InfoRow(
            label: 'Last Name',
            value: profile.lastName.isNotEmpty ? profile.lastName : '—',
          ),
          const Divider(height: 18),
          _InfoRow(
            label: 'Phone Number',
            value: (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
                ? profile.phoneNumber!
                : 'Not provided',
          ),
          const Divider(height: 18),
          _InfoRow(
            label: 'Email Status',
            value: 'Verified Account',
            valueColor: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  /// Guest sign in encouragement card
  Widget _buildGuestPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: OleenaTheme.primaryTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OleenaTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_open_rounded, color: OleenaTheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sign in to save favourite packages and contact wedding vendors.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: OleenaTheme.textDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: OleenaTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  /// Skeleton loader widget during initial fetch
  Widget _buildLoadingShimmer() {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: OleenaTheme.primary, strokeWidth: 2.2),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: OleenaTheme.textDark,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: OleenaTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: OleenaTheme.textMuted),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? OleenaTheme.textDark,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: OleenaTheme.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: OleenaTheme.primary, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OleenaTheme.textDark,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: OleenaTheme.textMuted,
                  ),
                )
              : null,
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
