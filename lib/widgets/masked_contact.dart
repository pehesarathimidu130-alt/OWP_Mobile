import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/auth_provider.dart';
import 'ensure_logged_in.dart';

/// Widget for displaying masked vendor contact information (phone, email, website).
///
/// Masks with '****' when:
/// • The user is a guest (unauthenticated) OR
/// • The API response indicates [contactHidden] is true OR
/// • The real value is not yet loaded / null.
///
/// Shows real value only when authenticated AND a non-empty value exists AND not hidden.
/// Tapping a masked contact prompts the login-required dialog.
class MaskedContact extends StatelessWidget {
  final String? value;
  final bool contactHidden;
  final TextStyle? style;
  final String message;
  final VoidCallback? onAuthSuccess;

  const MaskedContact({
    super.key,
    required this.value,
    this.contactHidden = false,
    this.style,
    this.message = 'You need to register or log in to view this.',
    this.onAuthSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider?>(context, listen: true);
    final isAuthenticated = authProvider?.isAuthenticated ?? false;
    final hasRealValue = value != null && value!.trim().isNotEmpty;

    // Mask when unauthenticated OR API says contactHidden OR no real value present
    final bool shouldMask = !isAuthenticated || contactHidden || !hasRealValue;

    if (!shouldMask) {
      return Text(
        value!.trim(),
        style: style ??
            GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
      );
    }

    return InkWell(
      onTap: () async {
        if (!isAuthenticated) {
          final ok = await ensureLoggedIn(
            context,
            message: message,
          );
          if (ok && context.mounted) {
            onAuthSuccess?.call();
          }
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Text(
        '****',
        style: (style ??
                GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ))
            .copyWith(letterSpacing: 2.0),
      ),
    );
  }
}
