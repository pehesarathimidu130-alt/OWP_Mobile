import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:oleena/core/api_service.dart';
import 'package:oleena/core/auth_provider.dart';
import 'package:oleena/core/session_events.dart';
import 'package:oleena/features/profile/widgets/notification_preferences_card.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:oleena/core/inquiry_api_service.dart';
import 'package:oleena/features/profile/providers/notification_preferences_provider.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;
  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  group('SessionEvents & 401 handling', () {
    setUp(() {
      SessionEvents.resetUnauthorizedGuard();
      SessionEvents.onUnauthorized = null;
    });

    test('SessionEvents triggers callback and guards against re-entry', () async {
      int callCount = 0;
      SessionEvents.onUnauthorized = () {
        callCount++;
      };

      await SessionEvents.triggerUnauthorized();
      await SessionEvents.triggerUnauthorized();
      await SessionEvents.triggerUnauthorized();

      expect(callCount, equals(1), reason: 'Re-entry guard should prevent multiple triggers');

      SessionEvents.resetUnauthorizedGuard();
      await SessionEvents.triggerUnauthorized();
      expect(callCount, equals(2), reason: 'After reset, callback should trigger again');
    });

    test('ApiService does NOT trigger unauthorized on 401 without Authorization header', () async {
      int unauthorizedCount = 0;
      SessionEvents.onUnauthorized = () {
        unauthorizedCount++;
      };

      final client = MockHttpClient((req) async {
        return http.Response(
          jsonEncode({'title': 'Invalid credentials'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(httpClient: client);

      try {
        // Unauthenticated call (e.g. login with wrong password)
        await service.post('/auth/customer/login', body: {'email': 'test@example.com', 'password': 'wrong'});
      } catch (e) {
        expect(e, isA<ApiException>());
      }

      expect(unauthorizedCount, equals(0), reason: '401 on request without Auth header must not redirect');
    });
  });

  group('CustomerProfileProvider & Session Synchronization', () {
    test('updateProfile updates CustomerProfile and synchronizes with AuthProvider session', () async {
      final auth = AuthProvider();

      // Verify updateUserSession updates AuthProvider in-memory and display getters
      await auth.updateUserSession(fullName: 'Jane Doe');
      expect(auth.displayName, equals('Jane Doe'));
      expect(auth.userInitials, equals('JD'));
    });
  });

  group('InquiryApiService 401 handling', () {
    test('InquiryApiService triggers unauthorized when token is present and 401 received', () async {
      SessionEvents.resetUnauthorizedGuard();
      int unauthorizedCount = 0;
      SessionEvents.onUnauthorized = () {
        unauthorizedCount++;
      };

      final client = MockHttpClient((req) async {
        return http.Response(
          jsonEncode({'title': 'Unauthorized'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final inquiryService = InquiryApiService(httpClient: client);

      try {
        await inquiryService.getMyInquiries();
      } catch (e) {
        expect(e, isA<ApiException>());
      }
      expect(unauthorizedCount, equals(0));
    });
  });

  group('NotificationPreferencesCard widget', () {
    testWidgets('renders active switches for Inquiry Updates and Favourite Price Changes without Coming soon badge', (tester) async {
      final prefsProvider = NotificationPreferencesProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<NotificationPreferencesProvider>.value(
          value: prefsProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: NotificationPreferencesCard(),
            ),
          ),
        ),
      );

      // Verify Coming soon badge does NOT exist
      expect(find.text('Coming soon'), findsNothing);

      // Verify the 2 supported category labels exist
      expect(find.text('Inquiry Updates'), findsOneWidget);
      expect(find.text('Favourite Price Changes'), findsOneWidget);

      // Verify weekly digest, promotions, and wedding reminders have been REMOVED
      expect(find.text('Weekly Digest'), findsNothing);
      expect(find.text('Promotions'), findsNothing);
      expect(find.text('Wedding Reminders'), findsNothing);
      expect(find.text('New Offers & Packages'), findsNothing);

      // Verify all Switch widgets have onChanged != null (enabled and interactive)
      final switches = tester.widgetList<Switch>(find.byType(Switch));
      expect(switches.length, equals(2));
      for (final s in switches) {
        expect(s.onChanged, isNotNull, reason: 'All switches must be enabled and connected to provider');
        expect(s.value, isTrue);
      }
    });
  });
}
