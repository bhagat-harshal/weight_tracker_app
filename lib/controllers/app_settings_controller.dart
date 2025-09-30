import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class AppSettingsController extends GetxController {
  var appSettings = AppSettings(
    frequency: LogFrequency.daily,
    reminderEnabled: true,
    reminderTime: const TimeOfDay(hour: 8, minute: 0),
    primaryColor: const Color(0xFF0A84FF),
  ).obs;

  void updateFrequency(LogFrequency frequency) {
    appSettings.update((val) {
      if (val != null) val.frequency = frequency;
    });
  }

  void updateReminderEnabled(bool enabled) {
    appSettings.update((val) {
      if (val != null) val.reminderEnabled = enabled;
    });
  }

  void updateReminderTime(TimeOfDay time) {
    appSettings.update((val) {
      if (val != null) val.reminderTime = time;
    });
  }

  void updatePrimaryColor(Color color) {
    appSettings.update((val) {
      if (val != null) val.primaryColor = color;
    });
  }

  void reset() {
    appSettings.value = AppSettings(
      frequency: LogFrequency.daily,
      reminderEnabled: true,
      reminderTime: const TimeOfDay(hour: 8, minute: 0),
      primaryColor: const Color(0xFF0A84FF),
    );
  }
}
