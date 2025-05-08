import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier
{
  bool _modo_escuro = true;

  bool get modoEscuro => _modo_escuro;

  void definirModo (bool valor)
  {
    _modo_escuro = valor;
    notifyListeners();
  }

  void alternarModo ()
  {
    _modo_escuro = !_modo_escuro;
    notifyListeners();
  }
}
