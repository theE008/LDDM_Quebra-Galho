import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:quebra_galho/utils/compass_custompainter.dart';
import 'dart:math' as math;

class CompassScreen extends StatefulWidget {
  const CompassScreen({Key? key}) : super(key: key);

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(); // gira em loop
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
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
          final CompassEvent? compassData = snapshot.data;
          final double? direction = compassData?.heading;

          if (direction != null) {
            // Sensor disponível – usa direção real
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
          } else {
            // Sensor indisponível – anima compasso girando
            return AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                double angle = _rotationController.value * 360;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: size,
                      painter: CompassCustomPainter(angle: angle),
                    ),
                    Positioned(
                      bottom: 100,
                      child: Column(
                        children: [
                          Text(
                            "Sensor não disponível",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Compasso girando em modo visual",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

String getCardinalDirection(double direction) {
  if (direction >= 0 && direction < 45) {
    return 'N';
  } else if (direction >= 45 && direction < 135) {
    return 'E';
  } else if (direction >= 135 && direction < 225) {
    return 'S';
  } else if (direction >= 225 && direction < 315) {
    return 'W';
  } else{
    return 'W';
  }
}
