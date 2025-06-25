import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../telas/gps_area_calculator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void showCustomSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.green,
      IconData icon = Icons.check_circle}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        showCustomSnackBar(
          context,
          'As senhas não coincidem',
          backgroundColor: Colors.orange,
          icon: Icons.warning_amber_rounded,
        );
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          showCustomSnackBar(context, 'Cadastro realizado com sucesso!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Erro ao registrar';
        IconData icon = Icons.error_outline;
        Color color = Colors.red;

        if (e.code == 'email-already-in-use') {
          message = 'Este e-mail já está em uso.';
        } else if (e.code == 'invalid-email') {
          message = 'E-mail inválido.';
        } else if (e.code == 'weak-password') {
          message = 'Senha muito fraca.';
          icon = Icons.warning_amber_rounded;
          color = Colors.orange;
        }

        showCustomSnackBar(context, message,
            backgroundColor: color, icon: icon);
      } catch (e) {
      final mensagemErro = e.toString();

      if (mensagemErro.contains(
          "type 'List<Object?>' is not a subtype of type 'PigeonUserDetails?' in type cast")) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => GPSAreaCalculator()),
          (Route<dynamic> route) => false,
        );

        showCustomSnackBar(context, 'Sucesso!'); 
        } else{
        showCustomSnackBar(
          context,
          'Erro inesperado: $e',
          backgroundColor: Colors.red,
          icon: Icons.error_outline,
        );
        }
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add,
                    size: 80,
                    color:
                        theme.bottomNavigationBarTheme.selectedItemColor),
                const SizedBox(height: 20),
                Text(
                  'Crie sua conta',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Informe o e-mail' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Informe a senha' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Confirme a senha' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme
                          .bottomNavigationBarTheme.selectedItemColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Registrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
