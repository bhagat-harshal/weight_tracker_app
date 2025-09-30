import 'package:flutter/material.dart';

enum LogFrequency { daily, weekly }

class AppSettings {
  LogFrequency frequency;
  bool reminderEnabled;
  TimeOfDay reminderTime;
  Color primaryColor;

  AppSettings({
    required this.frequency,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.primaryColor,
  });

  Map<String, dynamic> toMap() => {
        'frequency': frequency.index,
        'reminderEnabled': reminderEnabled,
        'reminderTime': '${reminderTime.hour}:${reminderTime.minute}',
        'primaryColor': primaryColor.value,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['reminderTime'] ?? '8:00').split(':');
    return AppSettings(
      frequency: LogFrequency.values[map['frequency'] ?? 0],
      reminderEnabled: map['reminderEnabled'] ?? false,
      reminderTime: TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 8,
        minute: int.tryParse(timeParts[1]) ?? 0,
      ),
      primaryColor: Color(map['primaryColor'] ?? 0xFF0A84FF),
    );
  }
}
