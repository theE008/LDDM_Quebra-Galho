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
  final TextEditingController _cepController = TextEditingController();

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
  final tema = Theme.of(context);
  final isDark = tema.brightness == Brightness.dark;

  final corTextoPrincipal = isDark ? Colors.white : Colors.black87;
  final corTextoSecundario = isDark ? Colors.white70 : Colors.black54;
  final corFundoInput = isDark ? Colors.grey[800]! : Colors.grey[300]!;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: tema.appBarTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      content: StatefulBuilder(
      builder: (context, setStateDialog) => SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Salvar Área',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: corTextoPrincipal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: corTextoPrincipal,
                    tooltip: 'Fechar',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tituloController,
                decoration: InputDecoration(
                  labelText: 'Título da Área',
                  labelStyle: TextStyle(color: corTextoSecundario),
                  filled: true,
                  fillColor: corFundoInput,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: TextStyle(color: corTextoPrincipal),
              ),
              const SizedBox(height: 16),
              Text(
                'Pontos Marcados:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: corTextoPrincipal,
                ),
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
                      style: TextStyle(color: corTextoSecundario),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
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
                    Navigator.push(
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
                  backgroundColor: tema.colorScheme.primary.withOpacity(0.85),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            ),
           ),
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

  /* -------------------------------- Linha entre marcadores -------------- */

  List<Polyline> _buildPolyline(bool darkMode) {
  if (points.length < 2) return [];

  final latLngPoints = points.map((p) => LatLng(p.latitude, p.longitude)).toList();

  if (latLngPoints.length >= 3) {
    latLngPoints.add(latLngPoints.first); // Fecha o polígono
  }

  return [
    Polyline(
      points: latLngPoints, // <- usa a lista correta agora
      color: darkMode ? Colors.tealAccent : Colors.blueAccent,
      strokeWidth: 4.0,
    )
  ];
}

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
      title: Image.asset(
          Theme.of(context).brightness == Brightness.light
              ? 'assets/app/logo_light.png'
              : 'assets/app/logo_dark.png',
          height: 40),
    ),
    body: SafeArea(
      child: Column(
        children: [
          // Caixa de busca fixa em cima do mapa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _cepController,
                keyboardType: TextInputType.number,
                onSubmitted: _searchCep,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Buscar CEP...',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).canvasColor,
                ),
              ),
            ),
          ),

          // Agora o mapa com controles, ocupa o resto da tela
          Expanded(
            flex: 6, //tamanho do mapa
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      urlTemplate: Theme.of(context).brightness == Brightness.dark
                          ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                          : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                      retinaMode: RetinaMode.isHighDensity(context), // aqui você ativa o modo retina automaticamente
                    ),
                    PolylineLayer(polylines: _buildPolyline(dark)),
                    MarkerLayer(markers: _buildMarkers()),
                    const CurrentLocationLayer(),
                  ],
                ),
              ),
            ),
          ),

          // Controles embaixo do mapa
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
    )
   );
  }
}
