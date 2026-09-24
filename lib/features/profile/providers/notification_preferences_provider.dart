import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages customer notification preference toggles.
///
/// All values are persisted locally with [SharedPreferences].
/// Keys follow the convention `notif_<name>` to avoid collisions with
/// other features that also use shared_preferences.
class NotificationPreferencesProvider extends ChangeNotifier {
  static const _kNewOffers = 'notif_new_offers';
  static const _kInquiryUpdates = 'notif_inquiry_updates';
  static const _kWeddingReminders = 'notif_wedding_reminders';
  static const _kWeeklyDigest = 'notif_weekly_digest';
  static const _kPromotions = 'notif_promotions';

  bool _newOffers = true;
  bool _inquiryUpdates = true;
  bool _weddingReminders = true;
  bool _weeklyDigest = false;
  bool _promotions = false;

  bool get newOffers => _newOffers;
  bool get inquiryUpdates => _inquiryUpdates;
  bool get weddingReminders => _weddingReminders;
  bool get weeklyDigest => _weeklyDigest;
  bool get promotions => _promotions;

  NotificationPreferencesProvider() {
    _loadPreferences();
  }

  /// Reads stored preferences from disk on startup.
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _newOffers = prefs.getBool(_kNewOffers) ?? true;
      _inquiryUpdates = prefs.getBool(_kInquiryUpdates) ?? true;
      _weddingReminders = prefs.getBool(_kWeddingReminders) ?? true;
      _weeklyDigest = prefs.getBool(_kWeeklyDigest) ?? false;
      _promotions = prefs.getBool(_kPromotions) ?? false;
      notifyListeners();
    } catch (_) {
      // Fail silently — preferences are non-critical
    }
  }

  /// Toggles the New Offers notification and persists the value.
  Future<void> toggleNewOffers(bool value) async {
    _newOffers = value;
    notifyListeners();
    await _save(_kNewOffers, value);
  }

  /// Toggles the Inquiry Updates notification and persists the value.
  Future<void> toggleInquiryUpdates(bool value) async {
    _inquiryUpdates = value;
    notifyListeners();
    await _save(_kInquiryUpdates, value);
  }

  /// Toggles the Wedding Reminders notification and persists the value.
  Future<void> toggleWeddingReminders(bool value) async {
    _weddingReminders = value;
    notifyListeners();
    await _save(_kWeddingReminders, value);
  }

  /// Toggles the Weekly Digest notification and persists the value.
  Future<void> toggleWeeklyDigest(bool value) async {
    _weeklyDigest = value;
    notifyListeners();
    await _save(_kWeeklyDigest, value);
  }

  /// Toggles the Promotions notification and persists the value.
  Future<void> togglePromotions(bool value) async {
    _promotions = value;
    notifyListeners();
    await _save(_kPromotions, value);
  }

  Future<void> _save(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      // Fail silently
    }
  }

  /// Resets all preferences to defaults (called on sign-out if needed).
  Future<void> resetAll() async {
    _newOffers = true;
    _inquiryUpdates = true;
    _weddingReminders = true;
    _weeklyDigest = false;
    _promotions = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kNewOffers);
      await prefs.remove(_kInquiryUpdates);
      await prefs.remove(_kWeddingReminders);
      await prefs.remove(_kWeeklyDigest);
      await prefs.remove(_kPromotions);
    } catch (_) {}
  }
}
