import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_service.dart';
import '../../core/auth_gate.dart';
import '../../core/theme.dart';
import '../../models/public_vendor_profile.dart';
import '../../models/vendor.dart';
import '../placeholders/inquiries_screen.dart';

/// Full dynamic Vendor Details Screen for Mobile Customers.
/// Displays live vendor business profile details, business hours (open/closed),
/// and past performances (ratings, showcases, client feedback) updated from the web platform.
class VendorDetailsScreen extends StatefulWidget {
  final Vendor vendor;
  final VoidCallback? onFavoriteToggled;

  const VendorDetailsScreen({
    super.key,
    required this.vendor,
    this.onFavoriteToggled,
  });

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  PublicVendorProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  late bool _isFavorite;
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.vendor.isFavorite;

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _heartCtrl,
      curve: Curves.easeInOut,
    ));

    _fetchProfile();
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final vendorId = int.tryParse(widget.vendor.id) ?? 1;

    try {
      final profile = await _apiService.fetchVendorProfile(vendorId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
        _errorMessage = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load vendor profile details: $e';
      });
    }
  }

  void _toggleHeart() {
    requireLogin(
      context,
      reason: 'Sign in to save ${widget.vendor.name} to your favourites',
      icon: Icons.favorite_border_rounded,
      onSuccess: () {
        setState(() => _isFavorite = !_isFavorite);
        _heartCtrl.forward(from: 0);
        widget.onFavoriteToggled?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final imageH = screenH * 0.36;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final vendor = widget.vendor;
    final profile = _profile;

    final coverImg = profile?.coverImageUrl != null && profile!.coverImageUrl!.isNotEmpty
        ? profile.coverImageUrl!
        : vendor.imageUrl;

    final logoImg = profile?.logoUrl ?? vendor.logoUrl;
    final businessName = profile?.businessName ?? vendor.name;
    final category = profile?.category ?? vendor.category;
    final description = (profile?.description != null && profile!.description!.isNotEmpty)
        ? profile.description!
        : vendor.description;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F7),
      body: Stack(
        children: [
          // ── Scrollable Body ───────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner ─────────────────────────────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: imageH,
                      width: double.infinity,
                      child: Image.network(
                        coverImg,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported_outlined,
                              color: Colors.grey, size: 50),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Vendor Logo Avatar Overlapping Banner
                    Positioned(
                      bottom: -28,
                      left: 20,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: logoImg != null && logoImg.isNotEmpty
                            ? Image.network(
                                logoImg,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.storefront_rounded,
                                  color: OleenaTheme.primary,
                                  size: 32,
                                ),
                              )
                            : const Icon(
                                Icons.storefront_rounded,
                                color: OleenaTheme.primary,
                                size: 32,
                              ),
                      ),
                    ),

                    // Category Pill
                    Positioned(
                      bottom: 16,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: OleenaTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ── Main Content Container ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Title & Verified Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              businessName,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: OleenaTheme.textDark,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (profile?.isApproved ?? vendor.isFeatured) ...[
                            const SizedBox(width: 6),
                            const Tooltip(
                              message: 'Verified Business',
                              child: Icon(Icons.verified_rounded,
                                  color: OleenaTheme.primary, size: 22),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Rating & Location Subtitle
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 4),
                          Text(
                            vendor.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: OleenaTheme.textDark,
                            ),
                          ),
                          Text(
                            ' (${profile?.reviewCount ?? vendor.reviewCount} reviews)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: OleenaTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('•', style: TextStyle(color: Colors.grey.shade400)),
                          const SizedBox(width: 10),
                          const Icon(Icons.location_on_outlined, size: 14, color: OleenaTheme.primary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              profile?.location ?? vendor.location,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: OleenaTheme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      if (profile?.tagline != null && profile!.tagline!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: OleenaTheme.primaryTint,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: OleenaTheme.primary.withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            '"${profile.tagline!}"',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: OleenaTheme.primary,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Loading or Error Indicator ────────────────
                      if (_isLoading) ...[
                        _buildLoadingCard(),
                        const SizedBox(height: 20),
                      ] else if (_errorMessage != null) ...[
                        _buildErrorCard(),
                        const SizedBox(height: 20),
                      ],

                      // ── About & Bio Section ───────────────────────
                      _buildSectionHeader('About Vendor'),
                      const SizedBox(height: 8),
                      Text(
                        description.isNotEmpty
                            ? description
                            : 'Dedicated wedding specialist bringing your dream celebration to life.',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: Colors.grey.shade700,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Business Details Info Box ─────────────────
                      if (profile != null) ...[
                        _buildBusinessInfoCard(profile),
                        const SizedBox(height: 24),
                      ],

                      // ── Business Operating Hours Section ─────────
                      _buildSectionHeader('Business Operating Hours', icon: Icons.access_time_rounded),
                      const SizedBox(height: 12),
                      _buildBusinessHoursCard(profile?.businessHours ?? []),

                      const SizedBox(height: 28),

                      // ── Past Performance & Customer Reviews Section ────
                      _buildSectionHeader(
                        'Past Performance & Customer Reviews',
                        icon: Icons.rate_review_outlined,
                        badgeCount: profile?.performances.length ?? 0,
                      ),
                      const SizedBox(height: 12),
                      _buildPerformancesSection(profile?.performances ?? []),

                      const SizedBox(height: 28),

                      // ── Services & Packages Offered ───────────────
                      if (profile != null && profile.services.isNotEmpty) ...[
                        _buildSectionHeader('Services & Packages Offered', icon: Icons.inventory_2_outlined),
                        const SizedBox(height: 12),
                        _buildServicesSection(profile.services),
                        const SizedBox(height: 28),
                      ],

                      // ── Gallery Showcase ──────────────────────────
                      if (profile != null && profile.galleryImages.isNotEmpty) ...[
                        _buildSectionHeader('Work Gallery Showcase', icon: Icons.photo_library_outlined),
                        const SizedBox(height: 12),
                        _buildGalleryGrid(profile.galleryImages),
                        const SizedBox(height: 28),
                      ],

                      const SizedBox(height: 110), // Padding for floating action bar
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Top Navigation Floating Buttons ──────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                ScaleTransition(
                  scale: _heartScale,
                  child: _CircleButton(
                    icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    iconColor: _isFavorite ? const Color(0xFFFF3366) : OleenaTheme.textDark,
                    onTap: _toggleHeart,
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Floating CTA Bar ────────────────────────────────
          Positioned(
            bottom: bottomPad + 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'STARTING FROM',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: OleenaTheme.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          vendor.formattedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: OleenaTheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => requireLogin(
                      context,
                      reason: 'Sign in to send inquiries to ${vendor.name}',
                      icon: Icons.chat_bubble_outline_rounded,
                      onSuccess: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InquiriesScreen(fromDetails: true),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send Inquiry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OleenaTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper UI Widgets ──────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {IconData? icon, int? badgeCount}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: OleenaTheme.primary),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: OleenaTheme.textDark,
          ),
        ),
        if (badgeCount != null && badgeCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: OleenaTheme.primaryTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$badgeCount',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: OleenaTheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: OleenaTheme.primary),
          ),
          const SizedBox(width: 14),
          Text(
            'Syncing live business & performance data...',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? 'Notice: Showing basic profile info.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.amber.shade900),
            ),
          ),
          TextButton(
            onPressed: _fetchProfile,
            child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Renders Business Profile details (Address, Contact, Service Areas, Travel Policy, Years in Business)
  Widget _buildBusinessInfoCard(PublicVendorProfile profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Profile Details',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: OleenaTheme.textDark,
            ),
          ),
          const Divider(height: 20),
          if (profile.ownerName != null && profile.ownerName!.isNotEmpty)
            _buildInfoRow(Icons.person_outline_rounded, 'Owner / Manager', profile.ownerName!),
          if (profile.contactNumber != null && profile.contactNumber!.isNotEmpty)
            _buildInfoRow(Icons.phone_outlined, 'Primary Contact', profile.contactNumber!),
          if (profile.altPhoneNumber != null && profile.altPhoneNumber!.isNotEmpty)
            _buildInfoRow(Icons.phone_iphone_rounded, 'Alt Phone', profile.altPhoneNumber!),
          if (profile.email != null && profile.email!.isNotEmpty)
            _buildInfoRow(Icons.email_outlined, 'Business Email', profile.email!),
          if (profile.websiteUrl != null && profile.websiteUrl!.isNotEmpty)
            _buildInfoRow(Icons.language_rounded, 'Website', profile.websiteUrl!),
          if (profile.address != null && profile.address!.isNotEmpty)
            _buildInfoRow(Icons.place_outlined, 'Address', '${profile.address!}, ${profile.location}'),
          if (profile.yearsInBusiness != null && profile.yearsInBusiness! > 0)
            _buildInfoRow(Icons.history_edu_rounded, 'Experience', '${profile.yearsInBusiness} Years in Business'),
          if (profile.serviceAreas != null && profile.serviceAreas!.isNotEmpty)
            _buildInfoRow(Icons.map_outlined, 'Service Areas', profile.serviceAreas!),
          if (profile.travelPolicy != null && profile.travelPolicy!.isNotEmpty)
            _buildInfoRow(Icons.flight_takeoff_rounded, 'Travel Policy', profile.travelPolicy!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: OleenaTheme.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: OleenaTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: OleenaTheme.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: OleenaTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Renders weekly Operating Hours maintained from Web App (Open/Closed times)
  Widget _buildBusinessHoursCard(List<BusinessHoursItem> hours) {
    if (hours.isEmpty) {
      // Default standard hours if vendor hasn't customized hours JSON yet
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded, color: OleenaTheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Open Daily: 09:00 AM – 06:00 PM (Contact vendor for appointment)',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
      );
    }

    // Determine current day status
    final now = DateTime.now();
    final weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDayName = weekDays[now.weekday - 1];
    final todayItem = hours.firstWhere(
      (h) => h.day.equalsIgnoreCase(currentDayName),
      orElse: () => hours.first,
    );

    final isOpenToday = !todayItem.isClosed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Today Status Pill Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isOpenToday ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isOpenToday ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 16,
                      color: isOpenToday ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOpenToday ? 'Open Today (${todayItem.day})' : 'Closed Today (${todayItem.day})',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isOpenToday ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
                Text(
                  todayItem.displayLine,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOpenToday ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),

          // Schedule Rows
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: hours.map((item) {
                final isToday = item.day.equalsIgnoreCase(currentDayName);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.day,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday ? OleenaTheme.primary : OleenaTheme.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.isClosed
                              ? Colors.red.shade50
                              : (isToday ? OleenaTheme.primaryTint : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.displayLine,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: item.isClosed
                                ? Colors.red.shade700
                                : (isToday ? OleenaTheme.primary : Colors.grey.shade800),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders Past Performances & Ratings showcase added by vendor on web dashboard
  Widget _buildPerformancesSection(List<VendorPerformanceItem> performances) {
    if (performances.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.workspace_premium_outlined, size: 36, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'No past performances listed yet',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: OleenaTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vendor showcase events and ratings will appear here as added.',
                style: GoogleFonts.poppins(fontSize: 11, color: OleenaTheme.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: performances.map((perf) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Showcase Photo
                  if (perf.photoUrl != null && perf.photoUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.network(
                          perf.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported_outlined, size: 24, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Category Badge
                        if (perf.category.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: OleenaTheme.primaryTint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              perf.category.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: OleenaTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],

                        Text(
                          perf.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: OleenaTheme.textDark,
                          ),
                        ),

                        if (perf.eventDate != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.event_rounded, size: 12, color: OleenaTheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${perf.eventDate!.day}/${perf.eventDate!.month}/${perf.eventDate!.year}',
                                style: GoogleFonts.poppins(fontSize: 11, color: OleenaTheme.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              if (perf.description != null && perf.description!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  perf.description!,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700, height: 1.5),
                ),
              ],

              // Customer Feedback & Rating Snippet
              if (perf.customerFeedback != null && perf.customerFeedback!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote_rounded, size: 18, color: Color(0xFFD97706)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${perf.customerFeedback!}"',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                            if (perf.customerName != null && perf.customerName!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '— ${perf.customerName!}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Renders Packages & Services offered by vendor
  Widget _buildServicesSection(List<PublicVendorServiceItem> services) {
    return Column(
      children: services.map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              if (s.coverImageUrl != null && s.coverImageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: Image.network(s.coverImageUrl!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    if (s.shortDescription != null && s.shortDescription!.isNotEmpty)
                      Text(
                        s.shortDescription!,
                        style: GoogleFonts.poppins(fontSize: 11, color: OleenaTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      s.formattedPrice,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: OleenaTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Renders Portfolio Gallery Grid
  Widget _buildGalleryGrid(List<String> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    this.iconColor = OleenaTheme.textDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}
