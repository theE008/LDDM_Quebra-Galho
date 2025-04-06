import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import '../utils/geo_utils.dart';

class GPSAreaCalculator extends StatefulWidget {
  @override
  _GPSAreaCalculatorState createState() => _GPSAreaCalculatorState();
}

class _GPSAreaCalculatorState extends State<GPSAreaCalculator> {
  List<Position> points = [];
  double area = 0.0;
  final MapController mapController = MapController();

  Future<void> _markPoint() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      if (points.length < 4) {
        points.add(position);

        // Move a câmera do mapa para o novo ponto
        mapController.move(
          LatLng(position.latitude, position.longitude),
          mapController.camera.zoom, // Ajustado para a nova API
        );
      }
      if (points.length == 4) {
        area = calculateArea(points);
      }
    });
  }

  List<Marker> _buildMarkers() {
    return points.asMap().entries.map((entry) {
      final index = entry.key;
      final pos = entry.value;
      return Marker(
        width: 40,
        height: 40,
        point: LatLng(pos.latitude, pos.longitude),
        child: Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = points.isNotEmpty
        ? LatLng(points.last.latitude, points.last.longitude)
        : LatLng(-15.793889, -47.882778); // Brasília como fallback

    return Scaffold(
      appBar: AppBar(title: Text("Calculadora de Área GPS")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Cantos arredondados
              child: Container(
                height: 450, // 👈 altura customizável
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12), // opcional: borda fina
                ),
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: _buildMarkers()),
                    CurrentLocationLayer(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Pontos marcados: ${points.length}/4",
                        style: TextStyle(
                          color: Colors.white, // Cor do texto),
                        ),
                  ),
                  if (points.length == 4)
                    Text("Área: ${area.toStringAsFixed(2)} m²"),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _markPoint,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          "Marcar Ponto",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1C4352), // Cor de fundo
                          foregroundColor: Colors.white, // Cor do texto/ícone
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(width: 12), // Espaço entre os botões
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            points.clear();
                            area = 0.0;
                          });
                        },
                        icon: Icon(Icons.delete, color: Colors.white),
                        label: Text(
                          "Resetar",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2A2A2A), // Cor de fundo do botão resetar
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
