import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oleena/core/app_config.dart';
import 'package:oleena/features/venue/widgets/full_screen_image_viewer.dart';
import 'package:oleena/models/listing_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Listing.resolveImageUrl', () {
    test('resolves null or empty to default fallback image', () {
      expect(Listing.resolveImageUrl(null), contains('images.unsplash.com'));
      expect(Listing.resolveImageUrl(''), contains('images.unsplash.com'));
      expect(Listing.resolveImageUrl('   '), contains('images.unsplash.com'));
    });

    test('preserves absolute http and https URLs', () {
      const url = 'https://example.com/photo.jpg';
      expect(Listing.resolveImageUrl(url), equals(url));

      const httpUrl = 'http://example.com/photo2.jpg';
      expect(Listing.resolveImageUrl(httpUrl), equals(httpUrl));
    });

    test('resolves relative paths to backend base URL without /api', () {
      final base = AppConfig.baseUrl.replaceAll('/api', '');
      expect(Listing.resolveImageUrl('/uploads/services/photo.jpg'), equals('$base/uploads/services/photo.jpg'));
      expect(Listing.resolveImageUrl('uploads/services/photo.jpg'), equals('$base/uploads/services/photo.jpg'));
    });

    test('dedupes resolved image lists correctly', () {
      final base = AppConfig.baseUrl.replaceAll('/api', '');
      final cover = '/uploads/services/photo.jpg';
      final images = [
        'uploads/services/photo.jpg',
        'https://example.com/unique.jpg',
        'https://example.com/unique.jpg',
      ];

      final resolved = [
        Listing.resolveImageUrl(cover),
        ...images.map((img) => Listing.resolveImageUrl(img)),
      ];

      final unique = <String>[];
      final seen = <String>{};
      for (final u in resolved) {
        if (seen.add(u)) unique.add(u);
      }

      expect(unique.length, equals(2));
      expect(unique[0], equals('$base/uploads/services/photo.jpg'));
      expect(unique[1], equals('https://example.com/unique.jpg'));
    });
  });

  group('FullScreenImageViewer Widget', () {
    testWidgets('renders placeholder when image list is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenImageViewer(imageUrls: []),
        ),
      );

      expect(find.text('No images available'), findsOneWidget);
    });

    testWidgets('renders top bar with counter and close button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenImageViewer(
            imageUrls: ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
            title: 'Grand Ballroom',
          ),
        ),
      );

      expect(find.text('Grand Ballroom'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });
  });
}
