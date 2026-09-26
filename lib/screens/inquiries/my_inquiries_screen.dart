import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_service.dart';
import '../../core/auth_gate.dart';
import '../../core/auth_provider.dart';
import '../../core/inquiry_api_service.dart';
import '../../core/theme.dart';
import '../../models/inquiry_model.dart';
import 'inquiry_detail_screen.dart';

/// Screen displaying the list of all inquiries sent by the customer.
class MyInquiriesScreen extends StatefulWidget {
  final VoidCallback? onExploreTap;

  const MyInquiriesScreen({super.key, this.onExploreTap});

  @override
  State<MyInquiriesScreen> createState() => _MyInquiriesScreenState();
}

class _MyInquiriesScreenState extends State<MyInquiriesScreen> {
  final InquiryApiService _apiService = InquiryApiService();
  List<Inquiry> _inquiries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoad();
    });
  }

  void _checkAuthAndLoad() {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      _fetchInquiries();
    } else {
      setState(() {
        _isLoading = false;
        _inquiries = [];
      });
    }
  }

  Future<void> _fetchInquiries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getMyInquiries();
      if (mounted) {
        setState(() {
          _inquiries = list;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load inquiries: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToExplore() {
    if (widget.onExploreTap != null) {
      widget.onExploreTap!();
    } else {
      context.go('/explore');
    }
  }

  Future<void> _navigateToDetail(Inquiry inquiry) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InquiryDetailScreen(inquiry: inquiry),
      ),
    );
    if (result == true && mounted) {
      _fetchInquiries();
    }
  }

  Future<void> _confirmDeleteInquiry(Inquiry inquiry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Inquiry?',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: OleenaTheme.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to remove your inquiry sent to ${inquiry.vendorName}? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13, color: OleenaTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: OleenaTheme.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _apiService.deleteInquiry(inquiry.inquiryId);
        setState(() {
          _inquiries.removeWhere((i) => i.inquiryId == inquiry.inquiryId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inquiry to ${inquiry.vendorName} removed successfully.'),
              backgroundColor: OleenaTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not delete inquiry: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _showEditInquiryModal(Inquiry inquiry) {
    DateTime? editDate = inquiry.weddingDate;
    final guestCtrl = TextEditingController(text: inquiry.guestCount?.toString() ?? '');
    final budgetCtrl = TextEditingController(
        text: inquiry.budget != null ? inquiry.budget!.toStringAsFixed(0) : '');
    final msgCtrl = TextEditingController(text: inquiry.message ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Inquiry',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: OleenaTheme.textDark,
                                ),
                              ),
                              Text(
                                inquiry.vendorName,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: OleenaTheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: OleenaTheme.textMuted),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Date Picker
                      Text(
                        'Wedding / Event Date',
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w600, color: OleenaTheme.textDark),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: editDate ?? now.add(const Duration(days: 30)),
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 365 * 3)),
                          );
                          if (picked != null) {
                            setModalState(() => editDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: OleenaTheme.primary),
                              const SizedBox(width: 10),
                              Text(
                                editDate != null
                                    ? '${editDate!.year}-${editDate!.month.toString().padLeft(2, '0')}-${editDate!.day.toString().padLeft(2, '0')}'
                                    : 'Select Date',
                                style: GoogleFonts.poppins(fontSize: 13, color: OleenaTheme.textDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Guest Count & Budget
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Guests',
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: guestCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    hintText: 'e.g. 200',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Budget (LKR)',
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: budgetCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    hintText: 'e.g. 450000',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Message
                      Text('Message', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: msgCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          hintText: 'Update your requirements...',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Save Button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  setModalState(() => isSaving = true);
                                  try {
                                    final guests = int.tryParse(guestCtrl.text.trim());
                                    final budget =
                                        double.tryParse(budgetCtrl.text.replaceAll(',', '').trim());
                                    await _apiService.updateInquiry(
                                      inquiryId: inquiry.inquiryId,
                                      weddingDate: editDate,
                                      guestCount: guests,
                                      budget: budget,
                                      message: msgCtrl.text.trim(),
                                    );
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                    _fetchInquiries();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Inquiry updated successfully.'),
                                          backgroundColor: OleenaTheme.primary,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setModalState(() => isSaving = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text('Update failed: $e'),
                                            backgroundColor: Colors.redAccent),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OleenaTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text('Save Changes',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      appBar: AppBar(
        title: Text(
          'My Inquiries',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: OleenaTheme.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          if (isAuthenticated)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: OleenaTheme.primary),
              tooltip: 'Refresh inquiries',
              onPressed: _fetchInquiries,
            ),
        ],
      ),
      body: SafeArea(
        child: !isAuthenticated
            ? _buildGuestView(context)
            : _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: OleenaTheme.primary,
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorView()
                    : _inquiries.isEmpty
                        ? _buildEmptyView()
                        : RefreshIndicator(
                            color: OleenaTheme.primary,
                            onRefresh: _fetchInquiries,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              itemCount: _inquiries.length,
                              itemBuilder: (ctx, index) {
                                final inquiry = _inquiries[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildInquiryCard(inquiry),
                                );
                              },
                            ),
                          ),
      ),
    );
  }

  Widget _buildInquiryCard(Inquiry inquiry) {
    final isPending = inquiry.isPending;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(inquiry),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Vendor/Listing Name + Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: OleenaTheme.primaryTint,
                        child: inquiry.vendorImage != null && inquiry.vendorImage!.isNotEmpty
                            ? Image.network(
                                inquiry.vendorImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.storefront_rounded,
                                        color: OleenaTheme.primary, size: 24),
                              )
                            : const Icon(Icons.storefront_rounded,
                                color: OleenaTheme.primary, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Vendor & Service Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inquiry.vendorName,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: OleenaTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (inquiry.serviceName != null && inquiry.serviceName!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              inquiry.serviceName!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: OleenaTheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.event_outlined, size: 13, color: OleenaTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Wedding Date: ${inquiry.formattedWeddingDate}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: OleenaTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status Badge (Pending ⏳ or Replied ✅)
                    _buildStatusBadge(inquiry.status),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0EAE1)),
                const SizedBox(height: 10),

                // Preview Info Row: Tap to view details hint & Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tap to view details',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: OleenaTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 10, color: OleenaTheme.primary),
                      ],
                    ),

                    // Action buttons (Pending: Edit & Delete; Replied: Delete)
                    Row(
                      children: [
                        if (isPending) ...[
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: OleenaTheme.primary),
                            tooltip: 'Edit Inquiry',
                            onPressed: () => _showEditInquiryModal(inquiry),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: Color(0xFFE53935)),
                          tooltip: 'Delete Inquiry',
                          onPressed: () => _confirmDeleteInquiry(inquiry),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Conditionally builds the status badge:
  /// • "Pending" (⏳)
  /// • "Replied" (✅)
  Widget _buildStatusBadge(String status) {
    final isReplied = status.toLowerCase() == 'replied';
    final isPending = status.toLowerCase() == 'pending';

    final bg = isReplied
        ? const Color(0xFFE8F5E9)
        : isPending
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFE3F2FD);
    final fg = isReplied
        ? const Color(0xFF2E7D32)
        : isPending
            ? const Color(0xFFF57F17)
            : const Color(0xFF1565C0);
    final emoji = isReplied ? '✅' : (isPending ? '⏳' : 'ℹ️');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: OleenaTheme.primaryTint,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 46,
                  color: OleenaTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Inquiries Yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: OleenaTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Browse verified wedding venues, photographers, and caterers, then send them your vision and questions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: OleenaTheme.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _navigateToExplore,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text(
                  'Explore Wedding Vendors',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OleenaTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Could not load inquiries',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: OleenaTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred while fetching your inquiries.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: OleenaTheme.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchInquiries,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OleenaTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: OleenaTheme.primaryTint,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: OleenaTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sign In to View Inquiries',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: OleenaTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Track vendor responses, event dates, and budget details in real-time from your account.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: OleenaTheme.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => requireLogin(
                  context,
                  reason: 'Sign in to access your wedding inquiries',
                  onSuccess: _fetchInquiries,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OleenaTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  'Sign In / Register',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
