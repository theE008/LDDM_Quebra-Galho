import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import '../utils/geo_utils.dart';
import '../utils/area_model.dart';
import 'saved_areas_screen.dart';

class GPSAreaCalculator extends StatefulWidget {
  @override
  _GPSAreaCalculatorState createState() => _GPSAreaCalculatorState();
}

class _GPSAreaCalculatorState extends State<GPSAreaCalculator> {
  List<Position> points = [];
  double area = 0.0;
  final MapController mapController = MapController();
  static List<SavedArea> savedAreas = [];

  Future<void> _markPoint() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      if (points.length < 4) {
        points.add(position);
        mapController.move(
          LatLng(position.latitude, position.longitude),
          mapController.camera.zoom,
        );
      }
      if (points.length == 4) {
        area = calculateArea(points);
      }
    });
  }

  void _saveArea() {
    savedAreas.add(SavedArea(points: List.from(points), area: area));
    setState(() {
      points.clear();
      area = 0.0;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedAreasScreen(savedAreas: savedAreas),
      ),
    );
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
        : LatLng(-19.912998, -43.940933);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/app/logo.png',
          height: 40,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 450,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12),
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
                  Text(
                    "Pontos marcados: ${points.length}/4",
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (points.length == 4)
                    Text("Área: ${area.toStringAsFixed(2)} m²"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _markPoint,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Marcar Ponto",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C4352),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            points.clear();
                            area = 0.0;
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Resetar",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2A2A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (points.length == 4) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _saveArea,
                      icon: const Icon(Icons.save),
                      label: const Text("Salvar Área"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
