import 'dart:math' as math;
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
/// a randomly selected Poppins sub-heading prompting the user to start chatting.
class ChatGreeting extends StatefulWidget {
  const ChatGreeting({super.key});

  @override
  State<ChatGreeting> createState() => _ChatGreetingState();
}

class _ChatGreetingState extends State<ChatGreeting> {
  static const List<String> _alternatePrompts = [
    'How can I help plan your wedding today?',
    "Let's plan it together.",
    'What about your wedding?',
    'Ready to design your dream day?',
    "Let's organise your special day.",
  ];

  late final int _promptIndex;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    // Index 0 means we use the dynamic "Good afternoon, Name" greeting.
    // Indices 1..N correspond to _alternatePrompts.
    _promptIndex = random.nextInt(_alternatePrompts.length + 1);
  }

  @override
  Widget build(BuildContext context) {
    String headlineText;

    if (_promptIndex == 0) {
      // Dynamic time-based greeting.
      final auth = context.watch<AuthProvider>();
      final now = DateTime.now();
      final period = greetingPeriod(now);

      String? firstName;
      final full = auth.fullName?.trim();
      if (full != null && full.isNotEmpty) {
        firstName = full.split(RegExp(r'\s+')).first;
      } else {
        final dn = auth.displayName.trim();
        if (dn != 'Oleena Member') {
          firstName = dn.split(RegExp(r'\s+')).first;
        }
      }

      headlineText = firstName != null && firstName.isNotEmpty
          ? 'Good $period, $firstName'
          : 'Good $period';
    } else {
      // One of the alternate fixed prompts.
      headlineText = _alternatePrompts[_promptIndex - 1];
    }

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
              headlineText,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: OleenaTheme.textDark,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
