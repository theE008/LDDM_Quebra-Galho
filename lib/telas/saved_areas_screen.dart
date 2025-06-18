import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quebra_galho/telas/gps_area_calculator.dart';
import '../DataBase/Banco_de_Dados.dart';
import '../utils/area_model.dart';
import 'main_screen.dart';
import 'package:provider/provider.dart';           
import '../utils/theme_provider.dart';


class SavedAreasScreen extends StatefulWidget {
  @override
  State<SavedAreasScreen> createState() => _SavedAreasScreenState();
}

class _SavedAreasScreenState extends State<SavedAreasScreen> {
  List<SavedArea> savedAreas = [];
  List<int> areaIds = [];

  @override
  void initState() {
    super.initState();
    _loadSavedAreas();
  }

  Future<void> _loadSavedAreas() async {
    final db = Banco_de_dados();
    List<Map<String, dynamic>> areasData = await db.buscarAreas();
    List<SavedArea> areasList = [];
    List<int> ids = [];
    

    for (var areaData in areasData) {
      int areaId = areaData['id'];
      double areaValue = areaData['area'];
      List<Map<String, dynamic>> pointsData = await db.buscarPontos(areaId);
      String titulo = areaData['titulo'] ?? 'Sem título';

      List<Position> points = pointsData.map((point) {
        return Position(
          latitude: point['latitude'],
          longitude: point['longitude'],
          altitude: point['altitude'],
          accuracy: point['accuracy'],
          speed: point['speed'],
          heading: point['heading'],
          speedAccuracy: point['speedAccuracy'],
          timestamp: DateTime.tryParse(point['timestamp'] ?? '') ?? DateTime.now(),
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
          isMocked: false,
        );
      }).toList();

      ids.add(areaId);
      areasList.add(SavedArea(titulo: titulo, points: points, area: areaValue));
    }

    setState(() {
      savedAreas = areasList;
      areaIds = ids;
    });
  }

  void _deleteArea(int index) async {
    int areaId = areaIds[index];
    await Banco_de_dados().deletarArea(areaId);
    setState(() {
      savedAreas.removeAt(index);
      areaIds.removeAt(index);
    });
  }

void _editarArea(int index) async {
  final areaAtual = savedAreas[index];
  final areaId = areaIds[index];
  final controller = TextEditingController(text: areaAtual.titulo);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Editar Título da Área"),
        content: TextField(
          controller: controller,
          cursorColor: Colors.greenAccent,
          decoration: InputDecoration(
            labelText: "Título",
            labelStyle: TextStyle(color: Colors.greenAccent),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white30, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.tealAccent, // Cor do texto do botão
            ),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final novoTitulo = controller.text.trim();
              if (novoTitulo.isNotEmpty) {
                await Banco_de_dados().atualizarTituloArea(areaId, novoTitulo);
                _loadSavedAreas(); // recarrega os cards
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent, // Fundo verde
              foregroundColor: Colors.black,        // Texto preto para contraste
            ),
            child: Text("Salvar"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          Theme.of(context).brightness == Brightness.light
                    ? 'assets/app/logo_light.png'
                    : 'assets/app/logo_dark.png',
          height: 40,
        ),
      ),
      body: savedAreas.isEmpty
          ? const Center(child: Text("Nenhuma área salva."))
          : ListView.builder(
              itemCount: savedAreas.length,
              itemBuilder: (context, index) {
                final area = savedAreas[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(area.titulo ?? 'Sem título'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Área: ${area.area.toStringAsFixed(2)} m²"),
                        const SizedBox(height: 4),
                        ...area.points.asMap().entries.map((entry) {
                          final index = entry.key + 1;
                          final p = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              "Ponto $index: (${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)})",
                              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                          );
                        }),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarArea(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteArea(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}