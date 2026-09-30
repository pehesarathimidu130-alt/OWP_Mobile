import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/listing_model.dart';

class ListingCategoryDetailsWidget extends StatelessWidget {
  final Listing listing;

  const ListingCategoryDetailsWidget({super.key, required this.listing});

  String _getGroupForField(String fieldName) {
    final groups = {
      'venueType': 'Venue Basics', 'venueSetting': 'Venue Basics', 'indoorOutdoor': 'Venue Basics', 'hasAirConditioning': 'Venue Basics', 'hasBackupGenerator': 'Venue Basics', 'hasElevator': 'Venue Basics', 'hasGuestDropOff': 'Venue Basics', 'hasVendorLoadingAccess': 'Venue Basics',
      'parkingCapacity': 'Parking & Accessibility', 'parkingType': 'Parking & Accessibility', 'valetParking': 'Parking & Accessibility', 'wifi': 'Parking & Accessibility', 'wheelchairAccessible': 'Parking & Accessibility',
      'hasCeremony': 'Ceremony Options', 'ceremonyLocation': 'Ceremony Options', 'outdoorCeremonyCapacity': 'Ceremony Options', 'separateCeremonyReceptionSpaces': 'Ceremony Options',
      'hasCatering': 'Catering Options', 'cateringProvidedBy': 'Catering Options', 'outsideFoodAllowed': 'Catering Options', 'kitchenFacility': 'Catering Options', 'cuisineOptions': 'Catering Options', 'buffetAvailable': 'Catering Options', 'platedDinnerAvailable': 'Catering Options', 'customMenuAvailable': 'Catering Options', 'cakeCuttingAllowed': 'Catering Options',
      'hasBeverages': 'Beverages & Bar', 'beverageService': 'Beverages & Bar', 'barFacility': 'Beverages & Bar', 'outsideBeveragesAllowed': 'Beverages & Bar',
      'hasAccommodation': 'Accommodation', 'numberOfGuestRooms': 'Accommodation', 'complimentaryBridalSuite': 'Accommodation', 'roomTypes': 'Accommodation', 'bridalSuiteAvailable': 'Accommodation', 'guestAccommodationAvailable': 'Accommodation', 'onSiteAccommodation': 'Accommodation',
      'hasEntertainment': 'Entertainment', 'djAllowed': 'Entertainment', 'liveBandAllowed': 'Entertainment', 'maxMusicEndTime': 'Entertainment', 'projectorScreen': 'Entertainment', 'traditionalMusicAllowed': 'Entertainment',
      'hasDecoration': 'Decoration Policy', 'decorationPolicy': 'Decoration Policy', 'tableDecoration': 'Decoration Policy', 'lightingDecoration': 'Decoration Policy', 'outsideDecoratorAllowed': 'Decoration Policy', 'basicDecorationIncluded': 'Decoration Policy', 'floralDecorationAvailable': 'Decoration Policy', 'stageDecorationAvailable': 'Decoration Policy',
      'hasPhotographyPolicy': 'Photography Policy', 'photographyAllowed': 'Photography Policy', 'externalPhotographerAllowed': 'Photography Policy', 'preWeddingShootAllowed': 'Photography Policy', 'photographyLocations': 'Photography Policy',
      'hasPolicies': 'Booking Policies', 'depositRequired': 'Booking Policies', 'depositAmount': 'Booking Policies', 'minimumGuestCount': 'Booking Policies', 'minimumBookingDuration': 'Booking Policies', 'cancellationPolicy': 'Booking Policies', 'outsideVendorRestrictions': 'Booking Policies', 'additionalCharges': 'Booking Policies',

      'shootingStyle': 'Coverage & Deliverables', 'hoursOfCoverage': 'Coverage & Deliverables', 'includedServices': 'Coverage & Deliverables', 'photosDelivered': 'Coverage & Deliverables', 'deliveryTimeframe': 'Coverage & Deliverables', 'rawFilesIncluded': 'Coverage & Deliverables', 'digitalGalleryIncluded': 'Coverage & Deliverables',
      'albumIncluded': 'Albums', 'albumType': 'Albums', 'albumPages': 'Albums',
      'photographerCount': 'Equipment & Team', 'droneAllowed': 'Equipment & Team', 'backupGear': 'Equipment & Team',
      'videographyIncluded': 'Videography', 'videographerCount': 'Videography', 'videoLength': 'Videography', 'videoDeliverables': 'Videography',
      'travelOutsideColombo': 'Travel & Policies', 'outstationAccommodationRequired': 'Travel & Policies',

      'performanceType': 'Performance Details', 'lineupSize': 'Performance Details', 'setDuration': 'Performance Details', 'genres': 'Performance Details',
      'soundSystemIncluded': 'Equipment', 'soundSystemCapacity': 'Equipment', 'wirelessMics': 'Equipment', 'stageLightingIncluded': 'Equipment', 'lightingRig': 'Equipment',
      'setupTimeRequired': 'Services & Logistics', 'backupHardwareOnSite': 'Services & Logistics', 'mcServicesIncluded': 'Services & Logistics', 'breakMusicIncluded': 'Services & Logistics', 'customSongsAllowed': 'Services & Logistics', 'overtimeRate': 'Services & Logistics',

      'primaryStyles': 'Style & Elements', 'providesFlorals': 'Style & Elements', 'floralTypes': 'Style & Elements', 'availableSetups': 'Style & Elements', 'tablewareLinens': 'Style & Elements', 'customSignageIncluded': 'Style & Elements', 'loungePropsAvailable': 'Style & Elements',
      'sameDayTeardownIncluded': 'Services & Logistics', 'venueRestrictions': 'Services & Logistics', 'outstationDecorAllowed': 'Services & Logistics', 'travelFeePolicy': 'Services & Logistics',
      'freeConsultation': 'Consultation & Fees', 'customMoodboards': 'Consultation & Fees', 'designFeePolicy': 'Consultation & Fees', 'minimumBudget': 'Consultation & Fees',

      'serviceStyle': 'Cuisine & Service', 'cuisines': 'Cuisine & Service', 'dietaryOptions': 'Cuisine & Service', 'minGuests': 'Cuisine & Service', 'maxGuests': 'Cuisine & Service', 'pricePerHead': 'Cuisine & Service',
      'waitstaffIncluded': 'Equipment & Setup', 'glasswareIncluded': 'Equipment & Setup', 'crockeryCutlery': 'Equipment & Setup', 'chafingDishesIncluded': 'Equipment & Setup', 'furnitureRentalAvailable': 'Equipment & Setup', 'setupTeardownIncluded': 'Equipment & Setup',
      'outstationCatering': 'Logistics & Policies', 'kitchenRequirement': 'Logistics & Policies', 'tastingAvailable': 'Logistics & Policies', 'tastingPolicy': 'Logistics & Policies',
    };
    return groups[fieldName] ?? 'Additional Details';
  }

  String _humanize(String text) {
    final overrides = {
      'djAllowed': 'DJ Allowed',
      'mcServicesIncluded': 'MC Services Included',
      'wifi': 'Wi-Fi',
      'indoorOutdoor': 'Indoor / Outdoor',
      'numberOfGuestRooms': 'Number of Guest Rooms',
    };
    if (overrides.containsKey(text)) return overrides[text]!;

    String stripped = text;
    if (text.startsWith('has') && text.length > 3 && text[3].toUpperCase() == text[3]) {
      stripped = text.substring(3);
    } else if (text.startsWith('is') && text.length > 2 && text[2].toUpperCase() == text[2]) {
      stripped = text.substring(2);
    }
    
    final split = stripped.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim();
    return split.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? activeDetails = listing.hotelVenueDetails ??
        listing.photographyDetails ??
        listing.musicDetails ??
        listing.decorationsDetails ??
        listing.cateringDetails;

    final List<Map<String, dynamic>> spaces = listing.venueSpaces ?? [];

    if ((activeDetails == null || activeDetails.isEmpty) && spaces.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupedFields = <String, List<MapEntry<String, dynamic>>>{};
    
    if (activeDetails != null) {
      for (final entry in activeDetails.entries) {
        final val = entry.value;
        if (val == null) continue;
        if (val is String && val.trim().isEmpty) continue;
        if (val is List && val.isEmpty) continue;
        if (val is bool && val == false) continue; // Skip false booleans

        final group = _getGroupForField(entry.key);
        groupedFields.putIfAbsent(group, () => []).add(entry);
      }
    }

    if (groupedFields.isEmpty && spaces.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: OleenaTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ...groupedFields.entries.map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.key,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OleenaTheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                ...group.value.map((field) => _buildSpecRow(field)),
              ],
            ),
          );
        }),
        
        if (spaces.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Venue Spaces',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OleenaTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ...spaces.map((space) => _buildSpaceCard(space)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSpecRow(MapEntry<String, dynamic> field) {
    final label = _humanize(field.key);
    Widget valueWidget;

    if (field.value is bool && field.value == true) {
      valueWidget = Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Text(
            'Yes',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: OleenaTheme.textDark,
            ),
          ),
        ],
      );
    } else if (field.value is List) {
      final items = (field.value as List).map((e) => e.toString()).toList();
      valueWidget = Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items.map((item) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: OleenaTheme.primaryTint.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OleenaTheme.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            item,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: OleenaTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        )).toList(),
      );
    } else {
      valueWidget = Text(
        field.value.toString(),
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          color: OleenaTheme.textDark,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: OleenaTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: valueWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceCard(Map<String, dynamic> space) {
    final name = space['name']?.toString() ?? 'Space';
    final type = space['type']?.toString();
    final seated = space['capacitySeated'];
    final floating = space['capacityFloating'];
    final isAc = space['isAirConditioned'] == true;
    final desc = space['description']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F7),
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OleenaTheme.textDark,
                  ),
                ),
              ),
              if (isAc)
                const Tooltip(
                  message: 'Air Conditioned',
                  child: Icon(Icons.ac_unit_rounded, size: 16, color: OleenaTheme.primary),
                ),
            ],
          ),
          if (type != null && type.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              type,
              style: GoogleFonts.poppins(fontSize: 12, color: OleenaTheme.textMuted),
            ),
          ],
          if (seated != null || floating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (seated != null) ...[
                  const Icon(Icons.chair_alt_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$seated Seated',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                ],
                if (floating != null) ...[
                  const Icon(Icons.groups_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$floating Floating',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
          if (desc != null && desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              desc,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
