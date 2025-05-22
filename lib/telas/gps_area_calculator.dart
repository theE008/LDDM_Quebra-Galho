import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';

import '../DataBase/Banco_de_Dados.dart';
import '../utils/area_model.dart';
import 'saved_areas_screen.dart';
import '../utils/geo_utils.dart';

class GPSAreaCalculator extends StatefulWidget {
  @override
  _GPSAreaCalculatorState createState() => _GPSAreaCalculatorState();
}

class _GPSAreaCalculatorState extends State<GPSAreaCalculator> {
  LatLng? currentLocation;
  List<Position> points = [];
  double area = 0.0;
  final MapController mapController = MapController();

  Future<void> _markPoint() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

  

    Future<void> _getCurrentLocation() async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });
      } catch (e) {
        print('Erro ao obter localização atual: $e');
      }
    }
    void initState() {
      super.initState();
      _getCurrentLocation();
    }

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

  void _abrirModalSalvarArea() {
  TextEditingController tituloController = TextEditingController();

  showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: const Color(0xFF1C1C1C),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView( // Garante que tudo seja visível ao abrir o teclado
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Salvar Área",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tituloController,
                decoration: InputDecoration(
                  labelText: "Título da Área",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                "Pontos Marcados:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: points.length,
                  itemBuilder: (context, index) {
                    final p = points[index];
                    return Text(
                      "Ponto ${index + 1}: (${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)})",
                      style: const TextStyle(color: Colors.white70),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final titulo = tituloController.text.trim().isEmpty
                      ? "Área sem título"
                      : tituloController.text.trim();

                  try {
                    final areaId = await Banco_de_dados().salvarAreaComTitulo(area, titulo);
                    await Banco_de_dados().salvarPontos(areaId, points);

                    if (!mounted) return;

                    setState(() {
                      points.clear();
                      area = 0.0;
                    });

                    await Navigator.of(context).maybePop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SavedAreasScreen()),
                    );
                  } catch (e, stacktrace) {
                    debugPrint('Erro ao salvar área: $e\n$stacktrace');
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text("Confirmar e Salvar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
    },
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
  Widget build(BuildContext context) 
  {
    final bool modoEscuro = Theme.of(context).brightness == Brightness.dark;

    final initialCenter = currentLocation ??
    (points.isNotEmpty
        ? LatLng(points.last.latitude, points.last.longitude)
        : LatLng(-19.912998, -43.940933));

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                  onTap: (tapPosition, latlng) {
                    setState(() {
                      if (points.length < 4) {
                        points.add(Position(
                          latitude: latlng.latitude,
                          longitude: latlng.longitude,
                          timestamp: DateTime.now(),
                          accuracy: 0,
                          altitude: 0,
                          heading: 0,
                          speed: 0,
                          speedAccuracy: 0,
                          altitudeAccuracy: 0,
                          headingAccuracy: 0,
                          isMocked: false,
                        ));
                        if (points.length == 4) {
                          area = calculateArea(points);
                        }
                      }
                    });
                  },
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
                    style: TextStyle(color: (modoEscuro)? Colors.white : Colors.black),
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
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.85),
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
                    const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SavedAreasScreen()),
                            );
                          },
                          icon: const Icon(Icons.bookmark, color: Colors.white),
                          tooltip: 'Ver áreas salvas',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                            shape: const CircleBorder(),
                          ),
                        ),
                    ],
                  ),
                  if (points.length == 4) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _abrirModalSalvarArea,
                      icon: const Icon(Icons.save),
                      label: const Text("Salvar Área"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.85),
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
