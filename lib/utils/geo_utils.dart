import 'dart:math';
import 'package:geolocator/geolocator.dart';

double calculateArea(List<Position> points) {
  if (points.length < 3) return 0.0;

  // Convert lat/lon to radians
  List<List<double>> xy = points.map((p) {
    double lat = p.latitude * pi / 180;
    double lon = p.longitude * pi / 180;
    return [lon, lat];
  }).toList();

  // Raio da Terra em metros
  const double R = 6371000;

  // Aplicar fórmula de Shoelace adaptada
  double sum = 0.0;
  for (int i = 0; i < xy.length; i++) {
    int j = (i + 1) % xy.length;
    sum += (xy[j][0] - xy[i][0]) * (2 + sin(xy[i][1]) + sin(xy[j][1]));
  }

  double area = (sum * R * R / 2).abs();
  return area;
}
