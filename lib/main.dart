// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/user_screen.dart';

void main() async {
  await GetStorage.init(); // 🔹 initialize storage

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MeroVidya Video Library',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(elevation: 1, centerTitle: true),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      // home: const ClassListScreen(),
    );
  }
}
