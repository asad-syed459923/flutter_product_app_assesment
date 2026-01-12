import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        children: [
          Obx(() => SwitchListTile(
            title: Text('dark_mode'.tr),
            value: controller.isDarkMode.value,
            onChanged: (val) => controller.toggleTheme(val),
          )),
          ListTile(
            title: Text('language'.tr),
            trailing: Obx(() => DropdownButton<String>(
              value: controller.currentLocale.value.languageCode,
              items: [
                DropdownMenuItem(value: 'en', child: Text('english'.tr)),
                DropdownMenuItem(value: 'ur', child: Text('urdu'.tr)),
              ],
              onChanged: (val) {
                if (val != null) controller.changeLanguage(val);
              },
            )),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListTile(
                  title: Text('version'.tr),
                  subtitle: Text('${snapshot.data!.version} (${snapshot.data!.buildNumber})'),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
