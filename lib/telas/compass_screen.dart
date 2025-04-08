import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:quebra_galho/utils/compass_custompainter.dart';

class CompassScreen extends StatelessWidget {
  const CompassScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF121212), // mesma cor de fundo que o app
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
                  'assets/app/logo.png',
                  height: 40,
        ),
      ),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao ler direção: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final CompassEvent? compassData = snapshot.data;

          if (compassData == null || compassData.heading == null) {
            return const Center(
              child: Text("Dispositivo sem sensores disponíveis!"),
            );
          }

          final double direction = compassData.heading!;

          return SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: size,
                  painter: CompassCustomPainter(angle: direction),
                ),
                Text(
                  getCardinalDirection(direction),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 82,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String getCardinalDirection(double direction) {
  if (direction >= 337.5 || direction < 22.5) {
    return 'N';
  } else if (direction >= 22.5 && direction < 67.5) {
    return 'NE';
  } else if (direction >= 67.5 && direction < 112.5) {
    return 'E';
  } else if (direction >= 112.5 && direction < 157.5) {
    return 'SE';
  } else if (direction >= 157.5 && direction < 202.5) {
    return 'S';
  } else if (direction >= 202.5 && direction < 247.5) {
    return 'SW';
  } else if (direction >= 247.5 && direction < 292.5) {
    return 'W';
  } else {
    return 'NW';
  }
}
