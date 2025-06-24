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

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 40,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/app/Portrait_Placeholder.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              user?.displayName ?? user?.email ?? 'Visitante',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Entrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.bottomNavigationBarTheme.selectedItemColor,
                foregroundColor: theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: Text(
                'Criar nova conta',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
