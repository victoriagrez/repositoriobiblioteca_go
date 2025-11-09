// lib/screens/listas.dart

import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../services/firebase_service.dart';
import 'libro_detalle.dart';

class PaginaListas extends StatefulWidget {
  const PaginaListas({Key? key}) : super(key: key);

  @override
  State<PaginaListas> createState() => _PaginaListasState();
}

class _PaginaListasState extends State<PaginaListas> {
  final ServicioFirebase _servicioFirebase = ServicioFirebase();
  final TextEditingController _controladorBusqueda = TextEditingController();
  List<Libro> _librosFiltrados = [];
  String _textoBusqueda = '';

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  void _filtrarLibros(List<Libro> todosLosLibros) {
    if (_textoBusqueda.isEmpty) {
      _librosFiltrados = todosLosLibros;
    } else {
      _librosFiltrados = todosLosLibros.where((libro) {
        final tituloMin = libro.titulo.toLowerCase();
        final autorMin = libro.autor.toLowerCase();
        final busquedaMin = _textoBusqueda.toLowerCase();
        return tituloMin.contains(busquedaMin) ||
            autorMin.contains(busquedaMin);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEB5F28),
        title: const Row(
          children: [
            Icon(Icons.bookmark, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Libros Guardados',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Ya tenemos búsqueda abajo
            },
          ),
        ],
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
                hintText: 'Buscar',
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
          // Lista de libros favoritos
          Expanded(
            child: StreamBuilder<List<Libro>>(
              stream: _servicioFirebase.obtenerFavoritos(),
              builder: (context, snapshot) {
                // Mientras carga
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFEB5F28),
                    ),
                  );
                }

                // Si hay error
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar favoritos\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Si no hay libros
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes libros guardados',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega libros a favoritos desde la pantalla principal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar libros según búsqueda
                final libros = snapshot.data!;
                _filtrarLibros(libros);

                if (_librosFiltrados.isEmpty && _textoBusqueda.isNotEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron libros con "$_textoBusqueda"',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                // Mostrar libros
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Sección: Leyendo
                    _construirSeccion(
                      titulo: 'Leyendo',
                      libros: _librosFiltrados
                          .where((l) => l.categorias.contains('Leyendo'))
                          .toList(),
                      colorProgreso: const Color(0xFF00A2C6),
                    ),
                    const SizedBox(height: 20),
                    // Sección: Leídos
                    _construirSeccion(
                      titulo: 'Leídos',
                      libros: _librosFiltrados
                          .where((l) => l.categorias.contains('Leído'))
                          .toList(),
                      colorProgreso: const Color(0xFF00A2C6),
                    ),
                    const SizedBox(height: 20),
                    // Sección: Guardados (todos los demás)
                    _construirSeccion(
                      titulo: 'Guardados',
                      libros: _librosFiltrados,
                      colorProgreso: Colors.pink,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccion({
    required String titulo,
    required List<Libro> libros,
    required Color colorProgreso,
  }) {
    if (libros.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...libros.map((libro) => _construirTarjetaLibro(libro, colorProgreso)),
      ],
    );
  }

  Widget _construirTarjetaLibro(Libro libro, Color colorProgreso) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaginaDetalleLibro(libro: libro),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del libro
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    libro.imagenUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Información del libro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      libro.autor,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Estrellas de calificación
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < libro.calificacion
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    // Barra de progreso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.68, // Puedes hacerlo dinámico
                        backgroundColor: Colors.grey[300],
                        color: colorProgreso,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '68%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Botón para eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _mostrarDialogoEliminar(libro),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoEliminar(Libro libro) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar de favoritos'),
        content: Text(
          '¿Estás segura que quieres eliminar "${libro.titulo}" de tus favoritos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (resultado == true) {
      final exitoso =
          await _servicioFirebase.eliminarDeFavoritos(libro.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exitoso
                  ? '✅ Eliminado de favoritos'
                  : '❌ Error al eliminar',
            ),
            backgroundColor: exitoso ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}