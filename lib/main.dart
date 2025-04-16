import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'controllers/auth_controller.dart';
import 'controllers/place_controller.dart';
import 'controllers/route_controller.dart';
import 'controllers/chat_controller.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Always run after Firebase/init is complete
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize GetX Controllers here instead of before runApp to ensure context is available
    Get.put(AuthController(), permanent: true);
    Get.put(PlaceController(), permanent: true);
    Get.put(RouteController(), permanent: true);
    Get.put(ChatController(), permanent: true);

    return GetMaterialApp(
      title: 'Pakistan Tourism',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.accentColor,
          surface: AppColors.backgroundColor,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
