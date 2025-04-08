import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/app/logo.png',
          height: 40,
        ),
      ),
      body: Center(
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.hasError || snapshot.data == null) {
              return Text('Bússola não disponível',
                  style: TextStyle(color: Colors.white));
            }

            double? direction = snapshot.data!.heading;
            if (direction == null) return Container();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFF1C4352),
                    shape: BoxShape.circle,
                  ),
                  child: Transform.rotate(
                    angle: (direction * (pi / 180) * -1),
                    child: Image.asset(
                      'assets/app/compasso.png',
                      height: 500,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  '${direction.toStringAsFixed(0)}°',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
