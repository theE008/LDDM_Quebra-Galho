import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:quebra_galho/utils/compass_custompainter.dart';
import 'dart:math' as math;

class CompassScreen extends StatefulWidget
{
  const CompassScreen ({Key? key}) : super(key: key);

  @override
  State<CompassScreen> createState ()
  {
    return _CompassScreenState();
  }
}

class _CompassScreenState extends State<CompassScreen> with SingleTickerProviderStateMixin
{
  late AnimationController controlador_animacao;

  @override
  void initState ()
  {
    super.initState();

    controlador_animacao = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose ()
  {
    controlador_animacao.dispose();
    super.dispose();
  }

  @override
  Widget build (BuildContext context)
  {
    final tamanho = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          Theme.of(context).brightness == Brightness.light
                    ? 'assets/app/logo_light.png'
                    : 'assets/app/logo_dark.png',
          height: 40,
        ),
      ),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          final CompassEvent? dados_bussola = snapshot.data;
          final double? direcao = dados_bussola?.heading;

          if (direcao != null) {
            return SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: tamanho,
                    painter: CompassCustomPainter(angle: direcao),
                  ),
                  Text(
                    getCardinalDirection(direcao),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 82,
                    ),
                  ),
                ],
              ),
            );
          }
          else {

            final corTextoPrincipal = Theme.of(context).textTheme.bodyMedium?.color;
            final bool modoEscuro = Theme.of(context).brightness == Brightness.dark;

            final corSuave1 = modoEscuro
              ? corTextoPrincipal?.withOpacity(0.6)
              : corTextoPrincipal;

            final corSuave2 = modoEscuro
              ? corTextoPrincipal?.withOpacity(0.5)
              : corTextoPrincipal?.withOpacity(0.85);

            return AnimatedBuilder(
              animation: controlador_animacao,
              builder: (context, child) {
                double angulo = controlador_animacao.value * 360;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: tamanho,
                      painter: CompassCustomPainter(angle: angulo),
                    ),
                    Positioned(
                      bottom: 100,
                      child: Column(
                        children: [
                          Text(
                            "Sensor não disponível",
                            style: TextStyle(
                              color: corSuave1,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Compasso girando em modo visual",
                            style: TextStyle(
                              color: corSuave2,
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

String getCardinalDirection (double direcao)
{
  if (direcao >= 0 && direcao < 45) {
    return 'N';
  } else if (direcao >= 45 && direcao < 135) {
    return 'E';
  } else if (direcao >= 135 && direcao < 225) {
    return 'S';
  } else if (direcao >= 225 && direcao < 315) {
    return 'W';
  } else {
    return 'W';
  }
}