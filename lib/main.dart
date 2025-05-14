import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quebra_galho/utils/theme_provider.dart';
import 'package:quebra_galho/widgets/splash_screen.dart';

void main ()
{
  runApp (
    ChangeNotifierProvider (
      create: (_) => ThemeProvider(),
      child: MeuApp(),
    )
  );
}

// Temas declarados em estilo "json-like"
final Map<String, ThemeData> temas = {
  "claro": ThemeData (
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light (
      primary: Color (0xFFFF0000),
      secondary: Color (0xFF00FF00),
    ),
  ),
  "escuro": ThemeData (
    scaffoldBackgroundColor: Color (0xFF00FFFF),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark (
      primary: Color (0xFF0000FF),
      secondary: Color (0xFFFFFF00),
    ),
  ),
};

class MeuApp extends StatelessWidget
{
  @override
  Widget build (BuildContext context)
  {
    final tema = Provider.of<ThemeProvider> (context);

    return MaterialApp (
      debugShowCheckedModeBanner: false,
      theme: temas["claro"],
      darkTheme: temas["escuro"],
      themeMode: tema.modoEscuro ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(),
    );
  }
}
