// lib/screens/main_scaffold.dart

import 'package:flutter/material.dart';
import 'home.dart';
import 'buscar.dart';
import 'listas.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _paginaActual = 0;

  final List<Widget> _pantallas = [
    const HomeScreen(),
    const PaginaBuscar(),
    const Center(child: Text('Lectura Rápida\nPróximamente')),
    const PaginaListas(),
    const Center(child: Text('Perfil\nPróximamente')),
  ];

  void _cambiarPagina(int index) {
    setState(() {
      _paginaActual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_paginaActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: _cambiarPagina,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEB5F28),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Lectura'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Listas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}