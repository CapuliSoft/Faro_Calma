import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';

class ProgressService extends ChangeNotifier {
  ProgressService._internal();
  static final ProgressService instance = ProgressService._internal();

  static const String _prefKey = 'gtc6_user_stats';
  late SharedPreferences _prefs;
  UserStats _stats = UserStats.empty();
  bool _initialized = false;

  UserStats get stats => _stats;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    final jsonStr = _prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(jsonStr);
        _stats = UserStats.fromJson(decoded);
      } catch (e) {
        debugPrint('[ProgressService] Error loading stats: $e');
        _stats = UserStats.empty();
      }
    } else {
      _stats = UserStats.empty();
    }
    
    _initialized = true;
    checkAndVerifyStreak();
    notifyListeners();
  }

  /// Verifies if the streak has been broken (last active date was before yesterday)
  void checkAndVerifyStreak() {
    if (_stats.activeDays.isEmpty) return;

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final yesterdayStr = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];

    // Sort active days to ensure order
    final sortedDays = List<String>.from(_stats.activeDays)..sort();
    final lastActiveStr = sortedDays.last;

    if (lastActiveStr != todayStr && lastActiveStr != yesterdayStr) {
      _stats = _stats.copyWith(streakCount: 0);
      _saveStats();
    }
  }

  /// Registers today's date as active and recalculates the streak
  void recordActiveDay() {
    if (!_initialized) return;

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    if (_stats.activeDays.contains(todayStr)) return;

    final newActiveDays = List<String>.from(_stats.activeDays)..add(todayStr);
    newActiveDays.sort(); // Sort ascending

    int currentStreak = 1;
    if (_stats.activeDays.isNotEmpty) {
      final yesterdayStr = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
      final lastActiveStr = _stats.activeDays.last; // Since it was sorted

      if (lastActiveStr == yesterdayStr) {
        currentStreak = _stats.streakCount + 1;
      } else if (lastActiveStr == todayStr) {
        currentStreak = _stats.streakCount;
      } else {
        currentStreak = 1;
      }
    }

    final newLongest = currentStreak > _stats.longestStreak ? currentStreak : _stats.longestStreak;

    _stats = _stats.copyWith(
      activeDays: newActiveDays,
      streakCount: currentStreak,
      longestStreak: newLongest,
    );
    _saveStats();
  }

  /// Records a completed session, increments totals and logs activity playtime
  void recordSession(String gameKey, double durationMinutes) {
    if (!_initialized) return;

    // Ensure active day is recorded
    recordActiveDay();

    final newActivityCounts = Map<String, int>.from(_stats.activityCounts);
    newActivityCounts[gameKey] = (newActivityCounts[gameKey] ?? 0) + 1;

    _stats = _stats.copyWith(
      totalPlaytimeMinutes: _stats.totalPlaytimeMinutes + durationMinutes,
      totalSessions: _stats.totalSessions + 1,
      activityCounts: newActivityCounts,
    );
    _saveStats();
  }

  /// Reset all stats back to 0/empty
  Future<void> resetProgress() async {
    if (!_initialized) return;
    _stats = UserStats.empty();
    await _saveStats();
  }

  Future<void> _saveStats() async {
    final jsonStr = json.encode(_stats.toJson());
    await _prefs.setString(_prefKey, jsonStr);
    notifyListeners();
  }
}
