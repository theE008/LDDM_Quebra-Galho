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

class MeuApp extends StatelessWidget
{
  @override
  Widget build (BuildContext context)
  {
    final tema = Provider.of<ThemeProvider> (context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF121212),
        brightness: Brightness.dark,
      ),
      themeMode: tema.modoEscuro ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(),
    );
  }
} // estou adicionando isso pra conseguir comiitar
