import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget
{
  const AboutScreen ({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context)
  {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
          _tituloSecao(context, 'Informações do Aplicativo'),
          _cardInfo(
            context: context,
            icon: Icons.apps,
            titulo: 'Nome',
            subtitulo: 'Quebra-Galho',
          ),
          _cardInfo(
            context: context,
            icon: Icons.verified,
            titulo: 'Versão',
            subtitulo: '1.0.0',
          ),
          _cardInfo(
            context: context,
            icon: Icons.person,
            titulo: 'Desenvolvedores',
            subtitulo: 'Bruno Rafael Santos Oliveira, Bruna, Thiago, Daniel',
          ),

          const SizedBox(height: 24),
          _tituloSecao(context, 'Finalidade'),
          _cardTexto(
            context,
            'O Quebra-Galho foi criado para auxiliar trabalhadores e curiosos com ferramentas práticas em campo. Medição de áreas, direção e muito mais — tudo na palma da sua mão.',
          ),

          const SizedBox(height: 24),
          _tituloSecao(context, 'Funcionalidades'),
          _listaMarcadores(
            context,
            [
              'Calculadora de área com GPS',
              'Bússola simples e prática',
              'Funciona offline',
            ],
          ),

          const SizedBox(height: 24),
          _tituloSecao(context, 'Suporte & Contato'),
          _cardTexto(
            context,
            'Para sugestões, dúvidas ou bugs, entre em contato pelo email: suporte@quebragalho.app.',
          ),
        ],
      ),
    );
  }

  Widget _tituloSecao (BuildContext context, String titulo)
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        titulo,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _cardInfo ({
    required BuildContext context,
    required IconData icon,
    required String titulo,
    required String subtitulo,
  })
  {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
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
                  titulo,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardTexto (BuildContext context, String texto)
  {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _listaMarcadores (BuildContext context, List<String> itens)
  {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: itens.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  )
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
