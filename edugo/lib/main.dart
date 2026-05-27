import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const EduGoApp());
}

class EduGoApp extends StatelessWidget {
  const EduGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1CB0F6)),
        textTheme: GoogleFonts.nunitoTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFBFF),
      ),
      home: const SplashScreen(),
    );
  }
}
