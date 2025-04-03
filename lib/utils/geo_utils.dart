import 'dart:math';
import 'package:geolocator/geolocator.dart';

double calculateArea(List<Position> points) {
  if (points.length < 4) return 0.0;

  double d1 = haversine(points[0], points[1]);
  double d2 = haversine(points[1], points[2]);
  double d3 = haversine(points[2], points[3]);
  double d4 = haversine(points[3], points[0]);

  double s = (d1 + d2 + d3 + d4) / 2;
  return sqrt((s - d1) * (s - d2) * (s - d3) * (s - d4));
}

double haversine(Position p1, Position p2) {
  const double R = 6371e3;
  double dLat = (p2.latitude - p1.latitude) * pi / 180;
  double dLon = (p2.longitude - p1.longitude) * pi / 180;
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(p1.latitude * pi / 180) * cos(p2.latitude * pi / 180) *
          sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}
