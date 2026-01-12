import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/datasources/db_service.dart';

class SettingsController extends GetxController {
  final DbService dbService = Get.find();
  var isDarkMode = false.obs;
  var currentLocale = const Locale('en', 'US').obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final theme = await dbService.getSetting('theme');
    if (theme == 'dark') {
      isDarkMode.value = true;
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      isDarkMode.value = false;
      Get.changeThemeMode(ThemeMode.light);
    }

    final language = await dbService.getSetting('language');
    if (language == 'ur') {
      currentLocale.value = const Locale('ur', 'PK');
      Get.updateLocale(currentLocale.value);
    } else {
      currentLocale.value = const Locale('en', 'US');
      Get.updateLocale(currentLocale.value);
    }
  }

  void toggleTheme(bool isDark) {
    isDarkMode.value = isDark;
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    dbService.saveSetting('theme', isDark ? 'dark' : 'light');
  }

  void changeLanguage(String languageCode) {
    if (languageCode == 'ur') {
      currentLocale.value = const Locale('ur', 'PK');
    } else {
      currentLocale.value = const Locale('en', 'US');
    }
    Get.updateLocale(currentLocale.value);
    dbService.saveSetting('language', languageCode);
  }
}
