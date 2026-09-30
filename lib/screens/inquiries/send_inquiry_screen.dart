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
  final String? category;

  const SendInquiryScreen({
    super.key,
    this.listing,
    this.vendor,
    this.vendorId,
    this.serviceId,
    this.vendorName,
    this.serviceTitle,
    this.coverImageUrl,
    this.category,
  });

  @override
  State<SendInquiryScreen> createState() => _SendInquiryScreenState();
}

class _SendInquiryScreenState extends State<SendInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  DateTime? _selectedDate;
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _guestCountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isSubmitting = false;

  // ── Category helpers ─────────────────────────────────────────────────────
  // Uses the same keyword matching as ExploreScreen._categories chips and
  // Listing._resolveCategoryIcon so category identification is consistent.
  static bool _isVenueOrHotel(String? cat) {
    if (cat == null) return false;
    final c = cat.toLowerCase();
    return c.contains('venue') || c.contains('hotel');
  }

  static bool _isCatering(String? cat) {
    if (cat == null) return false;
    final c = cat.toLowerCase();
    return c.contains('cater') || c.contains('food');
  }

  /// Guest count field is shown only for Hotel/Venue and Catering.
  bool get _showGuestCount =>
      _isVenueOrHotel(_displayCategory) || _isCatering(_displayCategory);

  /// Category-specific hint for the message field.
  String get _messageHint {
    final cat = _displayCategory?.toLowerCase() ?? '';
    if (cat.contains('venue') || cat.contains('hotel')) {
      return 'Tell the vendor about your event type, expected guests and preferred dates.';
    }
    if (cat.contains('cater') || cat.contains('food')) {
      return 'Tell the vendor about guest count, cuisine preferences and dietary needs.';
    }
    if (cat.contains('photo') || cat.contains('video')) {
      return 'Tell the vendor about the event, coverage hours and the style you like.';
    }
    if (cat.contains('decor') || cat.contains('flower') || cat.contains('flora')) {
      return 'Tell the vendor about the venue, theme and colour palette.';
    }
    if (cat.contains('music') || cat.contains('dj') || cat.contains('band')) {
      return 'Tell the vendor about the venue, event timing and the style of music you want.';
    }
    return 'Tell the vendor about your event, schedule, package requirements, or any questions...';
  }

  int get _targetVendorId {
    if (widget.vendorId != null && widget.vendorId! > 0) return widget.vendorId!;
    if (widget.listing != null && widget.listing!.vendor.vendorId > 0) {
      return widget.listing!.vendor.vendorId;
    }
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

  String get _displayServiceTitle {
    if (widget.serviceTitle != null && widget.serviceTitle!.isNotEmpty) return widget.serviceTitle!;
    if (widget.listing != null && widget.listing!.title.isNotEmpty) return widget.listing!.title;
    return 'General Service Inquiry';
  }

  String? get _displayCategory {
    if (widget.category != null && widget.category!.isNotEmpty) return widget.category;
    if (widget.listing != null && widget.listing!.category.isNotEmpty) return widget.listing!.category;
    if (widget.vendor != null && widget.vendor!.category.isNotEmpty) {
      return widget.vendor!.category;
    }
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
    _budgetController.dispose();
    _guestCountController.dispose();
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

    setState(() => _isSubmitting = true);

    try {
      final budgetText = _budgetController.text.replaceAll(',', '').trim();
      final budget = budgetText.isNotEmpty ? double.tryParse(budgetText) : null;

      final guestCount = _showGuestCount
          ? int.tryParse(_guestCountController.text.trim())
          : null;

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
                // ── Listing Title, Vendor Name & Category Pill at Top ─────────
                _buildHeaderCard(),
                const SizedBox(height: 24),

                // ── 1. Preferred Event Date (Optional) ───────────────────────
                _buildSectionLabel('Preferred Event Date (Optional)', Icons.calendar_month_rounded),
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
                                ? 'Flexible / Date not decided yet'
                                : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: _selectedDate == null ? FontWeight.w400 : FontWeight.w600,
                              color: _selectedDate == null ? Colors.grey.shade500 : OleenaTheme.textDark,
                            ),
                          ),
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                            onPressed: () => setState(() => _selectedDate = null),
                            visualDensity: VisualDensity.compact,
                          )
                        else
                          const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── 2. Budget (Optional) ─────────────────────────────────────
                _buildSectionLabel('Budget (LKR), optional', Icons.payments_outlined),
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
                      return null; // Optional
                    }
                    final num = double.tryParse(val.replaceAll(',', '').trim());
                    if (num == null || num <= 0) {
                      return 'Please enter a valid positive budget amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── 3. Guest Count (Optional – Hotel/Venue and Catering only) ──
                // Shown only when category is Hotel/Venue or Catering, matching
                // the same keyword rules as ExploreScreen._categories chips.
                if (_showGuestCount) ...[
                  _buildSectionLabel('Expected Guests (optional)', Icons.people_alt_outlined),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _guestCountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: _inputDecoration(
                      hintText: 'e.g. 200',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return null; // Optional
                      final n = int.tryParse(val.trim());
                      if (n == null || n <= 0) {
                        return 'Please enter a valid positive number.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // ── 4. Message (Required, 500-char counter, category-specific hint) ──
                _buildSectionLabel('Message to Vendor', Icons.chat_bubble_outline_rounded),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLength: 500,
                  maxLines: 5,
                  minLines: 3,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _inputDecoration(
                    hintText: _messageHint,
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
                const SizedBox(height: 12),

                // ── 5. Inspiration Photo (Optional) ──────────────────────────
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
    final resolvedImage = _displayCoverImage != null
        ? Listing.resolveImageUrl(_displayCoverImage)
        : null;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: OleenaTheme.primaryTint,
            ),
            clipBehavior: Clip.antiAlias,
            child: resolvedImage != null
                ? Image.network(
                    resolvedImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.storefront_rounded, color: OleenaTheme.primary),
                  )
                : const Icon(Icons.storefront_rounded, color: OleenaTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),

          // Listing Title, Vendor Name, Category Pill
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing Title
                Text(
                  _displayServiceTitle,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: OleenaTheme.textDark,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Vendor Name
                Text(
                  _displayVendorName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: OleenaTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Category Pill
                if (_displayCategory != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: OleenaTheme.primaryTint,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: OleenaTheme.primary.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      _displayCategory!.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: OleenaTheme.primary,
                        letterSpacing: 0.5,
                      ),
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
