import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../providers/notification_preferences_provider.dart';

/// Card widget displaying notification preference toggle switches.
///
/// Reads and writes through [NotificationPreferencesProvider].
/// Designed to be dropped into the profile screen body without external state.
class NotificationPreferencesCard extends StatelessWidget {
  const NotificationPreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<NotificationPreferencesProvider>();

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
              Text(
                'Notification Preferences',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: OleenaTheme.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _NotifToggle(
            icon: Icons.local_offer_outlined,
            title: 'New Offers & Packages',
            subtitle: 'Alerts when vendors post new deals',
            value: prefs.newOffers,
            onChanged: prefs.toggleNewOffers,
          ),
          const Divider(height: 1, thickness: 0.6),
          _NotifToggle(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Inquiry Updates',
            subtitle: 'Status changes on your inquiries',
            value: prefs.inquiryUpdates,
            onChanged: prefs.toggleInquiryUpdates,
          ),
          const Divider(height: 1, thickness: 0.6),
          _NotifToggle(
            icon: Icons.event_outlined,
            title: 'Wedding Reminders',
            subtitle: 'Countdown and planning milestones',
            value: prefs.weddingReminders,
            onChanged: prefs.toggleWeddingReminders,
          ),
          const Divider(height: 1, thickness: 0.6),
          _NotifToggle(
            icon: Icons.mail_outline_rounded,
            title: 'Weekly Digest',
            subtitle: 'A curated weekly roundup',
            value: prefs.weeklyDigest,
            onChanged: prefs.toggleWeeklyDigest,
          ),
          const Divider(height: 1, thickness: 0.6),
          _NotifToggle(
            icon: Icons.campaign_outlined,
            title: 'Promotions',
            subtitle: 'Special offers from OWP partners',
            value: prefs.promotions,
            onChanged: prefs.togglePromotions,
          ),
        ],
      ),
    );
  }
}

/// Single row toggle item inside [NotificationPreferencesCard].
class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
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
          Icon(icon, size: 18, color: OleenaTheme.textMuted),
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
            onChanged: onChanged,
            activeThumbColor: OleenaTheme.primary,
            activeTrackColor: OleenaTheme.primaryTint,
            inactiveTrackColor: Colors.grey.shade200,
            inactiveThumbColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
