import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/event_controller.dart';
import 'controllers/ticket_controller.dart';
import 'screens/splash_screen.dart';
import 'services/local_db_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await LocalDbService.init();

  await NotificationService.instance.init();

  Get.put(AuthController());
  Get.put(EventController());
  Get.put(TicketController());

  runApp(const KonfetiApp());
}

class KonfetiApp extends StatelessWidget {
  const KonfetiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Konfeti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0C0A14),
        primaryColor: const Color(0xFF8B5CF6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFFEC4899),
          surface: Color(0xFF161326),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0C0A14),
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      defaultTransition: Transition.fade,
      home: const SplashScreen(),
    );
  }
}
