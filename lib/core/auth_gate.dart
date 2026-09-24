import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'theme.dart';

/// Action-based Auth Gate helper function.
///
/// Verifies if the user is currently authenticated:
/// • If authenticated: Immediately executes [onSuccess].
/// • If guest: Displays an elegant, non-blocking modal bottom sheet prompting the user
///   to Sign In or Register. Never locks the whole app or screen.
Future<void> requireLogin(
  BuildContext context, {
  required VoidCallback onSuccess,
  String reason = 'Sign in to access this feature',
  IconData icon = Icons.lock_outline_rounded,
}) async {
  final authProvider = context.read<AuthProvider>();

  // If already authenticated, proceed immediately with the protected action
  if (authProvider.isAuthenticated) {
    onSuccess();
    return;
  }

  // Otherwise, present the action-based bottom sheet
  final bool? didAuthenticate = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _AuthGateBottomSheet(
      reason: reason,
      icon: icon,
    ),
  );

  // If the user signed in, execute the queued action
  if (didAuthenticate == true && context.mounted) {
    onSuccess();
  }
}

/// Static helper wrapper for object-oriented invocation: `AuthGate.requireLogin(...)`.
class AuthGate {
  AuthGate._();

  static Future<void> requireLogin(
    BuildContext context, {
    required VoidCallback onSuccess,
    String reason = 'Sign in to access this feature',
    IconData icon = Icons.lock_outline_rounded,
  }) =>
      requireLogin(
        context,
        onSuccess: onSuccess,
        reason: reason,
        icon: icon,
      );
}

class _AuthGateBottomSheet extends StatelessWidget {
  final String reason;
  final IconData icon;

  const _AuthGateBottomSheet({
    required this.reason,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Brand Icon Badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: OleenaTheme.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: OleenaTheme.primary,
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            'Account Required',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: OleenaTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Reason text
          Text(
            reason,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: OleenaTheme.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final result = await context.push('/login');
                if (result == true && context.mounted) {
                  // User logged in successfully
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OleenaTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Register Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/register');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: OleenaTheme.primary,
                side: const BorderSide(color: OleenaTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Create an Account',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Continue as Guest button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Continue as Guest',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
