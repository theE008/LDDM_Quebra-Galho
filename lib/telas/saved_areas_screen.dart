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

  final tema = Theme.of(context);
  final isDark = tema.brightness == Brightness.dark;

  final corTitulo = isDark ? Colors.white : Colors.black87;
  final corLabel = isDark ? Colors.white70 : Colors.black54;
  final corCursor = tema.colorScheme.primary;
  final corBordaAtiva = tema.colorScheme.primary;
  final corBordaInativa = tema.dividerColor;
  final corFundoDialog = tema.dialogBackgroundColor;

  final corBotaoCancelar = tema.colorScheme.primary;
  final corBotaoSalvarFundo = tema.colorScheme.primary;
  final corBotaoSalvarTexto = isDark ? Colors.white : Colors.black;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: corFundoDialog,
        title: Text(
          "Editar Título da Área",
          style: TextStyle(color: corTitulo),
        ),
        content: TextField(
          controller: controller,
          cursorColor: corCursor,
          style: TextStyle(color: corTitulo),
          decoration: InputDecoration(
            labelText: "Título",
            labelStyle: TextStyle(color: corLabel),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: corBordaInativa, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: corBordaAtiva, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: corBotaoSalvarFundo,
              foregroundColor: corBotaoSalvarTexto, // texto do botão Cancelar
            ),
            child: const Text("Cancelar"),
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
              backgroundColor: corBotaoSalvarFundo, // fundo botão Salvar
              foregroundColor: corBotaoSalvarTexto,  // texto botão Salvar
            ),
            child: const Text("Salvar"),
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
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título e botões
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                area.titulo ?? 'Sem título',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editarArea(index),
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.green),
                                  onPressed: () {
                                    final texto = StringBuffer()
                                      ..writeln("Área: ${area.titulo}")
                                      ..writeln("Tamanho: ${area.area.toStringAsFixed(2)} m²")
                                      ..writeln("Pontos:");
                                    for (int i = 0; i < area.points.length; i++) {
                                      final p = area.points[i];
                                      texto.writeln("P${i + 1}: (${p.latitude}, ${p.longitude})");
                                    }
                                    // Share.share(texto.toString());
                                  },
                                  tooltip: 'Compartilhar',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteArea(index),
                                  tooltip: 'Deletar',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Área
                        Text(
                          "Área total: ${area.area.toStringAsFixed(2)} m²",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 12),

                        // Chips com rolagem horizontal e limite visual
                        SizedBox(
                          height: 40, // altura suficiente para 1 linha de chips
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: area.points.asMap().entries.map((entry) {
                              final i = entry.key + 1;
                              final p = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text(
                                    "P$i: ${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                ),
                              );
                            }).toList(),
                          ),
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