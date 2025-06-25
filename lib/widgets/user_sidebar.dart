import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../telas/new_login_screen.dart';
import '../telas/new_register_screen.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                children: [
                  // Cabeçalho (foto e email)
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
                        user?.email ?? 'Visitante',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Botões de login e registro (exibidos só se não estiver logado)
                  if (user == null)
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
                              backgroundColor: theme.bottomNavigationBarTheme.selectedItemColor,
                              foregroundColor: theme.scaffoldBackgroundColor,
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
                              backgroundColor: theme.bottomNavigationBarTheme.selectedItemColor,
                              foregroundColor: theme.scaffoldBackgroundColor,
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

                  const Spacer(),

                  // Botão logout (exibido só se estiver logado)
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

                  // Rodapé
                  Text(
                    'Versão 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
