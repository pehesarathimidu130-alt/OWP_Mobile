import 'package:flutter/material.dart';
import 'placeholder_body.dart';

/// Placeholder screen for Member 4 – Wedding Tracker.
class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF5F9),
      body: PlaceholderBody(
        icon: Icons.checklist_rounded,
        title: 'My Wedding',
        subtitle:
            'Member 4 is building this section.\nTrack your wedding checklist, budget & timeline here.',
        badge: 'TRACKER',
      ),
    );
  }
}
