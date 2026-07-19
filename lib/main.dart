import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routes/app_routes.dart';

import 'core/dependency_injection/injection.dart';
import 'core/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DependencyInjection.bindings();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final role = prefs.getString('role');
  
  String initialRoute = AppPages.initial;
  
  if (token != null && token.isNotEmpty) {
    if (role?.toUpperCase() == 'COACH') {
      initialRoute = AppRoutes.adminhome;
    } else {
      initialRoute = AppRoutes.home;
    }
  }

  runApp(
    MyApp(initialRoute: initialRoute),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, this.initialRoute = AppPages.initial});

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

      title: 'Zeustucker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xffF8F9FA).withValues(alpha: 0.99),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}