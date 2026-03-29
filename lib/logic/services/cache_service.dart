import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Cache keys used across the app.
class CacheKeys {
  static const String userData = 'cache_user_data';
  static const String enrolledCourses = 'cache_enrolled_courses';
  static const String upcomingSessions = 'cache_upcoming_sessions';
  static const String activeSessions = 'cache_active_sessions';
  static const String attendanceSummary = 'cache_attendance_summary';
  static const String attendanceHistory = 'cache_attendance_history';
}

/// TTL (time-to-live) per cache key, in minutes.
class CacheTTL {
  static const int userData = 60 * 24; // 24 hours — rarely changes
  static const int enrolledCourses = 60; // 1 hour
  static const int upcomingSessions = 5; // 5 minutes — changes daily
  static const int activeSessions = 1; // 1 minute — near real-time
  static const int attendanceSummary = 10; // 10 minutes — computed on server
  static const int attendanceHistory = 10; // 10 minutes
}

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  /// Initialize with an already-created [SharedPreferences] instance.
  /// Call this once from main() before the app starts.
  Future<void> initWithPrefs(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  /// Lazily initialize — safe to call from anywhere in case initWithPrefs
  /// wasn't called first (e.g. in tests or isolated widgets).
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'CacheService.init() must be called before use.');
    return _prefs!;
  }

  // ---------------------------------------------------------------------------
  // Core read / write
  // ---------------------------------------------------------------------------

  /// Write a value to the cache with a TTL in minutes.
  Future<void> write(String key, dynamic value, {required int ttlMinutes}) async {
    try {
      final entry = {
        'data': value,
        'expires_at': DateTime.now()
            .add(Duration(minutes: ttlMinutes))
            .millisecondsSinceEpoch,
      };
      await _p.setString(key, jsonEncode(entry));
    } catch (e) {
      debugPrint('CacheService.write error for "$key": $e');
    }
  }

  /// Read a value from the cache.
  /// Returns null if the key doesn't exist or has expired.
  T? read<T>(String key) {
    try {
      final raw = _p.getString(key);
      if (raw == null) return null;

      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = entry['expires_at'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        // Expired — clean up silently
        _p.remove(key);
        return null;
      }

      return entry['data'] as T?;
    } catch (e) {
      debugPrint('CacheService.read error for "$key": $e');
      return null;
    }
  }

  /// Read a value even if it's expired (stale). Useful for showing
  /// old data while fetching fresh data in the background.
  T? readStale<T>(String key) {
    try {
      final raw = _p.getString(key);
      if (raw == null) return null;
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      return entry['data'] as T?;
    } catch (e) {
      debugPrint('CacheService.readStale error for "$key": $e');
      return null;
    }
  }

  bool isExpired(String key) {
    try {
      final raw = _p.getString(key);
      if (raw == null) return true;
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = entry['expires_at'] as int;
      return DateTime.now().millisecondsSinceEpoch > expiresAt;
    } catch (_) {
      return true;
    }
  }

  Future<void> delete(String key) async {
    await _p.remove(key);
  }

  /// Clear all cached data — call this on logout so the next user
  /// starts with a clean slate.
  Future<void> clearAll() async {
    final keys = [
      CacheKeys.userData,
      CacheKeys.enrolledCourses,
      CacheKeys.upcomingSessions,
      CacheKeys.activeSessions,
      CacheKeys.attendanceSummary,
      CacheKeys.attendanceHistory,
    ];
    for (final key in keys) {
      await _p.remove(key);
    }
    debugPrint('CacheService: all cache cleared.');
  }
}
