import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'core/dependency_injection/injection.dart';
import 'core/routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DependencyInjection.bindings();


  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),

      // builder: (context, child) {
      //   return DevicePreview.appBuilder(
      //     context,
      //     Scaffold(
      //       body: Container(
      //         width: double.infinity,
      //         height: double.infinity,
      //         decoration: const BoxDecoration(
      //           image: DecorationImage(
      //             image: AssetImage("assets/images/Property 1=background2.png"),
      //             fit: BoxFit.cover,
      //           ),
      //
      //         ),
      //         child: child,
      //       ),
      //     ),
      //   );
      // },

      title: 'Aura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
       scaffoldBackgroundColor: Color(0xffF8F9FA).withValues(alpha: 0.99),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}