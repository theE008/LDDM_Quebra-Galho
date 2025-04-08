import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../telas/gps_area_calculator.dart';
import '../telas/map_screen.dart';
import '../telas/settings.dart';
import '../telas/compass_screen.dart';

class BottomNavBar extends StatelessWidget {
  final PersistentTabController controller;

  BottomNavBar({Key? key, required this.controller}) : super(key: key);

  List<Widget> _buildScreens() {
    return [
      GPSAreaCalculator(),
      MapScreen(),
      CompassScreen(),
      SettingsScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calculate),
        title: "Calculadora",
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: const Color.fromARGB(255, 221, 220, 220),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.map),
        title: "Mapa",
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: const Color.fromARGB(255, 221, 220, 220),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.explore),
        title: "Bússola",
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: const Color.fromARGB(255, 221, 220, 220),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: "Ajustes",
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: const Color.fromARGB(255, 221, 220, 220),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: const Color(0xFF121212),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarStyle: NavBarStyle.style3,
    );
  }
}
