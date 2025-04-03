import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      GPSAreaCalculator(),
      Center(child: Text("Mapa (Em desenvolvimento)")),
      Center(child: Text("Configurações (Em desenvolvimento)")),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calculate),
        title: ("Calculadora"),
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.map),
        title: ("Mapa"),
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: ("Config"),
        activeColorPrimary: const Color.fromARGB(255, 28, 67, 82),
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
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

class GPSAreaCalculator extends StatefulWidget {
  @override
  _GPSAreaCalculatorState createState() => _GPSAreaCalculatorState();
}

class _GPSAreaCalculatorState extends State<GPSAreaCalculator> {
  List<Position> points = [];
  double area = 0.0;

  Future<void> _markPoint() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      if (points.length < 4) {
        points.add(position);
      }
      if (points.length == 4) {
        area = _calculateArea();
      }
    });
  }

  double _calculateArea() {
    if (points.length < 4) return 0.0;
    double lat1 = points[0].latitude;
    double lon1 = points[0].longitude;
    double lat2 = points[1].latitude;
    double lon2 = points[1].longitude;
    double lat3 = points[2].latitude;
    double lon3 = points[2].longitude;
    double lat4 = points[3].latitude;
    double lon4 = points[3].longitude;

    double d1 = _haversine(lat1, lon1, lat2, lon2);
    double d2 = _haversine(lat2, lon2, lat3, lon3);
    double d3 = _haversine(lat3, lon3, lat4, lon4);
    double d4 = _haversine(lat4, lon4, lat1, lon1);

    double s = (d1 + d2 + d3 + d4) / 2;
    return sqrt((s - d1) * (s - d2) * (s - d3) * (s - d4));
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371e3;
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculadora de Área GPS")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pontos marcados: ${points.length}/4"),
            if (points.length == 4)
              Text("Área: ${area.toStringAsFixed(2)} m²"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _markPoint,
              child: Text("Marcar Ponto"),
            ),
            if (points.isNotEmpty)
              ElevatedButton(
                onPressed: () => setState(() {
                  points.clear();
                  area = 0.0;
                }),
                child: Text("Resetar"),
              ),
          ],
        ),
      ),
    );
  }
}