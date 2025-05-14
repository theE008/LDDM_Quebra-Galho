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

/** ORIGEM DAS CORES
 *  
 * Fundo: #E0F0F0
 * Tema (Logo):  #04333B
 * Lesser tema (Fundo da logo): #1B4A52
 * Branco (Ferramenta): 1B4A52
 * Detalhes (Brancos das ferramentas): #7DA9B2
 */

// Temas declarados em estilo "json-like"
final Map<String, ThemeData> temas = {
  "claro": ThemeData (
    scaffoldBackgroundColor: Color (0xFFE0F0F0),
    brightness: Brightness.light,
    colorScheme: ColorScheme.light (
      primary: Color (0xFF04333B),
      secondary: Color (0xFF1B4A52),
    ),
  ),
  "escuro": ThemeData (
    scaffoldBackgroundColor: Color (0xFF000011),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark (
      primary: Color (0xFF011223),
      secondary: Color (0xFF203040),
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
