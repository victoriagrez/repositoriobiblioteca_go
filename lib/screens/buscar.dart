// lib/screens/buscar.dart

import 'package:flutter/material.dart';

class PaginaBuscar extends StatefulWidget {
  const PaginaBuscar({Key? key}) : super(key: key);

  @override
  State<PaginaBuscar> createState() => _PaginaBuscarState();
}

class _PaginaBuscarState extends State<PaginaBuscar> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  String _textoBusqueda = '';

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEB5F28),
        title: const Text(
          'Buscar Libros',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controladorBusqueda,
              onChanged: (valor) {
                setState(() {
                  _textoBusqueda = valor;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar libros, autores...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _textoBusqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _controladorBusqueda.clear();
                            _textoBusqueda = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Resultados de búsqueda
          Expanded(
            child: _textoBusqueda.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Busca tus libros favoritos',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      'Buscando: "$_textoBusqueda"',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}