import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amanjalan/core/theme/app_colors.dart';
import 'package:amanjalan/features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Aplikasi dikunci mode potret (layar darurat dan peta dirancang untuk potret)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // ---------------------------------------------------------------
  // OPSIONAL (hanya untuk testing): hapus tanda komentar di bawah
  // supaya onboarding selalu muncul lagi. Jangan lupa import:
  // import 'package:shared_preferences/shared_preferences.dart';
  //
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.remove('seen_onboarding');
  // ---------------------------------------------------------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmanJalan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.plum,
          primary: AppColors.plum,
        ),
        scaffoldBackgroundColor: Colors.white,
        // Font body default Nunito (heading memakai Poppins langsung di tiap widget)
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      // Splash dulu. Setelah itu SplashScreen yang menentukan tujuan:
      // Home / Onboarding / Login (lihat _goNext di splash_screen.dart)
      home: const SplashScreen(),
    );
  }
}