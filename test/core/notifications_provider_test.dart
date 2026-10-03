import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:oleena/core/api_client.dart';
import 'package:oleena/core/notifications_provider.dart';
import 'package:oleena/models/notification_model.dart';

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
  group('AppNotification Model', () {
    test('fromJson & toJson round trip', () {
      final json = {
        'notificationId': 42,
        'title': 'Test Title',
        'message': 'Test Message',
        'type': 'InquiryStatusChanged',
        'isRead': false,
        'createdAt': '2026-10-02T12:00:00.000Z',
      };

      final notif = AppNotification.fromJson(json);
      expect(notif.notificationId, equals(42));
      expect(notif.title, equals('Test Title'));
      expect(notif.message, equals('Test Message'));
      expect(notif.type, equals('InquiryStatusChanged'));
      expect(notif.isRead, isFalse);

      final exported = notif.toJson();
      expect(exported['notificationId'], equals(42));
      expect(exported['title'], equals('Test Title'));
      expect(exported['isRead'], isFalse);
    });

    test('copyWith updates properties', () {
      final notif = AppNotification(
        notificationId: 1,
        title: 'Original',
        message: 'Original Message',
        type: 'General',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final updated = notif.copyWith(isRead: true, title: 'Updated');
      expect(updated.isRead, isTrue);
      expect(updated.title, equals('Updated'));
      expect(updated.notificationId, equals(1));
    });
  });

  group('NotificationsProvider', () {
    test('fetchUnreadCount updates unreadCount', () async {
      final client = MockHttpClient((req) async {
        expect(req.url.path, endsWith('/notifications/unread-count'));
        return http.Response(jsonEncode({'count': 5}), 200, headers: {'content-type': 'application/json'});
      });

      final provider = NotificationsProvider(apiClient: ApiClient(httpClient: client));
      expect(provider.unreadCount, equals(0));

      await provider.fetchUnreadCount();
      expect(provider.unreadCount, equals(5));
    });

    test('fetchNotifications updates notifications list and calculates unread count', () async {
      final client = MockHttpClient((req) async {
        expect(req.url.path, endsWith('/notifications'));
        return http.Response(
          jsonEncode([
            {
              'notificationId': 101,
              'title': 'Inquiry Update',
              'message': 'Status changed to Confirmed',
              'type': 'InquiryStatusChanged',
              'isRead': false,
              'createdAt': '2026-10-02T10:00:00.000Z',
            },
            {
              'notificationId': 102,
              'title': 'Price Alert',
              'message': 'Price dropped by 10%',
              'type': 'PriceUpdated',
              'isRead': true,
              'createdAt': '2026-10-02T09:00:00.000Z',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final provider = NotificationsProvider(apiClient: ApiClient(httpClient: client));
      await provider.fetchNotifications();

      expect(provider.notifications.length, equals(2));
      expect(provider.unreadCount, equals(1));
      expect(provider.notifications.first.title, equals('Inquiry Update'));
    });

    test('markAsRead optimistically marks notification as read with rollback on failure', () async {
      bool failRequest = false;
      final client = MockHttpClient((req) async {
        if (req.method == 'GET') {
          return http.Response(
            jsonEncode([
              {
                'notificationId': 101,
                'title': 'Inquiry Update',
                'message': 'Status changed',
                'type': 'InquiryStatusChanged',
                'isRead': false,
                'createdAt': '2026-10-02T10:00:00.000Z',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (req.method == 'PATCH') {
          if (failRequest) {
            return http.Response(jsonEncode({'message': 'Server error'}), 500);
          }
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      final provider = NotificationsProvider(apiClient: ApiClient(httpClient: client));
      await provider.fetchNotifications();
      expect(provider.unreadCount, equals(1));
      expect(provider.notifications.first.isRead, isFalse);

      // Successful markAsRead
      await provider.markAsRead(101);
      expect(provider.unreadCount, equals(0));
      expect(provider.notifications.first.isRead, isTrue);

      // Reset to unread for failure test
      await provider.fetchNotifications();
      expect(provider.unreadCount, equals(1));

      failRequest = true;
      try {
        await provider.markAsRead(101);
        fail('Should throw');
      } catch (_) {
        // Rollback verified
        expect(provider.unreadCount, equals(1));
        expect(provider.notifications.first.isRead, isFalse);
      }
    });

    test('markAllAsRead optimistically marks all read with rollback on failure', () async {
      bool failRequest = false;
      final client = MockHttpClient((req) async {
        if (req.method == 'GET') {
          return http.Response(
            jsonEncode([
              {
                'notificationId': 1,
                'title': 'N1',
                'message': 'M1',
                'type': 'Type1',
                'isRead': false,
                'createdAt': '2026-10-02T10:00:00.000Z',
              },
              {
                'notificationId': 2,
                'title': 'N2',
                'message': 'M2',
                'type': 'Type2',
                'isRead': false,
                'createdAt': '2026-10-02T10:00:00.000Z',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (req.method == 'PATCH') {
          if (failRequest) {
            return http.Response(jsonEncode({'message': 'Internal error'}), 500);
          }
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      final provider = NotificationsProvider(apiClient: ApiClient(httpClient: client));
      await provider.fetchNotifications();
      expect(provider.unreadCount, equals(2));

      await provider.markAllAsRead();
      expect(provider.unreadCount, equals(0));
      expect(provider.notifications.every((n) => n.isRead), isTrue);

      // Rollback test
      await provider.fetchNotifications();
      failRequest = true;
      try {
        await provider.markAllAsRead();
        fail('Should throw');
      } catch (_) {
        expect(provider.unreadCount, equals(2));
        expect(provider.notifications.every((n) => !n.isRead), isTrue);
      }
    });

    test('deleteNotification optimistically removes notification with rollback on failure', () async {
      bool failRequest = false;
      final client = MockHttpClient((req) async {
        if (req.method == 'GET') {
          return http.Response(
            jsonEncode([
              {
                'notificationId': 55,
                'title': 'To Delete',
                'message': 'Msg',
                'type': 'Type',
                'isRead': false,
                'createdAt': '2026-10-02T10:00:00.000Z',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (req.method == 'DELETE') {
          if (failRequest) {
            return http.Response(jsonEncode({'message': 'Error deleting'}), 500);
          }
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      final provider = NotificationsProvider(apiClient: ApiClient(httpClient: client));
      await provider.fetchNotifications();
      expect(provider.notifications.length, equals(1));
      expect(provider.unreadCount, equals(1));

      failRequest = true;
      try {
        await provider.deleteNotification(55);
        fail('Should throw');
      } catch (_) {
        // Rollback verified
        expect(provider.notifications.length, equals(1));
        expect(provider.unreadCount, equals(1));
      }

      failRequest = false;
      await provider.deleteNotification(55);
      expect(provider.notifications.isEmpty, isTrue);
      expect(provider.unreadCount, equals(0));
    });

    test('clear resets state', () async {
      final client = MockHttpClient((req) async {
        return http.Response(jsonEncode({'count': 10}), 200, headers: {'content-type': 'application/json'});
      });

      final provider = NotificationsProvider(apiClient: ApiClient(httpClient: client));
      await provider.fetchUnreadCount();
      expect(provider.unreadCount, equals(10));

      provider.clear();
      expect(provider.unreadCount, equals(0));
      expect(provider.notifications, isEmpty);
    });
  });
}
