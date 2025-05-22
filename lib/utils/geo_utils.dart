import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

double calculateArea(List<Position> points) {
  if (points.length < 3) return 0.0;

  final Distance distance = const Distance();
  final LatLng center = LatLng(
    points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length,
    points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length,
  );

  // Converte os pontos geográficos em coordenadas locais (X, Y)
  List<LatLng> projected = points.map((p) {
    final dx = distance(center, LatLng(center.latitude, p.longitude));
    final dy = distance(center, LatLng(p.latitude, center.longitude));
    return LatLng(
      p.latitude > center.latitude ? dy : -dy,
      p.longitude > center.longitude ? dx : -dx,
    );
  }).toList();

  double area = 0.0;
  for (int i = 0; i < projected.length; i++) {
    int j = (i + 1) % projected.length;
    area += projected[i].latitude * projected[j].longitude;
    area -= projected[j].latitude * projected[i].longitude;
  }

  return (area.abs() / 2.0);
}
