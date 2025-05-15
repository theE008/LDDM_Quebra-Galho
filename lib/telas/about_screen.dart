import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/app/logo.png',
          height: 40,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Informações do Aplicativo'),
          _buildInfoCard(
            icon: Icons.apps,
            title: 'Nome',
            subtitle: 'Quebra-Galho',
          ),
          _buildInfoCard(
            icon: Icons.verified,
            title: 'Versão',
            subtitle: '2.0.0',
          ),
          _buildInfoCard(
            icon: Icons.person,
            title: 'Desenvolvedores',
            subtitle: 'Bruno Rafael Santos Oliveira, Bruna, Thiago, Daniel',
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Finalidade'),
          _buildTextCard(
            'O Quebra-Galho foi criado para auxiliar trabalhadores e curiosos com ferramentas práticas em campo. Medição de áreas, direção e muito mais — tudo na palma da sua mão.',
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Funcionalidades'),
          _buildBulletList([
            'Calculadora de área com GPS',
            'Bússola simples e prática',
            'Funciona offline',
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle('Suporte & Contato'),
          _buildTextCard(
            'Para sugestões, dúvidas ou bugs, entre em contato pelo email: suporte@quebragalho.app.',
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
        style: const TextStyle(
          color: Color.fromARGB(200, 255, 255, 255),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C4352),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C4352),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C4352),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18)),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
