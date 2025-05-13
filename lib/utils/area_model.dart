import 'package:geolocator/geolocator.dart';

class SavedArea {
  final List<Position> points;
  final double area;

  SavedArea({required this.points, required this.area});
}
