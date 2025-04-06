
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quebra_galho/widgets/splash_screen.dart';
import 'telas/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF121212), // 🔹 cor de fundo global
        brightness: Brightness.dark, // 🔹 widgets no estilo dark (AppBar, etc)
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

