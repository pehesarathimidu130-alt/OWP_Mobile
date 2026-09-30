import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/inquiry_api_service.dart';
import '../../core/theme.dart';
import '../../models/inquiry_model.dart';

/// Screen displaying the complete details of an inquiry sent by the customer.
class InquiryDetailScreen extends StatefulWidget {
  final Inquiry inquiry;

  const InquiryDetailScreen({super.key, required this.inquiry});

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  late Inquiry _inquiry;
  final InquiryApiService _apiService = InquiryApiService();

  @override
  void initState() {
    super.initState();
    _inquiry = widget.inquiry;
  }

  Future<void> _deleteInquiry() async {
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
          'Are you sure you want to permanently delete this inquiry to ${_inquiry.vendorName}?',
          style: GoogleFonts.poppins(fontSize: 13, color: OleenaTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: OleenaTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _apiService.deleteInquiry(_inquiry.inquiryId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inquiry to ${_inquiry.vendorName} deleted.'),
              backgroundColor: OleenaTheme.primary,
            ),
          );
          Navigator.pop(context, true); // Pop back with delete indicator
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

  void _showEditSheet() {
    DateTime? editDate = _inquiry.weddingDate;
    final guestCtrl = TextEditingController(text: _inquiry.guestCount?.toString() ?? '');
    final budgetCtrl = TextEditingController(
        text: _inquiry.budget != null ? _inquiry.budget!.toStringAsFixed(0) : '');
    final msgCtrl = TextEditingController(text: _inquiry.message ?? '');
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
                          Text(
                            'Edit Inquiry Details',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: OleenaTheme.textDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Date
                      Text('Wedding / Event Date', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
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
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Guests & Budget
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Guests', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: guestCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                Text('Budget (LKR)', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: budgetCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  setModalState(() => isSaving = true);
                                  try {
                                    final guests = int.tryParse(guestCtrl.text.trim());
                                    final budget = double.tryParse(budgetCtrl.text.replaceAll(',', '').trim());
                                    await _apiService.updateInquiry(
                                      inquiryId: _inquiry.inquiryId,
                                      weddingDate: editDate,
                                      guestCount: guests,
                                      budget: budget,
                                      message: msgCtrl.text.trim(),
                                    );
                                    setState(() {
                                      _inquiry = Inquiry(
                                        inquiryId: _inquiry.inquiryId,
                                        vendorId: _inquiry.vendorId,
                                        vendorName: _inquiry.vendorName,
                                        vendorImage: _inquiry.vendorImage,
                                        serviceId: _inquiry.serviceId,
                                        serviceName: _inquiry.serviceName,
                                        weddingDate: editDate,
                                        guestCount: guests,
                                        budget: budget,
                                        message: msgCtrl.text.trim(),
                                        attachmentUrl: _inquiry.attachmentUrl,
                                        status: _inquiry.status,
                                        createdAt: _inquiry.createdAt,
                                      );
                                    });
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
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
                                        SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.redAccent),
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
                              : Text('Save Changes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
    final isPending = _inquiry.isPending;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      appBar: AppBar(
        title: Text(
          'Inquiry Details',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: OleenaTheme.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: OleenaTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935)),
            tooltip: 'Delete Inquiry',
            onPressed: _deleteInquiry,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Card ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: OleenaTheme.primaryTint,
                            child: _inquiry.vendorImage != null && _inquiry.vendorImage!.isNotEmpty
                                ? Image.network(
                                    _inquiry.vendorImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.storefront_rounded, color: OleenaTheme.primary, size: 28),
                                  )
                                : const Icon(Icons.storefront_rounded, color: OleenaTheme.primary, size: 28),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _inquiry.vendorName,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: OleenaTheme.textDark,
                                ),
                              ),
                              if (_inquiry.serviceName != null && _inquiry.serviceName!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _inquiry.serviceName!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: OleenaTheme.primary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Inquiry #${_inquiry.inquiryId} • Sent ${_inquiry.formattedCreatedDate}',
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Status',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: OleenaTheme.textMuted),
                        ),
                        _buildStatusBadge(_inquiry.status),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Structured Event Parameters ────────────────────────
              Text(
                'Event Requirements',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OleenaTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.event_available_rounded,
                      'Wedding / Event Date',
                      _inquiry.formattedWeddingDate,
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      Icons.people_alt_outlined,
                      'Expected Guests',
                      _inquiry.guestCount != null && _inquiry.guestCount! > 0
                          ? '${_inquiry.guestCount} guests'
                          : 'Not specified',
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      Icons.payments_outlined,
                      'Target Budget',
                      _inquiry.formattedBudget,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Message Card ───────────────────────────────────────
              Text(
                'Message',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OleenaTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _inquiry.message != null && _inquiry.message!.isNotEmpty
                      ? _inquiry.message!
                      : 'No message provided.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: OleenaTheme.textDark,
                    height: 1.6,
                  ),
                ),
              ),

              // ── Inspiration Attachment ─────────────────────────────
              if (_inquiry.attachmentUrl != null && _inquiry.attachmentUrl!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Attached Inspiration Photo',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: OleenaTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: OleenaTheme.primaryTint,
                    child: Image.network(
                      _inquiry.attachmentUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          'Attachment preview unavailable',
                          style: GoogleFonts.poppins(fontSize: 12, color: OleenaTheme.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Action Buttons ─────────────────────────────────────
              if (isPending)
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _showEditSheet,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      'Edit Inquiry Requirements',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OleenaTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: OleenaTheme.primaryTint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: OleenaTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, color: OleenaTheme.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: OleenaTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
