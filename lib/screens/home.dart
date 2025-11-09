// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/libro.dart';
import '../services/firebase_service.dart';
import 'libro_detalle.dart';
import 'buscar.dart';
import 'listas.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ServicioFirebase _servicioFirebase = ServicioFirebase();

  // Lista de libros disponibles
  final List<Libro> _librosNuevos = [
    Libro(
      id: 'libro_principito',
      titulo: 'El Principito',
      autor: 'Antoine de Saint-Exupéry',
      imagenUrl: 'assets/principito.jpg',
      calificacion: 5,
      categorias: ['Arte', 'Infantil'],
      paginas: 96,
    ),
    Libro(
      id: 'libro_albatros',
      titulo: 'El albatros negro',
      autor: 'María Dueñas',
      imagenUrl: 'assets/albatros.jpg',
      calificacion: 5,
      categorias: ['Historia', 'Novela'],
      paginas: 450,
    ),
    Libro(
      id: 'libro_zoo',
      titulo: 'La muy catastrófica visita al zoo',
      autor: 'Varios Autores',
      imagenUrl: 'assets/zoo.jpg',
      calificacion: 5,
      categorias: ['Infantil', 'Humor'],
      paginas: 120,
    ),
  ];

  final List<Libro> _librosParaTi = [
    Libro(
      id: 'libro_amor',
      titulo: 'Nuestra Desquiciada historia de amor',
      autor: 'Sandy Nelson',
      imagenUrl: 'assets/amor.jpg',
      calificacion: 5,
      categorias: ['Romance', 'Drama'],
      paginas: 320,
    ),
    Libro(
      id: 'libro_cosecha',
      titulo: 'Amanecer en la cosecha',
      autor: 'Autor Desconocido',
      imagenUrl: 'assets/cosecha.jpg',
      calificacion: 5,
      categorias: ['Fantasía', 'Aventura'],
      paginas: 280,
    ),
    Libro(
      id: 'libro_aciman',
      titulo: 'André Aciman',
      autor: 'André Aciman',
      imagenUrl: 'assets/aciman.jpg',
      calificacion: 5,
      categorias: ['Romance', 'Drama'],
      paginas: 250,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navegar según el índice
    switch (index) {
      case 0:
        // Ya estamos en Home, no hacer nada
        break;
      case 1:
        // Buscar
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaginaBuscar()),
        );
        break;
      case 2:
        // Libros / Lectura rápida
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lectura rápida próximamente')),
        );
        break;
      case 3:
        // Listas (Favoritos)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaginaListas()),
        );
        break;
      case 4:
        // Perfil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil próximamente')),
        );
        break;
    }
  }

  Future<void> _signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  // Función para agregar/quitar de favoritos desde el home
  Future<void> _alternarFavorito(Libro libro) async {
    final exitoso = await _servicioFirebase.alternarFavorito(libro);
    
    if (!mounted) return;
    
    if (exitoso) {
      final esFav = await _servicioFirebase.esFavorito(libro.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esFav ? '❤️ Agregado a favoritos' : '💔 Eliminado de favoritos',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: esFav ? Colors.green : Colors.red,
        ),
      );
      setState(() {}); // Refrescar UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE85D2E),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF28A9B8),
              shape: BoxShape.circle,
            ),
          ),
        ),
        title: const Text(
          '¡Bienvenido!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaginaBuscar()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Carrusel del Reto Lector
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
              ),
              items: [
                _buildRetoLectorCard(),
              ],
            ),
            const SizedBox(height: 30),

            // Sección "Nuevos lanzamientos"
            _buildSectionHeader('Nuevos\nlanzamientos'),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _librosNuevos.length,
                itemBuilder: (context, index) {
                  return _buildBookCard(_librosNuevos[index]);
                },
              ),
            ),
            const SizedBox(height: 30),

            // Sección "Para ti"
            _buildSectionHeader('Para ti'),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _librosParaTi.length,
                itemBuilder: (context, index) {
                  return _buildBookCard(_librosParaTi[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE85D2E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Libros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Listas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          TextButton(
            onPressed: () {
              // Navegar a ver más
            },
            child: const Text(
              'Ver más',
              style: TextStyle(
                color: Color(0xFFE85D2E),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetoLectorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF28A9B8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.black),
                  onPressed: () {},
                ),
                const SizedBox(width: 10),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reto Lector',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '2025',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Reto lector 2025',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Biblioteca Pública Digital',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Icon(
                  Icons.keyboard,
                  size: 50,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mayo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Un libro de creación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Libro libro) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Imagen del libro clickeable
              GestureDetector(
                onTap: () {
                  // Navegar a la pantalla de detalle del libro
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaginaDetalleLibro(libro: libro),
                    ),
                  ).then((_) {
                    // Refrescar cuando volvemos
                    setState(() {});
                  });
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      libro.imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.book, size: 50, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Botón de favorito
              Positioned(
                top: 8,
                right: 8,
                child: FutureBuilder<bool>(
                  future: _servicioFirebase.esFavorito(libro.id),
                  builder: (context, snapshot) {
                    final esFavorito = snapshot.data ?? false;
                    return GestureDetector(
                      onTap: () => _alternarFavorito(libro),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          esFavorito ? Icons.bookmark : Icons.bookmark_border,
                          color: esFavorito
                              ? const Color(0xFFE85D2E)
                              : const Color(0xFF28A9B8),
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            libro.titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              libro.calificacion.toInt(),
              (index) => const Icon(
                Icons.star,
                color: Color(0xFFFFA726),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}