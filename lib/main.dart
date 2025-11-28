import 'package:flutter/material.dart';
import 'package:siakad/pages/splash_screen.dart';
import 'package:siakad/pages/welcome_page.dart';
import 'package:siakad/pages/login_pages.dart';
import 'package:siakad/pages/register_pages.dart';
import 'package:siakad/widgets/bottom_nav.dart'; // halaman utama (navbar + dashboard)
// ignore: avoid_web_libraries_in_flutter
// ignore: avoid_web_libraries_in_flutter

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KELOMPOK 9',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C7F9A)),
        primaryColor: const Color(0xFF4C7F9A),
        scaffoldBackgroundColor: const Color(0xFFFDF7EE),
        useMaterial3: true,
      ),

      // 🔹 Semua rute aplikasi didefinisikan di sini
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPages(),
        '/register': (context) => const RegisterPages(),
        '/main': (context) => const BottomNav(), // berisi dashboard + navbar
      },

      // 🔹 Ini halaman pertama yang muncul saat app dibuka
      home: const SplashScreen(),

      // 🔹 Buat layout responsif tengah (biar UI nggak melebar di tablet/desktop)
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(color: Colors.white, child: child),
          ),
        );
      },
    );
  }
}
