import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../telas/new_login_screen.dart';
import '../telas/new_register_screen.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            children: [
              // Cabeçalho (foto e nome/email)
              Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/app/Portrait_Placeholder.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? user?.email ?? 'Visitante',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const Divider(),

              // Espaço antes dos botões de login e registro
              const SizedBox(height: 24),

              // Botões de ação (Login e Registro sempre visíveis)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Entrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Registrar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Empurra o botão sair e rodapé pro final
              const Spacer(),

              // Botão de logout se o usuário estiver logado
              if (user != null)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Sair"),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),

              const Divider(),
              const SizedBox(height: 12),

              // Rodapé (opcional)
              Text(
                'Versão 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
