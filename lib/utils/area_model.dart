import 'package:geolocator/geolocator.dart';

class SavedArea {
  final List<Position> points;
  final double area;
  final int? id;
  final String? titulo;

  SavedArea({required this.points, required this.area, this.id, this.titulo});
}
