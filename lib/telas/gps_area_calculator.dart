// lib/screens/gps_area_calculator.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../DataBase/Banco_de_Dados.dart';
import '../utils/geo_utils.dart';
import 'saved_areas_screen.dart';



class GPSAreaCalculator extends StatefulWidget {
  const GPSAreaCalculator({Key? key}) : super(key: key);

  @override
  State<GPSAreaCalculator> createState() => _GPSAreaCalculatorState();
}

class _GPSAreaCalculatorState extends State<GPSAreaCalculator> {
  LatLng? currentLocation;
  final List<Position> points = [];
  double area = 0.0;
  final MapController mapController = MapController();

  /* --------------------------- Localização inicial ------------------------ */
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /* ------------------------------ Buscar CEP   --------------------------- */
  
  Future<void> _searchCep(String cep) async {
    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final logradouro = data['logradouro'];
        final localidade = data['localidade'];
        final uf = data['uf'];

        final query = "$logradouro, $localidade, $uf, Brasil";
        final nominatimUrl = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json');
        final geoResponse = await http.get(nominatimUrl, headers: {
          'User-Agent': 'FlutterApp'
        });

        if (geoResponse.statusCode == 200) {
          final List<dynamic> results = json.decode(geoResponse.body);
          if (results.isNotEmpty) {
            final lat = double.parse(results[0]['lat']);
            final lon = double.parse(results[0]['lon']);
            mapController.move(LatLng(lat, lon), 16);
          }
        }
      }
    } catch (e) {
      print("Erro ao buscar CEP: $e");
    }
  
  }
  /* ------------------------------ Buscar CEP   --------------------------- */
  
  /* ------------------------------ Marcar ponto --------------------------- */
  Future<void> _markPoint() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      points.add(pos);
      mapController.move(
        LatLng(pos.latitude, pos.longitude),
        mapController.camera.zoom,
      );
      area = points.length >= 3 ? calculateArea(points) : 0.0;
    });
  }

  /* --------------------------- Modal salvar área ------------------------- */
  void _abrirModalSalvarArea() {
    final tituloController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Salvar Área',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título da Área',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pontos Marcados:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: points.length,
                    itemBuilder: (_, i) {
                      final p = points[i];
                      return Text(
                        'Ponto ${i + 1}: (${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)})',
                        style: const TextStyle(color: Colors.white70),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final titulo = tituloController.text.trim().isEmpty
                        ? 'Área sem título'
                        : tituloController.text.trim();
                    try {
                      final id = await Banco_de_dados().salvarAreaComTitulo(area, titulo);
                      await Banco_de_dados().salvarPontos(id, points);
                      if (!mounted) return;
                      setState(() {
                        points.clear();
                        area = 0.0;
                      });
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SavedAreasScreen()),
                      );
                    } catch (e, s) {
                      debugPrint('Erro ao salvar área: $e\n$s');
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar e Salvar'),
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
      ),
    );
  }

  /* ---------------------------- Marcadores mapa -------------------------- */
  List<Marker> _buildMarkers() => points
      .map(
        (p) => Marker(
          width: 40,
          height: 40,
          point: LatLng(p.latitude, p.longitude),
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      )
      .toList();

  /* --------------------------------  UI  -------------------------------- */
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final initialCenter = currentLocation ??
        (points.isNotEmpty
            ? LatLng(points.last.latitude, points.last.longitude)
            : const LatLng(-19.912998, -43.940933));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: Image.asset(Theme.of(context).brightness == Brightness.light
                    ? 'assets/app/logo_light.png'
                    : 'assets/app/logo_dark.png', height: 40),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /* -------------------- Mapa (flexível) -------------------- */
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: 16,
                      onTap: (_, latLng) {
                        setState(() {
                          points.add(
                            Position(
                              latitude: latLng.latitude,
                              longitude: latLng.longitude,
                              timestamp: DateTime.now(),
                              accuracy: 0,
                              altitude: 0,
                              heading: 0,
                              speed: 0,
                              speedAccuracy: 0,
                              altitudeAccuracy: 0,
                              headingAccuracy: 0,
                              isMocked: false,
                            ),
                          );
                          area = points.length >= 3 ? calculateArea(points) : 0.0;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(markers: _buildMarkers()),
                      const CurrentLocationLayer(),
                    ],
                  ),
                ),
              ),
            ),

            /* --------------- Controles (rolável se precisar) --------------- */
            Flexible(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'Pontos marcados: ${points.length}',
                      style: TextStyle(color: dark ? Colors.white : Colors.black),
                    ),
                    if (points.length >= 3)
                      Text(
                        'Área: ${area.toStringAsFixed(2)} m²',
                        style: TextStyle(color: dark ? Colors.white : Colors.black),
                      ),
                    const SizedBox(height: 16),

                    /* Linha de ações principais */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _markPoint,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Marcar Ponto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                          label: const Text('Resetar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A2A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

                    if (points.length >= 3) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _abrirModalSalvarArea,
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar Área'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
