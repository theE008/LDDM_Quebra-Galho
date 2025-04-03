import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/geo_utils.dart';

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
        area = calculateArea(points);
      }
    });
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
            if (points.length == 4) Text("Área: ${area.toStringAsFixed(2)} m²"),
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
