import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../telas/gps_area_calculator.dart';
import '../telas/map_screen.dart';
import '../telas/settings.dart';
import '../telas/compass_screen.dart';
import '../telas/about_screen.dart';

class BottomNavBar extends StatelessWidget {
  final PersistentTabController controller;

  BottomNavBar({Key? key, required this.controller}) : super(key: key);

  List<Widget> _buildScreens() {
    return [
      GPSAreaCalculator(),
      CompassScreen(),
      SettingsScreen(),
      AboutScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final activeColor = theme.bottomNavigationBarTheme.selectedItemColor ?? cs.primary;
    final inactiveColor = theme.bottomNavigationBarTheme.unselectedItemColor ?? cs.onSurface.withOpacity(0.6);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.calculate),
        title: "Calculadora",
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.explore),
        title: "Bússola",
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        title: "Ajustes",
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.info),
        title: "Sobre",
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navBg = theme.bottomNavigationBarTheme.backgroundColor ?? theme.colorScheme.surface;

    return PersistentTabView(
      context,
      controller: controller,
      screens: _buildScreens(),
      items: _navBarsItems(context),
      backgroundColor: navBg,
      confineToSafeArea: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarStyle: NavBarStyle.style3,
    );
  }
}
