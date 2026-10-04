import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:oleena/models/listing_model.dart';
import 'package:oleena/models/vendor.dart';
import 'package:oleena/core/favorites_provider.dart';
import 'package:oleena/screens/details/listing_details_screen.dart';
import 'package:oleena/screens/details/vendor_details_screen.dart';
import 'package:oleena/screens/inquiries/inquiry_detail_screen.dart';
import 'package:oleena/models/inquiry_model.dart';

void main() {
  Widget buildTestWidget(Widget child, {double width = 320, double textScale = 1.0}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(),
        ),
      ],
      child: MaterialApp(
        builder: (context, childWidget) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(width, 800),
              textScaler: TextScaler.linear(textScale),
            ),
            child: childWidget!,
          );
        },
        home: child,
      ),
    );
  }

  group('Overflow Sweep Tests', () {
    final longVendor = Vendor(
      id: '1',
      name: 'Extremely Long Vendor Business Name That Might Overflow And Cause RenderFlex Issues',
      category: 'Very Long Category Name That Might Overflow And Cause RenderFlex Issues',
      categoryIcon: 'hotel',
      priceFrom: 10000000.0,
      rating: 4.8,
      reviewCount: 9999,
      imageUrl: '',
      coverImageUrl: '',
      logoUrl: '',
      location: 'Very Long Location Name That Might Overflow And Cause RenderFlex Issues',
      city: 'Very Long City Name That Might Overflow And Cause RenderFlex Issues',
      description: 'Test description',
      isFeatured: true,
    );

    final longListing = Listing(
      id: '1',
      serviceId: 1,
      title: 'Extremely Long Listing Title That Might Overflow And Cause RenderFlex Issues',
      category: 'Very Long Category Name That Might Overflow And Cause RenderFlex Issues',
      categoryId: 1,
      categoryIcon: 'hotel',
      shortDescription: 'Short description',
      description: 'Long description',
      price: 10000000.0,
      priceFrom: 10000000.0,
      isPriceOnRequest: false,
      coverImageUrl: '',
      images: [],
      vendor: VendorInfo(
        id: '1',
        vendorId: 1,
        name: 'Extremely Long Vendor Business Name That Might Overflow And Cause RenderFlex Issues',
        ownerName: 'Extremely Long Owner Name That Might Overflow And Cause RenderFlex Issues',
        location: 'Very Long Location Name That Might Overflow And Cause RenderFlex Issues',
        rating: 4.8,
        reviewCount: 9999,
        isApproved: true,
        contactNumber: '+94 77 123 4567 890 123 456',
      ),
      hotelVenueDetails: null,
    );

    for (final textScale in [1.0, 1.3, 1.5]) {
      for (final width in [320.0, 360.0]) {
        testWidgets('ListingDetailsScreen should not overflow at width $width, scale $textScale', (tester) async {
          await tester.pumpWidget(buildTestWidget(ListingDetailsScreen(listing: longListing), width: width, textScale: textScale));
          await tester.pump();
          
          final exception = tester.takeException();
          if (exception != null) {
            fail('Overflow detected: $exception');
          }
        });

        testWidgets('VendorDetailsScreen should not overflow at width $width, scale $textScale', (tester) async {
          await tester.pumpWidget(buildTestWidget(VendorDetailsScreen(vendor: longVendor), width: width, textScale: textScale));
          await tester.pump();
          
          final exception = tester.takeException();
          if (exception != null) {
            fail('Overflow detected: $exception');
          }
        });

        testWidgets('InquiryDetailScreen should not overflow at width $width, scale $textScale', (tester) async {
          final longInquiry = Inquiry(
            inquiryId: 1,
            vendorId: 1,
            vendorName: 'Extremely Long Vendor Business Name That Might Overflow And Cause RenderFlex Issues',
            serviceId: 1,
            serviceName: 'Very Long Service Name That Might Overflow And Cause RenderFlex Issues',
            weddingDate: DateTime(2027, 10, 15),
            guestCount: 500,
            budget: 1000000000.0,
            message: 'This is a very long message. ' * 20,
            status: 'Pending Review from Vendor',
            createdAt: DateTime(2026, 10, 1),
          );

          await tester.pumpWidget(buildTestWidget(InquiryDetailScreen(inquiry: longInquiry), width: width, textScale: textScale));
          await tester.pump();
          
          final exception = tester.takeException();
          if (exception != null) {
            fail('Overflow detected: $exception');
          }
        });
      }
    }
  });
}
