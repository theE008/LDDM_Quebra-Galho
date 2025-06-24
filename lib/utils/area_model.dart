import 'package:geolocator/geolocator.dart';

class SavedArea {
  final List<Position> points;
  final double area;
  final int? id;
  final String? titulo;
  final bool isShared;

  SavedArea({required this.points, required this.area, this.id, this.titulo, this.isShared = false,});
}
