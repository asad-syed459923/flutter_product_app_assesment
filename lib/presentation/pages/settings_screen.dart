import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            theme,
            children: [
              Obx(() => ListTile(
                leading: Icon(Icons.dark_mode_rounded, color: theme.colorScheme.primary),
                title: Text('dark_mode'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Switch.adaptive(
                  value: controller.isDarkMode.value,
                  onChanged: (val) => controller.toggleTheme(val),
                ),
              )),
              const Divider(indent: 56),
              ListTile(
                leading: Icon(Icons.language_rounded, color: theme.colorScheme.primary),
                title: Text('language'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.currentLocale.value.languageCode,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: [
                      DropdownMenuItem(value: 'en', child: Text('english'.tr)),
                      DropdownMenuItem(value: 'ur', child: Text('urdu'.tr)),
                    ],
                    onChanged: (val) {
                      if (val != null) controller.changeLanguage(val);
                    },
                  ),
                )),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSettingsSection(
            theme,
            children: [
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  return ListTile(
                    leading: Icon(Icons.info_outline_rounded, color: Colors.grey[600]),
                    title: Text('version'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      snapshot.hasData 
                        ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                        : '...',
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
