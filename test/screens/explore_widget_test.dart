import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oleena/features/venue/widgets/explore_filter_sheet.dart';

void main() {
  testWidgets('ExploreSortFilterSheet renders properly and allows selecting options', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ExploreFilterCriteria? appliedCriteria;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await showModalBottomSheet<ExploreFilterCriteria>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => const ExploreSortFilterSheet(
                    currentCriteria: ExploreFilterCriteria(),
                  ),
                );
                appliedCriteria = result;
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );

    // Tap button to open sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify Title and Section Headers are present
    expect(find.text('Sort & Filter'), findsOneWidget);
    expect(find.text('Sort By'), findsOneWidget);
    expect(find.text('Customer Rating'), findsOneWidget);
    expect(find.text('Starting Budget'), findsOneWidget);

    // Verify sort options are rendered
    expect(find.text('Price: Low to High'), findsOneWidget);
    expect(find.text('Price: High to Low'), findsOneWidget);
    expect(find.text('Rating: High to Low'), findsOneWidget);

    // Select Price: Low to High
    await tester.tap(find.text('Price: Low to High'));
    await tester.pumpAndSettle();

    // Select 4.5+ ★ rating chip
    await tester.tap(find.text('4.5+ ★'));
    await tester.pumpAndSettle();

    // Tap 'Apply Filters'
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    // Verify callback received the expected criteria
    expect(appliedCriteria, isNotNull);
    expect(appliedCriteria!.sortOption, ExploreSortOption.priceLowToHigh);
    expect(appliedCriteria!.minRating, 4.5);
  });
}
