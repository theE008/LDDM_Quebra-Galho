import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../telas/gps_area_calculator.dart';
import '../telas/map_screen.dart';
import '../telas/settings.dart';

class BottomNavBar extends StatelessWidget {
  final PersistentTabController controller;

  BottomNavBar({Key? key, required this.controller}) : super(key: key);

  List<Widget> _buildScreens() {
    return [
      GPSAreaCalculator(),
      MapScreen(),
      SettingsScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calculate),
        title: "Calculadora",
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.map),
        title: "Mapa",
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: "Config",
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: Colors.grey,
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
      backgroundColor: const Color.fromARGB(255, 236, 235, 235),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarStyle: NavBarStyle.style3,
    );
  }
}
