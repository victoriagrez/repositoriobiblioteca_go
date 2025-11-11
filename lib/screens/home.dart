import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/libro.dart';
import '../services/firebase_service.dart';
import 'libro_detalle.dart';
import 'buscar.dart';
import 'listas.dart';
import '../theme/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ServicioFirebase _servicioFirebase = ServicioFirebase();

  static const double _coverWidth = 160;
  static const double _coverHeight = 220;

  // LIBROS DISPO 
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
      imagenUrl: 'assets/albatroz.png',
      calificacion: 5,
      categorias: ['Historia', 'Novela'],
      paginas: 450,
    ),
    Libro(
      id: 'libro_zoo',
      titulo: 'La muy catastrófica visita al zoo',
      autor: 'Varios Autores',
      imagenUrl: 'assets/zoo.webp',
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
      imagenUrl: 'assets/desquiciada.webp',
      calificacion: 5,
      categorias: ['Romance', 'Drama'],
      paginas: 320,
    ),
    Libro(
      id: 'libro_cosecha',
      titulo: 'Amanecer en la cosecha',
      autor: 'Autor Desconocido',
      imagenUrl: 'assets/amanecer.jpg',
      calificacion: 5,
      categorias: ['Fantasía', 'Aventura'],
      paginas: 280,
    ),
    Libro(
      id: 'libro_aciman',
      titulo: 'André Aciman',
      autor: 'André Aciman',
      imagenUrl: 'assets/romano.jpg',
      calificacion: 5,
      categorias: ['Romance', 'Drama'],
      paginas: 250,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // NAV
    switch (index) {
      case 0:
        break;
      case 1:
        // BUSCAR
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaginaBuscar()),
        );
        break;
      case 2:
        // LIBROS LECTURA RAP 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lectura rápida')),
        );
        break;
      case 3:
        // LISTAS FAV
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaginaListas()),
        );
        break;
      case 4:
        // PERFIL
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil')),
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

  // AGREGAR Y ELIMINAR FAVS 
  Future<void> _alternarFavorito(Libro libro) async {
    final exitoso = await _servicioFirebase.alternarFavorito(libro);

    if (!mounted) return;

    if (exitoso) {
      final esFav = await _servicioFirebase.esFavorito(libro.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esFav ? 'Agregado a favoritos' : 'Eliminado de favoritos',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: esFav
              ? AppTheme.azulSecundario
              : Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = AppTheme.azulSecundario;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: secondary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.person, size: 20),
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

            // RETO LECTOR 
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
              ),
              items: [
                _buildRetoLectorCard(secondary),
              ],
            ),
            const SizedBox(height: 30),

            // LANZAMIENTOS
            _buildSectionHeader('Nuevos\nlanzamientos', primary),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _librosNuevos.length,
                itemBuilder: (context, index) {
                  return _buildBookCard(_librosNuevos[index], secondary);
                },
              ),
            ),
            const SizedBox(height: 30),

            // PARA TI
            _buildSectionHeader('Para ti', primary),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _librosParaTi.length,
                itemBuilder: (context, index) {
                  return _buildBookCard(_librosParaTi[index], secondary);
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
        selectedItemColor: primary,
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

  Widget _buildSectionHeader(String title, Color primary) {
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
              // VER MAS 
            },
            child: Text(
              'Ver más',
              style: TextStyle(
                color: primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetoLectorCard(Color secondary) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: secondary,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Stack(
      children: [
        // Flechas izquierda
        Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {},
          ),
        ),

        // CONTENIDO CENTRADO (con ajuste anti-overflow)
        // FittedBox escalará el contenido si no cabe en 200 px de alto
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 8),
                  Icon(
                    Icons.keyboard,
                    size: 44, // antes 50
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mayo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30, // antes 32
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
          ),
        ),

        // Flechas derecha
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    ),
  );
}


  Widget _buildBookCard(Libro libro, Color secondary) {
    return Container(
      width: _coverWidth,
      margin: const EdgeInsets.only(right: 16), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // IMAGEN LIBRO 
              GestureDetector(
                onTap: () {
                  // NAVEGACION PANTALLA DE LIBRO DETALLE
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaginaDetalleLibro(
                        libroId: libro.id,
                        datosLibro: {
                          'titulo': libro.titulo,
                          'autor': libro.autor,
                          'imagenUrl': libro.imagenUrl,
                          'calificacion': libro.calificacion,
                          'categorias': libro.categorias,
                          'paginas': libro.paginas,
                        },
                      ),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
                child: Container(
                  height: _coverHeight, // 200
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[200],
                      child: Image.asset(
                        libro.imagenUrl,
                        fit: BoxFit.cover,        
                        width: double.infinity,
                        height: double.infinity,  
                        alignment: Alignment.center,
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
              ),
              // FAV BOTON
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
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          esFavorito ? Icons.bookmark : Icons.bookmark_border,
                          color: secondary,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

      
          const SizedBox(height: 6), 
          Text(
            libro.titulo,
            style: const TextStyle(
              fontSize: 13,           
              height: 1.1,            
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // ESTRELLAS (ligeramente más pequeñas)
          Row(
            children: List.generate(
              libro.calificacion.toInt(),
              (index) => const Icon(
                Icons.star,
                color: AppTheme.amarilloEstrella,
                size: 14, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
