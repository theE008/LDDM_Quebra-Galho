import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quebra_galho/telas/gps_area_calculator.dart';
import '../DataBase/Banco_de_Dados.dart';
import '../utils/area_model.dart';
import 'main_screen.dart';
import 'package:provider/provider.dart';           
import '../utils/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedAreasScreen extends StatefulWidget {
  @override
  State<SavedAreasScreen> createState() => _SavedAreasScreenState();
}

class _SavedAreasScreenState extends State<SavedAreasScreen> {
  List<SavedArea> savedAreas = [];
  List<int> areaIds = [];
  bool isLoading = true;
  User? user;

  @override
  void initState() {
    super.initState();
    _registrarUsuario();
    _loadSavedAreas();
  }

  Future<void> _registrarUsuario() async {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (!doc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'uid': user!.uid,
        'email': user!.email,
      });
    }
  }

  Future<void> _loadSavedAreas() async {
    setState(() {
      isLoading = true;
      user = FirebaseAuth.instance.currentUser;
    });

    final db = Banco_de_dados();

    List<Map<String, dynamic>> areasData = await db.buscarAreas();
    List<SavedArea> areasList = [];
    List<int> ids = [];

    // Áreas locais (sempre)
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

    // Áreas compartilhadas só se logado
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('shared_areas')
          .where('sharedWith', arrayContains: user!.uid)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final titulo = data['title'] ?? 'Área compartilhada';
        final areaValue = (data['area'] ?? 0).toDouble();

        final pointsList = (data['points'] as List).map((p) {
          return Position(
            latitude: p['lat'],
            longitude: p['lng'],
            altitude: 0,
            accuracy: 0,
            speed: 0,
            heading: 0,
            speedAccuracy: 0,
            timestamp: DateTime.now(),
            altitudeAccuracy: 0,
            headingAccuracy: 0,
            isMocked: false,
          );
        }).toList();

        areasList.add(SavedArea(titulo: titulo, points: pointsList, area: areaValue, isShared: true));
      }
    }

    setState(() {
      savedAreas = areasList;
      areaIds = ids;
      isLoading = false;
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

  void _compartilharArea(SavedArea area) async {
    if (user == null) {
      showCustomSnackBar(context, 'Faça login para compartilhar áreas.', success: false);
      return;
    }

    final firestore = FirebaseFirestore.instance;

    await firestore.collection('shared_areas').add({
      'owner': user!.uid,
      'title': area.titulo,
      'area': area.area,
      'points': area.points.map((p) => {
        'lat': p.latitude,
        'lng': p.longitude,
      }).toList(),
      'sharedWith': [],
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Área compartilhada com sucesso!')),
    );
  }

  void showCustomSnackBar(BuildContext context, String message, {bool success = true}) {
    final theme = Theme.of(context);
    final bgColor = success
        ? theme.bottomNavigationBarTheme.selectedItemColor
        : Colors.redAccent;

    final textColor = theme.scaffoldBackgroundColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarDialogoCompartilhar(SavedArea area) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Compartilhar área",
                ),
                const SizedBox(height: 20),
                Text(
                  "Informe o e-mail do usuário para compartilhar esta área.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "E-mail do usuário",
                    hintText: "Digite o e-mail",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text("Cancelar"),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final email = controller.text.trim();
                        if (email.isEmpty) return;

                        final currentUser = FirebaseAuth.instance.currentUser;
                        final firestore = FirebaseFirestore.instance;
                        final result = await firestore
                            .collection('users')
                            .where('email', isEqualTo: email)
                            .limit(1)
                            .get();

                        if (result.docs.isEmpty) {
                          showCustomSnackBar(context, 'Usuário não encontrado. Verifique o e-mail.', success: false);
                          return;
                        }

                        final uid = result.docs.first.data()['uid'];

                        await firestore.collection('shared_areas').add({
                          'owner': currentUser?.uid,
                          'title': area.titulo,
                          'area': area.area,
                          'points': area.points.map((p) => {
                            'lat': p.latitude,
                            'lng': p.longitude,
                          }).toList(),
                          'sharedWith': [uid],
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        Navigator.pop(context);

                        showCustomSnackBar(context, 'Área compartilhada com sucesso!');
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Compartilhar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.bottomNavigationBarTheme.unselectedItemColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editarArea(int index) async {
    final areaAtual = savedAreas[index];
    final areaId = areaIds[index];
    final controller = TextEditingController(text: areaAtual.titulo);

    final tema = Theme.of(context);
    final isDark = tema.brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: tema.scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Editar Título da Área",
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  cursorColor: tema.colorScheme.primary,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: "Título",
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: tema.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: tema.colorScheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text("Cancelar"),
                      style: TextButton.styleFrom(
                        foregroundColor: tema.colorScheme.error,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final novoTitulo = controller.text.trim();
                        if (novoTitulo.isNotEmpty) {
                          await Banco_de_dados().atualizarTituloArea(areaId, novoTitulo);
                          _loadSavedAreas();
                        }
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Salvar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tema.bottomNavigationBarTheme.unselectedItemColor,
                        foregroundColor: tema.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          Theme.of(context).brightness == Brightness.light
              ? 'assets/app/logo_light.png'
              : 'assets/app/logo_dark.png',
          height: 40,
        ),
      ),
      body: Column(
        children: [
          if (user == null) 
            Container(
              width: double.infinity,
              color: Colors.amber[700],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: const Text(
                "Para usar o serviço de compartilhamento de áreas, faça o login!",
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

          Expanded(
            child: isLoading
              ? Center(
                  child: Image.asset(
                    'assets/app/loading.gif',
                    width: 100,
                    height: 100,
                  ),
                )
              : savedAreas.isEmpty
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          if (area.isShared) ...[
                                            Container(
                                              width: 12,
                                              height: 12,
                                              margin: const EdgeInsets.only(right: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                          Expanded(
                                            child: Text(
                                              area.titulo ?? 'Sem título',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _editarArea(index),
                                          tooltip: 'Editar',
                                        ),

                                        if (user != null) ...[
                                          IconButton(
                                            icon: const Icon(Icons.share, color: Colors.green),
                                            onPressed: () => _mostrarDialogoCompartilhar(area),
                                            tooltip: 'Compartilhar',
                                          ),
                                        ],
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteArea(index),
                                            tooltip: 'Deletar',
                                          ),

                                        IconButton(
                                          icon: const Icon(Icons.map, color: Colors.orange),
                                          onPressed: () {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => GPSAreaCalculator(initialPoints: area.points),
                                              ),
                                              (Route<dynamic> route) => false,
                                            );
                                          },
                                          tooltip: 'Visualizar no mapa',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Área total: ${area.area.toStringAsFixed(2)} m²",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 40,
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
          ),
        ],
      ),
    );
  }
}
