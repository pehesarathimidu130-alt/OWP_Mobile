import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

/// Card widget displaying notification preference options.
///
/// Note: Backend currently lacks customer notification preference endpoints.
/// In accordance with platform integrity rules, unsupported features (Weekly Digest &
/// Promotions) have been removed, and remaining toggles are displayed in a disabled
/// state with a 'Coming soon' indicator rather than faking local-only persistence.
class NotificationPreferencesCard extends StatelessWidget {
  const NotificationPreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Section header with 'Coming soon' pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: OleenaTheme.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: OleenaTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Notification Preferences',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: OleenaTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Coming soon',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: OleenaTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const _DisabledNotifRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Inquiry Updates',
            subtitle: 'Status changes on your inquiries',
          ),
          const Divider(height: 1, thickness: 0.6),
          const _DisabledNotifRow(
            icon: Icons.favorite_border_rounded,
            title: 'Favourite Price Changes',
            subtitle: 'Alerts when saved services change prices',
          ),
        ],
      ),
    );
  }
}

/// Single disabled row item inside [NotificationPreferencesCard].
class _DisabledNotifRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DisabledNotifRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: false,
            onChanged: null,
            inactiveTrackColor: Colors.grey.shade200,
            inactiveThumbColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

