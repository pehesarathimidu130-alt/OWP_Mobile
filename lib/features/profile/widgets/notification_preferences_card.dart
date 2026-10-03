import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../providers/notification_preferences_provider.dart';

/// Card widget displaying customer notification preference options.
///
/// Connected to [NotificationPreferencesProvider] with optimistic toggle updates
/// and backend persistence.
class NotificationPreferencesCard extends StatelessWidget {
  const NotificationPreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<NotificationPreferencesProvider?>(context, listen: true);
    final inquiryUpdates = prefs?.inquiryUpdates ?? true;
    final priceChanges = prefs?.priceChanges ?? true;

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
          // Section header
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
            ],
          ),

          const SizedBox(height: 14),

          _PreferenceRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Inquiry Updates',
            subtitle: 'Status changes on your inquiries',
            value: inquiryUpdates,
            onChanged: (val) async {
              if (prefs == null) return;
              try {
                await prefs.toggleInquiryUpdates(val);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update inquiry notification preference.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
          const Divider(height: 1, thickness: 0.6),
          _PreferenceRow(
            icon: Icons.favorite_border_rounded,
            title: 'Favourite Price Changes',
            subtitle: 'Alerts when saved services change prices',
            value: priceChanges,
            onChanged: (val) async {
              if (prefs == null) return;
              try {
                await prefs.togglePriceChanges(val);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update price change notification preference.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Single interactive toggle row inside [NotificationPreferencesCard].
class _PreferenceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: OleenaTheme.primary),
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
                    color: OleenaTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: OleenaTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: OleenaTheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
