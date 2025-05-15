import 'dart:math';
import 'package:geolocator/geolocator.dart';

double calculateArea(List<Position> points) {
  if (points.length < 3) return 0.0;

  const double radius = 6371000; // Raio da Terra em metros
  double total = 0.0;

  for (int i = 0; i < points.length; i++) {
    int j = (i + 1) % points.length;

    double lat1 = points[i].latitude * pi / 180;
    double lon1 = points[i].longitude * pi / 180;
    double lat2 = points[j].latitude * pi / 180;
    double lon2 = points[j].longitude * pi / 180;

    double deltaLon = lon2 - lon1;

    // Formula do polígono esférico:
    total += deltaLon * (2 + sin(lat1) + sin(lat2));
  }

  total = total * radius * radius / 2.0;

  return total.abs();
}
