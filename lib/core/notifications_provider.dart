import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'api_client.dart';

/// Provider for managing customer notifications.
///
/// Communicates directly with `/api/notifications` routes:
/// - GET /notifications
/// - GET /notifications/unread-count
/// - PATCH /notifications/{id}/read
/// - PATCH /notifications/read-all
/// - DELETE /notifications/{id}
///
/// Features optimistic UI updates with automatic rollback on error.
class NotificationsProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotificationsProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches unread notification count via GET /api/notifications/unread-count
  Future<void> fetchUnreadCount() async {
    try {
      final res = await _apiClient.get('/notifications/unread-count');
      if (res is Map<String, dynamic> && res['count'] != null) {
        _unreadCount = (res['count'] as num).toInt();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationsProvider] fetchUnreadCount error: $e');
    }
  }

  /// Fetches full notification list via GET /api/notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.get('/notifications');
      if (res is List) {
        _notifications = res
            .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
            .toList();
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load notifications.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optimistically marks a single notification as read via PATCH /api/notifications/{id}/read
  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index == -1) return;

    final existing = _notifications[index];
    if (existing.isRead) return;

    // Optimistic update
    _notifications[index] = existing.copyWith(isRead: true);
    _unreadCount = (_unreadCount - 1).clamp(0, 9999);
    notifyListeners();

    try {
      await _apiClient.patch('/notifications/$notificationId/read');
    } catch (e) {
      // Rollback
      _notifications[index] = existing;
      _unreadCount = (_unreadCount + 1);
      notifyListeners();
      rethrow;
    }
  }

  /// Optimistically marks all notifications as read via PATCH /api/notifications/read-all
  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty) return;

    final backupList = List<AppNotification>.from(_notifications);
    final backupCount = _unreadCount;

    // Optimistic update
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _apiClient.patch('/notifications/read-all');
    } catch (e) {
      // Rollback
      _notifications = backupList;
      _unreadCount = backupCount;
      notifyListeners();
      rethrow;
    }
  }

  /// Optimistically deletes a notification via DELETE /api/notifications/{id}
  Future<void> deleteNotification(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index == -1) return;

    final backupItem = _notifications[index];

    // Optimistic update
    _notifications.removeAt(index);
    if (!backupItem.isRead) {
      _unreadCount = (_unreadCount - 1).clamp(0, 9999);
    }
    notifyListeners();

    try {
      await _apiClient.delete('/notifications/$notificationId');
    } catch (e) {
      // Rollback
      _notifications.insert(index, backupItem);
      if (!backupItem.isRead) {
        _unreadCount++;
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Clears notifications state on logout
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
