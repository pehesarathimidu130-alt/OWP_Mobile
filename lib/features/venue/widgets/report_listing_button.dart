import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api_service.dart';
import '../../../core/auth_gate.dart';
import '../../../core/auth_provider.dart';
import '../../../core/theme.dart';

/// A button at the bottom of ListingDetailsScreen that allows a logged-in customer
/// to report / flag a listing.
///
/// On mount it calls GET /api/flags/check to determine if the user has already
/// reported this listing and renders the appropriate state:
///   • Not reported → grey "Report this listing" button (opens bottom sheet)
///   • Already reported → disabled filled-flag button ("You have reported this item")
///
/// On sheet submission it calls POST /api/flags and on success instantly
/// transitions the button to the "already reported" state.
class ReportListingButton extends StatefulWidget {
  final int listingId;
  final int vendorId;
  final String listingTitle;

  const ReportListingButton({
    super.key,
    required this.listingId,
    required this.vendorId,
    required this.listingTitle,
  });

  @override
  State<ReportListingButton> createState() => _ReportListingButtonState();
}

class _ReportListingButtonState extends State<ReportListingButton> {
  bool _hasReported = false;
  bool _isChecking = true; // true while the API check is in flight

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyReported();
  }

  Future<void> _checkIfAlreadyReported() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.customerId == null) {
      if (mounted) setState(() => _isChecking = false);
      return;
    }
    try {
      final reported = await ApiService().checkIfReported(
        listingId: widget.listingId,
        userId: auth.customerId!,
      );
      if (mounted) {
        setState(() {
          _hasReported = reported;
          _isChecking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _onButtonTapped() {
    requireLogin(
      context,
      reason: 'Sign in to report this listing',
      icon: Icons.flag_outlined,
      onSuccess: () => _showReportSheet(context),
    );
  }

  void _showReportSheet(BuildContext context) {
    final auth = context.read<AuthProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportBottomSheet(
        listingId: widget.listingId,
        vendorId: widget.vendorId,
        listingTitle: widget.listingTitle,
        reporterUserId: auth.customerId ?? 0,
        onSuccess: () {
          if (mounted) setState(() => _hasReported = true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const SizedBox(height: 48);
    }

    if (_hasReported) {
      // ── Already Reported State ─────────────────────────────
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
        child: Center(
          child: TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.flag, color: Colors.grey, size: 20),
            label: const Text(
              'Already reported',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      );
    }

    // ── Default State ──────────────────────────────────────
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      child: Center(
        child: TextButton.icon(
          onPressed: _onButtonTapped,
          icon: const Icon(Icons.flag_outlined, color: Colors.grey, size: 20),
          label: const Text(
            'Report this listing',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ReportBottomSheet extends StatefulWidget {
  final int listingId;
  final int vendorId;
  final String listingTitle;
  final int reporterUserId;
  final VoidCallback onSuccess;

  const _ReportBottomSheet({
    required this.listingId,
    required this.vendorId,
    required this.listingTitle,
    required this.reporterUserId,
    required this.onSuccess,
  });

  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  String? _selectedReason;
  final TextEditingController _commentsController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Abusive language',
    'Misleading price and photos',
    'Fake photos',
    'Duplicate listing',
    'Off-platform solicitation',
  ];

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null || widget.reporterUserId == 0) return;
    setState(() => _isSubmitting = true);

    try {
      await ApiService().submitFlag(
        listingId: widget.listingId,
        reporterUserId: widget.reporterUserId,
        vendorId: widget.vendorId,
        contentTitle: widget.listingTitle,
        reason: _selectedReason!,
        comments: _commentsController.text.trim().isEmpty
            ? null
            : _commentsController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report submitted for review. Thank you for your feedback.'),
          backgroundColor: OleenaTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      // 409 = already reported (race condition)
      if (e.statusCode == 409) {
        Navigator.of(context).pop();
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already reported this listing.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: ${e.message}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit report. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sheet handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Why are you reporting this listing?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Your report is confidential and helps keep our platform safe.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ..._reasons.map((reason) {
            return RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: _selectedReason,
              activeColor: OleenaTheme.primary,
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedReason = value),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            );
          }),
          const SizedBox(height: 16),
          TextField(
            controller: _commentsController,
            maxLines: 3,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: 'Additional comments (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: OleenaTheme.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: (_selectedReason != null && !_isSubmitting)
                ? _submitReport
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: OleenaTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Submit Report', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
