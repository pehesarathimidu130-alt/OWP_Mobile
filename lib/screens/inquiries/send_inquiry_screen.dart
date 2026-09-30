import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_service.dart';
import '../../core/theme.dart';
import '../../models/listing_model.dart';
import '../../models/vendor_model.dart';

/// Form screen for creating and submitting a structured inquiry to a wedding vendor.
class SendInquiryScreen extends StatefulWidget {
  final Listing? listing;
  final Vendor? vendor;
  final int? vendorId;
  final int? serviceId;
  final String? vendorName;
  final String? serviceTitle;
  final String? coverImageUrl;

  const SendInquiryScreen({
    super.key,
    this.listing,
    this.vendor,
    this.vendorId,
    this.serviceId,
    this.vendorName,
    this.serviceTitle,
    this.coverImageUrl,
  });

  @override
  State<SendInquiryScreen> createState() => _SendInquiryScreenState();
}

class _SendInquiryScreenState extends State<SendInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  DateTime? _selectedDate;
  final TextEditingController _guestCountController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isSubmitting = false;

  int get _targetVendorId {
    if (widget.vendorId != null && widget.vendorId! > 0) return widget.vendorId!;
    if (widget.listing != null && widget.listing!.vendor.id.isNotEmpty) {
      final parsed = int.tryParse(widget.listing!.vendor.id);
      if (parsed != null && parsed > 0) return parsed;
    }
    if (widget.vendor != null && widget.vendor!.id.isNotEmpty) {
      final parsed = int.tryParse(widget.vendor!.id);
      if (parsed != null && parsed > 0) return parsed;
    }
    return 0;
  }

  int? get _targetServiceId {
    if (widget.serviceId != null && widget.serviceId! > 0) return widget.serviceId;
    if (widget.listing != null && widget.listing!.serviceId > 0) return widget.listing!.serviceId;
    return null;
  }

  String get _displayVendorName {
    if (widget.vendorName != null && widget.vendorName!.isNotEmpty) return widget.vendorName!;
    if (widget.listing != null && widget.listing!.vendor.name.isNotEmpty) return widget.listing!.vendor.name;
    if (widget.vendor != null && widget.vendor!.name.isNotEmpty) return widget.vendor!.name;
    return 'Wedding Vendor';
  }

  String? get _displayServiceTitle {
    if (widget.serviceTitle != null && widget.serviceTitle!.isNotEmpty) return widget.serviceTitle!;
    if (widget.listing != null && widget.listing!.title.isNotEmpty) return widget.listing!.title;
    return null;
  }

  String? get _displayCoverImage {
    if (widget.coverImageUrl != null && widget.coverImageUrl!.isNotEmpty) return widget.coverImageUrl!;
    if (widget.listing != null && widget.listing!.coverImageUrl.isNotEmpty) return widget.listing!.coverImageUrl;
    if (widget.vendor != null && widget.vendor!.coverImageUrl != null && widget.vendor!.coverImageUrl!.isNotEmpty) {
      return widget.vendor!.coverImageUrl;
    }
    return null;
  }

  @override
  void dispose() {
    _guestCountController.dispose();
    _budgetController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now.add(const Duration(days: 60));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 4)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: OleenaTheme.primary,
              onPrimary: Colors.white,
              onSurface: OleenaTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Attach Inspiration Photo',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OleenaTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: OleenaTheme.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: OleenaTheme.primary),
                ),
                title: Text('Take Photo with Camera', style: GoogleFonts.poppins(fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: OleenaTheme.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: OleenaTheme.primary),
                ),
                title: Text('Choose from Photo Gallery', style: GoogleFonts.poppins(fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your preferred wedding date.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final guestCount = int.tryParse(_guestCountController.text.trim());
      final budget = double.tryParse(_budgetController.text.replaceAll(',', '').trim());

      await _apiService.submitInquiry(
        vendorId: _targetVendorId,
        serviceId: _targetServiceId,
        weddingDate: _selectedDate,
        guestCount: guestCount,
        budget: budget,
        message: _messageController.text.trim(),
        photoAttachment: _selectedImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Inquiry sent successfully to $_displayVendorName!',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit inquiry: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      appBar: AppBar(
        title: Text(
          'Send Inquiry',
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
          icon: const Icon(Icons.close_rounded, color: OleenaTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Vendor / Service Header Card ─────────────────────────────
                _buildHeaderCard(),
                const SizedBox(height: 24),

                // ── 1. Wedding Date Picker ───────────────────────────────────
                _buildSectionLabel('Wedding / Event Date', Icons.calendar_month_rounded),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedDate == null ? const Color(0xFFE5E7EB) : OleenaTheme.primary,
                        width: _selectedDate == null ? 1 : 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          color: _selectedDate == null ? Colors.grey : OleenaTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Tap to select your wedding date'
                                : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: _selectedDate == null ? FontWeight.w400 : FontWeight.w600,
                              color: _selectedDate == null ? Colors.grey.shade500 : OleenaTheme.textDark,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── 2. Guest Count & 3. Budget Row ───────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guest Count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('Guest Count', Icons.people_outline_rounded),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _guestCountController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: _inputDecoration(
                              hintText: 'e.g. 150',
                              prefixIcon: Icons.people_alt_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Required';
                              }
                              final num = int.tryParse(val.trim());
                              if (num == null || num <= 0) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Budget
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('Budget (LKR)', Icons.payments_outlined),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: _inputDecoration(
                              hintText: 'e.g. 250,000',
                              prefixText: 'LKR ',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Required';
                              }
                              final num = double.tryParse(val.replaceAll(',', '').trim());
                              if (num == null || num <= 0) {
                                return 'Invalid budget';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── 4. Message (Multiline) ───────────────────────────────────
                _buildSectionLabel('Message to Vendor', Icons.chat_bubble_outline_rounded),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 3,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _inputDecoration(
                    hintText: 'Tell the vendor about your wedding theme, schedule, specific package requirements, or any questions...',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please provide a message for the vendor.';
                    }
                    if (val.trim().length < 10) {
                      return 'Please provide at least 10 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── 5. Photo Attachment (Device Feature via ImagePicker) ─────
                _buildSectionLabel('Inspiration Photo (Optional)', Icons.add_photo_alternate_outlined),
                const SizedBox(height: 8),
                _buildPhotoAttachmentArea(),
                const SizedBox(height: 32),

                // ── 6. Submit Inquiry Button ─────────────────────────────────
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OleenaTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: OleenaTheme.primary.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Submit Inquiry',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: OleenaTheme.primaryTint,
            ),
            clipBehavior: Clip.antiAlias,
            child: _displayCoverImage != null
                ? Image.network(
                    _displayCoverImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.storefront_rounded, color: OleenaTheme.primary),
                  )
                : const Icon(Icons.storefront_rounded, color: OleenaTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_displayServiceTitle != null) ...[
                  Text(
                    _displayServiceTitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: OleenaTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  _displayVendorName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: OleenaTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Typically responds within 24 hours',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: OleenaTheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OleenaTheme.textDark,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? prefixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey, size: 18) : null,
      prefixText: prefixText,
      prefixStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: OleenaTheme.textDark),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: OleenaTheme.primary, width: 1.5),
      ),
    );
  }

  Widget _buildPhotoAttachmentArea() {
    if (_selectedImageBytes != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OleenaTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                _selectedImageBytes!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedImage?.name ?? 'Photo attached',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: OleenaTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Tap X to remove',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: OleenaTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.cancel_rounded, color: Colors.red),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _selectedImageBytes = null;
                });
              },
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: OleenaTheme.primaryTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: OleenaTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attach Inspiration Photo',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: OleenaTheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Camera or Gallery (JPG, PNG)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
