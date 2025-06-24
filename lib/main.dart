import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quebra_galho/utils/theme_provider.dart';
import 'package:quebra_galho/widgets/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'telas/new_login_screen.dart';
import 'telas/new_register_screen.dart';

void main () async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
    scaffoldBackgroundColor: Color (0xFFE0F0F0), // cor de fundo
    brightness: Brightness.light,
    colorScheme: ColorScheme.light (
      primary: Colors.grey, // cor do botão
      secondary: Color (0xFF1B4A52), 
    ),
    appBarTheme: AppBarTheme (
      backgroundColor: Color (0xFFE0F0F0),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color (0xFFE0F0F0),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
    ),
  ),
  "escuro": ThemeData (
    scaffoldBackgroundColor: Color (0xFF1C1C1C),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark (
      primary: Color.fromARGB(255, 15, 15, 15), // cor do botão
      secondary: Color (0xFF203040), // cor de fundo
    ),
    appBarTheme: AppBarTheme (
      backgroundColor: Color (0xFF1C1C1C),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color (0xFF1C1C1C),
      selectedItemColor: Colors.greenAccent,
      unselectedItemColor: Colors.grey,
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
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}