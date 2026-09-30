import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oleena/features/venue/widgets/listing_category_details.dart';
import 'package:oleena/models/listing_model.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Listing loadListingFromJson(String filename) {
    final file = File('test/test_data/$filename');
    final jsonString = file.readAsStringSync();
    final jsonMap = jsonDecode(jsonString);
    return Listing.fromJson(jsonMap);
  }

  group('ListingCategoryDetailsWidget Tests', () {
    testWidgets('Hotel/Venue (ID 21) renders venue spaces and details', (WidgetTester tester) async {
      final listing = loadListingFromJson('21.json');
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ListingCategoryDetailsWidget(listing: listing),
          ),
        ),
      ));

      // Should render 3 venue spaces based on the test data (Grand Ballroom, Grand Hall, Garden)
      expect(find.text('Grand Ballroom'), findsWidgets);
      expect(find.text('Grand Hall'), findsWidgets);
      expect(find.text('Garden'), findsWidgets);

      // Should render at least one populated field from hotelVenueDetails
      // ValetParking should be "Included" and translated to "Valet Parking"
      expect(find.text('Valet Parking'), findsWidgets);
      expect(find.text('Included'), findsWidgets);

      expect(find.text('Photography Policy'), findsWidgets);
      
      // Let's assert it doesn't render "Videography" or "Shooting Style"
      expect(find.text('Videography'), findsNothing);
      expect(find.text('Shooting Style'), findsNothing);
    });

    testWidgets('Decorations (ID 24) ignores null fields and renders populated', (WidgetTester tester) async {
      final listing = loadListingFromJson('24.json');
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListingCategoryDetailsWidget(listing: listing),
        ),
      ));

      // Should render primaryStyles and freeConsultation 
      expect(find.text('Primary Styles'), findsOneWidget);
      expect(find.text('Free Consultation'), findsOneWidget);

      // Should not render null fields like Floral Types or Available Setups
      expect(find.text('Floral Types'), findsNothing);
      expect(find.text('Available Setups'), findsNothing);
    });

    testWidgets('Catering (ID 25) skips false booleans and renders correctly', (WidgetTester tester) async {
      final listing = loadListingFromJson('25.json');
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListingCategoryDetailsWidget(listing: listing),
        ),
      ));

      // Should render cuisines, waitstaffIncluded
      expect(find.text('Cuisines'), findsOneWidget);
      expect(find.text('Waitstaff Included'), findsOneWidget);

      // tastingAvailable is false, so it should be skipped entirely
      expect(find.text('Tasting Available'), findsNothing);
    });

    testWidgets('Empty/null detail object renders nothing', (WidgetTester tester) async {
      // Mock listing with no details
      final emptyListing = Listing(
        id: '99',
        serviceId: 99,
        title: 'Empty',
        category: 'Empty',
        categoryId: 99,
        categoryIcon: 'icon',
        shortDescription: 'Empty',
        description: 'Empty',
        priceFrom: 0,
        isPriceOnRequest: true,
        coverImageUrl: 'url',
        images: [],
        vendor: VendorInfo(id: '1', vendorId: 1, name: 'V', location: 'L', rating: 5, reviewCount: 0, isApproved: true),
      );
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListingCategoryDetailsWidget(listing: emptyListing),
        ),
      ));

      // Assert the widget renders a SizedBox.shrink() effectively finding nothing but the Scaffold body
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('Specifications'), findsNothing);
    });

    testWidgets('Music (ID 18) array fields render in a Wrap without overflow', (WidgetTester tester) async {
      final listing = loadListingFromJson('18.json');
      
      // Use a narrow viewport to force wrap behavior check
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ListingCategoryDetailsWidget(listing: listing),
          ),
        ),
      ));

      expect(find.text('Genres'), findsOneWidget);
      // Assert that Wrap is used
      expect(find.byType(Wrap), findsWidgets);
      
      // Ensure no exceptions were thrown during render (RenderFlex overflow would normally throw during pump)
      expect(tester.takeException(), isNull);
      
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
