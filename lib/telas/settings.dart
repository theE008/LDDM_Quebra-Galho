import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';

class SettingsScreen extends StatefulWidget
{
  @override
  _SettingsScreenState createState ()
  {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen>
{
  bool notificacoes = true;
  bool localizacao = false;
  bool autoAtualizar = true;
  bool vibracao = true;

  @override
  Widget build (BuildContext context)
  {
    final tema = Provider.of<ThemeProvider> (context);

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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _tituloSecao('Geral'),
          _tileComSwitch(
            icon: Icons.dark_mode,
            titulo: 'Modo Escuro',
            valor: tema.modoEscuro,
            aoAlterar: (val) {
              tema.definirModo(val);
            },
          ),
          _tileComSwitch(
            icon: Icons.notifications,
            titulo: 'Notificações',
            valor: notificacoes,
            aoAlterar: (val) {
              setState(() => notificacoes = val);
            },
          ),
          _tileComSwitch(
            icon: Icons.vibration,
            titulo: 'Feedback por Vibração',
            valor: vibracao,
            aoAlterar: (val) {
              setState(() => vibracao = val);
            },
          ),
          SizedBox(height: 24),
          _tituloSecao('Sistema'),
          _tileComSwitch(
            icon: Icons.location_on,
            titulo: 'Serviços de Localização',
            valor: localizacao,
            aoAlterar: (val) {
              setState(() => localizacao = val);
            },
          ),
          _tileComSwitch(
            icon: Icons.system_update,
            titulo: 'Atualização Automática',
            valor: autoAtualizar,
            aoAlterar: (val) {
              setState(() => autoAtualizar = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _tituloSecao (String titulo)
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        titulo,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

Widget _tileComSwitch ({
  required IconData icon,
  required String titulo,
  required bool valor,
  required Function(bool) aoAlterar,
})
{
  final tema = Theme.of(context);
  final corPrimaria = tema.colorScheme.primary;

  final bool modoEscuro = tema.brightness == Brightness.dark;
  final corTexto = modoEscuro
  ? Colors.white
  : Colors.black;

  final corSwitchAtivo = modoEscuro ? Colors.greenAccent : Colors.blueAccent;
  final corTrilhaSwitch = modoEscuro
    ? Colors.greenAccent.withOpacity(0.3)
    : Colors.blueAccent.withOpacity(0.3);

  final corFundo = modoEscuro
    ? corPrimaria.withOpacity(0.9)
    : corPrimaria.withOpacity(0.15);

  return Container(
    margin: EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: corFundo,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: valor
          ? corSwitchAtivo.withOpacity(0.8)
          : Colors.transparent,
        width: valor ? 1.5 : 0,
      ),
    ),
    child: SwitchListTile(
      secondary: Icon(icon, color: corTexto),
      title: Text(
        titulo,
        style: TextStyle(color: corTexto),
      ),
      value: valor,
      onChanged: aoAlterar,
      activeColor: corSwitchAtivo,
      activeTrackColor: corTrilhaSwitch,
    ),
  );
}

  Widget _tileDeAcao ({
    required IconData icon,
    required String titulo,
    required VoidCallback aoTocar,
  })
  {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Text(
              titulo,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}