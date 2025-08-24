// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mero_vidya_library/screens/user_screen.dart';
// import 'package:url_strategy/url_strategy.dart'; // <-- For clean URLs on web

import 'screens/class_list_screen.dart';

void main() {
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
      // home: const CustomLoginScreen(),
      home: const ClassListScreen(),
    );
  }
}
