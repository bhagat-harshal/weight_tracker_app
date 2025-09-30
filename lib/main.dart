import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controllers/weight_controller.dart';
import 'controllers/user_profile_controller.dart';
import 'controllers/app_settings_controller.dart';
import 'theme/app_theme.dart';

import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Register controllers
  Get.put(WeightController());
  Get.put(UserProfileController());
  Get.put(AppSettingsController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettingsController = Get.find<AppSettingsController>();
    return Obx(() {
      final primary = appSettingsController.appSettings.value.primaryColor;
      return GetMaterialApp(
        title: 'Weight Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(primary),
        home: const MainShell(),
      );
    });
  }
}
