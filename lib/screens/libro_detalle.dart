// lib/screens/libro_detalle.dart

import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../services/firebase_service.dart';

class PaginaDetalleLibro extends StatefulWidget {
  final Libro libro;

  const PaginaDetalleLibro({
    Key? key,
    required this.libro,
  }) : super(key: key);

  @override
  State<PaginaDetalleLibro> createState() => _PaginaDetalleLibroState();
}

class _PaginaDetalleLibroState extends State<PaginaDetalleLibro> {
  final ServicioFirebase _servicioFirebase = ServicioFirebase();
  bool _esFavorito = false;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _verificarSiEsFavorito();
  }

  // Verificar si el libro ya está en favoritos
  Future<void> _verificarSiEsFavorito() async {
    final resultado = await _servicioFirebase.esFavorito(widget.libro.id);
    setState(() {
      _esFavorito = resultado;
    });
  }

  // Manejar el clic en el botón de favoritos
  Future<void> _manejarFavorito() async {
    setState(() {
      _cargando = true;
    });

    final exitoso = await _servicioFirebase.alternarFavorito(widget.libro);

    if (exitoso) {
      setState(() {
        _esFavorito = !_esFavorito;
        _cargando = false;
      });

      // Mostrar mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esFavorito
                  ? '❤️ Agregado a favoritos'
                  : '💔 Eliminado de favoritos',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: _esFavorito ? Colors.green : Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        _cargando = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al actualizar favoritos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEB5F28),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón de favoritos
          IconButton(
            icon: _cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    _esFavorito ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
            onPressed: _cargando ? null : _manejarFavorito,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Acción de compartir
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Colors.white),
            onPressed: () {
              // Acción de reportar
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Imagen del libro
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.libro.imagenUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.libro.titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Autor
            Text(
              widget.libro.autor,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Calificación con estrellas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < widget.libro.calificacion
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 24,
                );
              }),
            ),
            const SizedBox(height: 20),
            // Categorías
            Wrap(
              spacing: 8,
              children: widget.libro.categorias.map((categoria) {
                return Chip(
                  label: Text(categoria),
                  backgroundColor: const Color(0xFF00A2C6),
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Botón de leer
            ElevatedButton.icon(
              onPressed: () {
                // Acción de leer libro
              },
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Leer Libro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAC3306),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Tabs de información
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Color(0xFFEB5F28),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFFEB5F28),
                    tabs: [
                      Tab(text: 'LIBRO'),
                      Tab(text: 'REVIEW'),
                      Tab(text: 'ESTADÍSTICAS'),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        // Tab de progreso
                        _construirTabProgreso(),
                        // Tab de reseñas
                        const Center(child: Text('Reseñas próximamente')),
                        // Tab de estadísticas
                        const Center(child: Text('Estadísticas próximamente')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTabProgreso() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu Progreso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00A2C6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '0 de ${widget.libro.paginas} Páginas leídas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '12 mar. 25 - N/D',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  '19h 12m se fue',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                const Text(
                  '128',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Personas han leído este libro',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}