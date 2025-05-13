// screens/saved_areas_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/area_model.dart';

class SavedAreasScreen extends StatefulWidget {
  final List<SavedArea> savedAreas;

  const SavedAreasScreen({super.key, required this.savedAreas});

  @override
  State<SavedAreasScreen> createState() => _SavedAreasScreenState();
}

class _SavedAreasScreenState extends State<SavedAreasScreen> {
  void _deleteArea(int index) {
    setState(() {
      widget.savedAreas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Áreas Salvas"),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: widget.savedAreas.isEmpty
          ? const Center(child: Text("Nenhuma área salva."))
          : ListView.builder(
              itemCount: widget.savedAreas.length,
              itemBuilder: (context, index) {
                final area = widget.savedAreas[index];
                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text("Área: ${area.area.toStringAsFixed(2)} m²"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: area.points.map((p) {
                        return Text("Lat: ${p.latitude}, Lng: ${p.longitude}");
                      }).toList(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteArea(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        label: const Text("Voltar"),
        icon: const Icon(Icons.arrow_back),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
