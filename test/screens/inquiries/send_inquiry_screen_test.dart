import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oleena/models/inquiry_model.dart';
import 'package:oleena/models/listing_model.dart';
import 'package:oleena/screens/inquiries/inquiry_detail_screen.dart';
import 'package:oleena/screens/inquiries/send_inquiry_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testListing = Listing(
    id: '1',
    serviceId: 101,
    title: 'Grand Coastal Ballroom',
    category: 'Hotel / Venue',
    categoryId: 1,
    categoryIcon: 'location_city',
    shortDescription: 'Exquisite ballroom.',
    description: 'Detailed description.',
    price: 350000,
    priceFrom: 350000,
    isPriceOnRequest: false,
    coverImageUrl: 'https://example.com/cover.jpg',
    images: const [],
    vendor: VendorInfo(
      id: '10',
      vendorId: 10,
      name: 'Shangri-La Colombo',
      location: 'Colombo, Sri Lanka',
      rating: 4.9,
      reviewCount: 42,
      isApproved: true,
    ),
    isFavorite: false,
  );

  group('SendInquiryScreen', () {
    testWidgets('Hotel/Venue category shows guest count and venue-specific message hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SendInquiryScreen(listing: testListing),
        ),
      );

      // Verify title, vendor name, and category pill are displayed
      expect(find.text('Grand Coastal Ballroom'), findsOneWidget);
      expect(find.text('Shangri-La Colombo'), findsOneWidget);
      expect(find.text('HOTEL / VENUE'), findsOneWidget);

      // Hotel/Venue: Expected Guests field IS shown
      expect(find.text('Expected Guests (optional)'), findsOneWidget);

      // No phone field
      expect(find.text('Phone'), findsNothing);
      expect(find.text('Contact Phone'), findsNothing);

      // Budget (LKR), optional exists
      expect(find.text('Budget (LKR), optional'), findsOneWidget);

      // Message field with 500 max length
      expect(find.text('Message to Vendor'), findsOneWidget);
      expect(find.text('0/500'), findsOneWidget);
    });

    testWidgets('Photography category hides guest count and shows photography-specific hint', (tester) async {
      final photoListing = Listing(
        id: '2',
        serviceId: 102,
        title: 'Wedding Photography Package',
        category: 'Photography',
        categoryId: 2,
        categoryIcon: 'camera_alt',
        shortDescription: 'Premium coverage.',
        description: 'Full-day coverage.',
        price: 150000,
        priceFrom: 150000,
        isPriceOnRequest: false,
        coverImageUrl: 'https://example.com/photo.jpg',
        images: const [],
        vendor: VendorInfo(
          id: '11',
          vendorId: 11,
          name: 'Snapshot Studio',
          location: 'Colombo, Sri Lanka',
          rating: 4.8,
          reviewCount: 30,
          isApproved: true,
        ),
        isFavorite: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SendInquiryScreen(listing: photoListing),
        ),
      );

      // Photography: guest count is NOT shown
      expect(find.text('Expected Guests (optional)'), findsNothing);

      // Category pill is shown
      expect(find.text('PHOTOGRAPHY'), findsOneWidget);
    });
  });

  group('InquiryDetailScreen guest count display', () {
    testWidgets('hides Expected Guests row when guestCount is null', (tester) async {
      final inquiry = Inquiry(
        inquiryId: 1,
        vendorId: 10,
        vendorName: 'Shangri-La Colombo',
        serviceId: 101,
        serviceName: 'Grand Coastal Ballroom',
        weddingDate: DateTime(2026, 12, 15),
        guestCount: null, // NULL
        budget: 500000,
        message: 'Looking forward to our event.',
        status: 'Pending',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: InquiryDetailScreen(inquiry: inquiry),
        ),
      );

      // Expected Guests row should NOT be present
      expect(find.text('Expected Guests'), findsNothing);
      expect(find.text('null guests'), findsNothing);
      expect(find.text('0 guests'), findsNothing);
      expect(find.text('Not specified'), findsNothing);
    });

    testWidgets('displays Expected Guests row when guestCount has a positive value', (tester) async {
      final inquiry = Inquiry(
        inquiryId: 1,
        vendorId: 10,
        vendorName: 'Shangri-La Colombo',
        serviceId: 101,
        serviceName: 'Grand Coastal Ballroom',
        weddingDate: DateTime(2026, 12, 15),
        guestCount: 200,
        budget: 500000,
        message: 'Looking forward to our event.',
        status: 'Pending',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: InquiryDetailScreen(inquiry: inquiry),
        ),
      );

      // Expected Guests row SHOULD be present with formatted count
      expect(find.text('Expected Guests'), findsOneWidget);
      expect(find.text('200 guests'), findsOneWidget);
    });
  });
}
