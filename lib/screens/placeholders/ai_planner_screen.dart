import 'package:flutter/material.dart';
import 'placeholder_body.dart';

/// Placeholder screen for Member 3 – AI Orchestrator / Planner.
class AiPlannerScreen extends StatelessWidget {
  const AiPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF5F9),
      body: PlaceholderBody(
        icon: Icons.auto_awesome_rounded,
        title: 'AI Planner',
        subtitle:
            'Member 3 is building this section.\nYour AI wedding assistant will be available here.',
        badge: 'AI POWERED',
      ),
    );
  }
}
