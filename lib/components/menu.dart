import 'package:flutter/material.dart';
import 'package:flutterapp/pages/weather_page.dart'; // Importe a tela de clima

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.purple, // Exemplo de cor para o cabeçalho
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Clima'),
            onTap: () {
              // Primeiro, fecha o menu (Drawer)
              Navigator.of(context).pop();
              // Depois, navega para a tela de clima
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
