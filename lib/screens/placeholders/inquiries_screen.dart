import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'placeholder_body.dart';

/// Placeholder screen for Member 2 – Inquiry Engine.
/// [fromDetails] controls whether an AppBar is shown (navigated from VendorDetailsScreen).
class InquiriesScreen extends StatelessWidget {
  final bool fromDetails;
  const InquiriesScreen({super.key, this.fromDetails = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F9),
      appBar: fromDetails
          ? AppBar(
              title: Text(
                'Send Inquiry',
                style:
                    GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: const PlaceholderBody(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Inquiry Engine',
        subtitle:
            'Member 2 is building this section.\nSend messages and check vendor availability here.',
        badge: 'COMING SOON',
      ),
    );
  }
}
