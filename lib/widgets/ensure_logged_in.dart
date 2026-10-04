import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/auth_coordinator.dart';
import '../core/auth_provider.dart';
import '../core/theme.dart';

enum _AuthGateChoice { login, register, cancel }

/// Ensures the user is logged in before proceeding with a protected customer action.
///
/// • If authenticated: returns `true` immediately without displaying any UI.
/// • If guest: displays an alert dialog prompting the user to Login or Register,
///   with a "Not now" option to cancel. Returns `true` if authentication succeeded,
///   or `false` if dismissed.
Future<bool> ensureLoggedIn(
  BuildContext context, {
  required String message,
}) async {
  final authProvider = Provider.of<AuthProvider?>(context, listen: false);
  if (authProvider?.isAuthenticated == true) {
    return true;
  }

  final choice = await showDialog<_AuthGateChoice>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: OleenaTheme.primaryTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: OleenaTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Account Required',
              style: GoogleFonts.playfairDisplay(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: OleenaTheme.textDark,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          color: OleenaTheme.textMuted,
          height: 1.5,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(_AuthGateChoice.cancel),
          child: Text(
            'Not now',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OleenaTheme.textMuted,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(dialogContext).pop(_AuthGateChoice.register),
          style: OutlinedButton.styleFrom(
            foregroundColor: OleenaTheme.primary,
            side: const BorderSide(color: OleenaTheme.primary, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          child: Text(
            'Register',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(_AuthGateChoice.login),
          style: ElevatedButton.styleFrom(
            backgroundColor: OleenaTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'Login',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  if (choice == _AuthGateChoice.login && context.mounted) {
    return await AuthCoordinator.startFlow(context, isRegister: false);
  } else if (choice == _AuthGateChoice.register && context.mounted) {
    return await AuthCoordinator.startFlow(context, isRegister: true);
  }

  return false;
}
