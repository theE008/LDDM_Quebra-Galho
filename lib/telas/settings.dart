import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  double volume = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF121212), // mesma cor de fundo que o app
                     elevation: 0,
                     centerTitle: true,
                     title: Image.asset(
                            'assets/app/logo.png',
                            height: 40, 
                            ),
                    ),
      // 
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Geral'),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Modo Escuro',
            value: isDarkMode,
            onChanged: (val) {
              setState(() => isDarkMode = val);
              
            },
          ),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Notificações',
            value: notificationsEnabled,
            onChanged: (val) {
              setState(() => notificationsEnabled = val);
            },
          ),
          SizedBox(height: 24),
          _buildSectionTitle('Conta'),
          _buildActionTile(
            icon: Icons.logout,
            title: 'Sair',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deslogado!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: const Color.fromARGB(179, 199, 197, 197),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // 🔵 Cor do botão switch tile (cartão de configuração)
        color: Color(0xFF1C4352),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.white),
        title: Text(title, style: TextStyle(color: Colors.white)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          // 🔴 Cor do botão "Sair"
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
