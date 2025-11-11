import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PaginaBuscar extends StatefulWidget {
  const PaginaBuscar({Key? key}) : super(key: key);

  @override
  State<PaginaBuscar> createState() => _PaginaBuscarState();
}
//BUSCAR
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Buscar Libros',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: scheme.primary,
      ),
      body: Column(
        children: [
      //SEARCHBAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controladorBusqueda,
              onChanged: (valor) {
                setState(() {
                  _textoBusqueda = valor;
                });
              },
              cursorColor: AppTheme.azulSecundario,
              decoration: InputDecoration(
                hintText: 'Buscar libros, autores...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _textoBusqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        color: AppTheme.azulSecundario,
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.azulSecundario, width: 2),
                ),
              ),
            ),
          ),
      //RESULTADOS
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
