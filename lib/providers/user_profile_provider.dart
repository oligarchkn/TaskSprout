import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String? email;
  final String? avatarEmoji;
  final String? bio;
  final int dailyGoal;
  final bool notificationsEnabled;
  final String? workStartTime;
  final String? workEndTime;

  UserProfile({
    required this.name,
    this.email,
    this.avatarEmoji,
    this.bio,
    this.dailyGoal = 5,
    this.notificationsEnabled = true,
    this.workStartTime,
    this.workEndTime,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarEmoji': avatarEmoji,
        'bio': bio,
        'dailyGoal': dailyGoal,
        'notificationsEnabled': notificationsEnabled,
        'workStartTime': workStartTime,
        'workEndTime': workEndTime,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        email: json['email'],
        avatarEmoji: json['avatarEmoji'],
        bio: json['bio'],
        dailyGoal: json['dailyGoal'] ?? 5,
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        workStartTime: json['workStartTime'],
        workEndTime: json['workEndTime'],
      );

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarEmoji,
    String? bio,
    int? dailyGoal,
    bool? notificationsEnabled,
    String? workStartTime,
    String? workEndTime,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      bio: bio ?? this.bio,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
    );
  }
}

class UserProfileProvider extends ChangeNotifier {
  static const String _storageKey = 'user_profile';

  UserProfile _profile = UserProfile(name: 'User');

  UserProfile get profile => _profile;

  // Load profile from storage
  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString(_storageKey);

      if (profileJson != null) {
        final Map<String, dynamic> decoded = json.decode(profileJson);
        _profile = UserProfile.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
    notifyListeners();
  }

  // Save profile to storage
  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String profileJson = json.encode(_profile.toJson());
      await prefs.setString(_storageKey, profileJson);
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  // Update profile
  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();
    await _saveProfile();
  }

  // Update specific fields
  Future<void> updateName(String name) async {
    _profile = _profile.copyWith(name: name);
    notifyListeners();
    await _saveProfile();
  }

  Future<void> updateEmail(String? email) async {
    _profile = _profile.copyWith(email: email);
    notifyListeners();
    await _saveProfile();
  }

  Future<void> updateAvatarEmoji(String? emoji) async {
    _profile = _profile.copyWith(avatarEmoji: emoji);
    notifyListeners();
    await _saveProfile();
  }

  Future<void> updateBio(String? bio) async {
    _profile = _profile.copyWith(bio: bio);
    notifyListeners();
    await _saveProfile();
  }

  Future<void> updateDailyGoal(int goal) async {
    _profile = _profile.copyWith(dailyGoal: goal);
    notifyListeners();
    await _saveProfile();
  }

  Future<void> updateNotifications(bool enabled) async {
    _profile = _profile.copyWith(notificationsEnabled: enabled);
    notifyListeners();
    await _saveProfile();
  }

  Future<void> updateWorkHours(String? startTime, String? endTime) async {
    _profile = _profile.copyWith(
      workStartTime: startTime,
      workEndTime: endTime,
    );
    notifyListeners();
    await _saveProfile();
  }
}
