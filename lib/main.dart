import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/di/injection_container.dart';
import 'routes/app_pages.dart';
import 'translations/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DependencyInjection.init();

  runApp(const ProductAssessment());
}

class ProductAssessment extends StatelessWidget {
  const ProductAssessment({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Product Store',
      debugShowCheckedModeBanner: false,

      // Theme Management
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system, // Default system, overridden by controller
      // Localization
      translations: AppTranslations(),
      locale: const Locale('en', 'US'), // Default, overridden by controller
      fallbackLocale: const Locale('en', 'US'),

      // Navigation
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
