import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_profile_controller.dart';
import '../controllers/app_settings_controller.dart';
import '../controllers/weight_controller.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final UserProfileController userProfileController;
  late final AppSettingsController appSettingsController;
  late final WeightController weightController;

  late TextEditingController nameController;
  late TextEditingController heightController;
  late TextEditingController targetWeightController;

  @override
  void initState() {
    super.initState();
    userProfileController = Get.find<UserProfileController>();
    appSettingsController = Get.find<AppSettingsController>();
    weightController = Get.find<WeightController>();

    // Initialize controllers with current values
    nameController = TextEditingController(
      text: userProfileController.userProfile.value.name,
    );
    heightController = TextEditingController(
      text: userProfileController.userProfile.value.height.toString(),
    );
    targetWeightController = TextEditingController(
      text: userProfileController.userProfile.value.targetWeight.toString(),
    );

    // Keep fields in sync if profile changes
    ever<UserProfile>(userProfileController.userProfile, (profile) {
      if (nameController.text != profile.name) {
        nameController.text = profile.name;
      }
      if (heightController.text != profile.height.toString()) {
        heightController.text = profile.height.toString();
      }
      if (targetWeightController.text != profile.targetWeight.toString()) {
        targetWeightController.text = profile.targetWeight.toString();
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    heightController.dispose();
    targetWeightController.dispose();
    super.dispose();
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            _sectionTitle(context, 'User Info'),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        onChanged: userProfileController.updateName,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => userProfileController
                            .updateHeight(double.tryParse(v) ?? 0.0),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: targetWeightController,
                        decoration: const InputDecoration(
                          labelText: 'Target Weight',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => userProfileController
                            .updateTargetWeight(double.tryParse(v) ?? 0.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, 'App Preferences'),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final profile = userProfileController.userProfile.value;
                final settings = appSettingsController.appSettings.value;
                final isKg = profile.unit == WeightUnit.kg;
                final isDaily = settings.frequency == LogFrequency.daily;
                return Card(
                  child: Column(
                    children: [
                      // Weight unit switch (KG/LB)
                      SwitchListTile(
                        title: const Text('Weight:'),
                        subtitle: Text(isKg ? 'Kilograms (kg)' : 'Pounds (lb)'),
                        value: isKg,
                        onChanged: (val) {
                          userProfileController.updateUnit(
                              val ? WeightUnit.kg : WeightUnit.lb);
                        },
                      ),
                      const Divider(height: 1),
                      // Frequency toggle
                      SwitchListTile(
                        title: const Text('Frequency'),
                        subtitle: Text(isDaily ? 'Daily' : 'Weekly'),
                        value: isDaily,
                        onChanged: (val) {
                          appSettingsController.updateFrequency(
                              val ? LogFrequency.daily : LogFrequency.weekly);
                        },
                      ),
                      const Divider(height: 1),
                      // Reminder notifications
                      SwitchListTile(
                        title: const Text('Reminder Notifications'),
                        value: settings.reminderEnabled,
                        onChanged: appSettingsController.updateReminderEnabled,
                      ),
                      ListTile(
                        title: const Text('Time'),
                        subtitle: Text(settings.reminderTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: settings.reminderTime,
                          );
                          if (picked != null) {
                            appSettingsController.updateReminderTime(picked);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, 'Theme'),
            const SizedBox(height: 8),
            // Simple preset primary color choices like the mock accent
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final current = appSettingsController.appSettings.value.primaryColor;
                final options = <Color>[
                  const Color(0xFF0A84FF), // blue
                  const Color(0xFF10B981), // green
                  const Color(0xFFF43F5E), // red/pink
                  const Color(0xFF8B5CF6), // purple
                ];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: options.map((c) {
                        final selected = c.value == current.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => appSettingsController.updatePrimaryColor(c),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset All Data'),
                      content: const Text(
                          'Are you sure you want to delete all records? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    userProfileController.reset();
                    appSettingsController.reset();
                    weightController.reset();
                    Get.snackbar(
                      'Reset',
                      'All data has been cleared',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
                child: const Text('Reset All Data'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
