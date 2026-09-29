import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/auth_provider.dart';
import '../../../core/theme.dart';

/// Returns the time-of-day greeting word for the given [now].
///
/// Accepts a [DateTime] so the logic is unit-testable without mocking the clock.
///   00:00–11:59 → "morning"
///   12:00–16:59 → "afternoon"
///   17:00–23:59 → "evening"
String greetingPeriod(DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'morning';
  if (hour < 17) return 'afternoon';
  return 'evening';
}

/// Empty-state centred greeting widget.
///
/// Shows the robot avatar circle, personalised Playfair Display headline, and
/// a Poppins sub-heading prompting the user to start chatting.
class ChatGreeting extends StatelessWidget {
  const ChatGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final now = DateTime.now();
    final period = greetingPeriod(now);

    // Extract first name: first word of fullName → first word of displayName.
    String? firstName;
    final full = auth.fullName?.trim();
    if (full != null && full.isNotEmpty) {
      firstName = full.split(RegExp(r'\s+')).first;
    } else {
      // displayName never throws — use it as fallback.
      final dn = auth.displayName.trim();
      if (dn != 'Oleena Member') {
        firstName = dn.split(RegExp(r'\s+')).first;
      }
    }

    final greetingText = firstName != null && firstName.isNotEmpty
        ? 'Good $period, $firstName'
        : 'Good $period';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Robot avatar circle.
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: OleenaTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),

            // Playfair Display greeting headline.
            Text(
              greetingText,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: OleenaTheme.textDark,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Poppins subtitle.
            Text(
              'How can I help plan your wedding today?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: OleenaTheme.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
