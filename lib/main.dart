import 'package:fikraa/screens/data_screen.dart';
import 'package:fikraa/screens/my_firebase_messaging_service.dart';
import 'package:fikraa/screens/user_management_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fikraa/screens/welcome_screen.dart';
import 'package:fikraa/theme/theme.dart';
import 'package:fikraa/screens/home_screen.dart';
import 'package:fikraa/screens/temperature.dart';
import 'package:fikraa/screens/energy.dart';
import 'package:fikraa/screens/entertainment.dart';
import 'package:fikraa/screens/water.dart';
import 'package:fikraa/screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode, // Use your custom theme
      home: const WelcomeScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/temperature': (context) => const TemperaturePage(),
        '/energy': (context) => const EnergyPage(),
        '/water': (context) => const WaterPage(),
        '/entertainment': (context) => const GasControlPage(), // Ensure this is correct
        '/welcome': (context) => const WelcomeScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/data': (context) => DataScreen(),
      },
    );
  }
}
