import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
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
    final cs = Theme.of(context).colorScheme;
    final inactive = Theme.of(context)
            .bottomNavigationBarTheme
            .unselectedItemColor ??
        cs.onSurface.withOpacity(0.6);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.calculate),
        title: "Calculadora",
        activeColorPrimary: cs.primary,
        inactiveColorPrimary: inactive,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.explore),
        title: "Bússola",
        activeColorPrimary: cs.primary,
        inactiveColorPrimary: inactive,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        title: "Ajustes",
        activeColorPrimary: cs.primary,
        inactiveColorPrimary: inactive,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.info),
        title: "Sobre",
        activeColorPrimary: cs.primary,
        inactiveColorPrimary: inactive,
      ),
    ];
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    final navBg = Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    return PersistentTabView(
      context,
      controller: controller,
      screens: _buildScreens(),
      items: _navBarsItems(context),       // agora passa o context
      backgroundColor: navBg,       // usa a cor do tema
      confineToSafeArea: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarStyle: NavBarStyle.style3,
    );
  }
}
