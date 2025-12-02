import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../data/portadas_urls.dart';
import '../models/libro.dart';
import '../services/firebase_service.dart';
import 'libro_detalle.dart';
import 'listas.dart';
import 'perfil.dart';

class BuscarPage extends StatefulWidget {
  const BuscarPage({super.key});

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final TextEditingController _searchController = TextEditingController();
  final ServicioFirebase _servicioFirebase = ServicioFirebase();

  int _selectedIndex = 1;
  String _selectedFilter = 'No ficción';

  // Filtros
  final List<String> _filters = [
    'Ficción',
    'Clásicos',
    'No ficción',
    'Historia',
  ];

  // CONVERTIMOS tus libros “Map” a modelo Libro (MISMO QUE HOME)
  final List<Libro> _books = [
    Libro(
      id: 'libro_romano',
      titulo: 'Mi año romano',
      autor: 'André Aciman',
      imagenUrl: kUrlPortadaRomano,
      calificacion: 5,
      categorias: ['Ficción'],
      paginas: 250,
    ),
    Libro(
      id: 'libro_emilia',
      titulo: 'Mi nombre es Emilia del Valle',
      autor: 'Isabel Allende',
      imagenUrl: kUrlPortadaEmilia,
      calificacion: 5,
      categorias: ['Ficción'],
      paginas: 320,
    ),
    Libro(
      id: 'libro_amanecer',
      titulo: 'Amanecer en la cosecha',
      autor: 'Autor desconocido',
      imagenUrl: kUrlPortadaAmanecer,
      calificacion: 5,
      categorias: ['Ficción'],
      paginas: 280,
    ),
    Libro(
      id: 'libro_zoo',
      titulo: 'La muy catastrófica visita al zoo',
      autor: 'Joel Dicker',
      imagenUrl: kUrlPortadaZoo,
      calificacion: 5,
      categorias: ['Infantil'],
      paginas: 120,
    ),
    Libro(
      id: 'libro_albatros',
      titulo: 'El albatros negro',
      autor: 'María Oruña',
      imagenUrl: kUrlPortadaAlbatros,
      calificacion: 5,
      categorias: ['Novela'],
      paginas: 450,
    ),
    Libro(
      id: 'libro_desquiciada',
      titulo: 'Nuestra desquiciada historia de amor',
      autor: 'Sandy Nelson',
      imagenUrl: kUrlPortadaDesquiciada,
      calificacion: 5,
      categorias: ['Romance'],
      paginas: 320,
    ),
    Libro(
      id: 'libro_letters',
      titulo: 'Cartas que nunca escribí',
      autor: 'Autor ficticio',
      imagenUrl: kUrlPortadaLetters,
      calificacion: 4,
      categorias: ['Drama'],
      paginas: 200,
    ),
    Libro(
      id: 'libro_art',
      titulo: 'Arte y creatividad',
      autor: 'Varios autores',
      imagenUrl: kUrlPortadaArt,
      calificacion: 4,
      categorias: ['Arte'],
      paginas: 180,
    ),
    Libro(
      id: 'libro_design',
      titulo: 'Historia del diseño',
      autor: 'Autor ficticio',
      imagenUrl: kUrlPortadaDesign,
      calificacion: 4,
      categorias: ['Diseño'],
      paginas: 160,
    ),
    Libro(
      id: 'libro_volvemos',
      titulo: 'Volvemos a empezar',
      autor: 'Autor ficticio',
      imagenUrl: kUrlPortadaVolvemos,
      calificacion: 4,
      categorias: ['Ficción'],
      paginas: 300,
    ),
    Libro(
      id: 'libro_woman',
      titulo: 'Woman',
      autor: 'Autor ficticio',
      imagenUrl: kUrlPortadaWoman,
      calificacion: 4,
      categorias: ['Arte'],
      paginas: 200,
    ),
    Libro(
      id: 'libro_principito',
      titulo: 'El Principito',
      autor: 'Antoine de Saint-Exupéry',
      imagenUrl: kUrlPortadaPrincipito,
      calificacion: 5,
      categorias: ['Infantil'],
      paginas: 96,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = 'No ficción';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ❤️ IGUAL QUE HOME.DART
  Future<void> _alternarFavorito(Libro libro) async {
    final exitoso = await _servicioFirebase.alternarFavorito(libro);

    if (!mounted) return;

    if (exitoso) {
      final esFav = await _servicioFirebase.esFavorito(libro.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(esFav ? 'Agregado a favoritos' : 'Eliminado de favoritos'),
          duration: const Duration(seconds: 2),
          backgroundColor:
              esFav ? AppTheme.azulSecundario : Theme.of(context).colorScheme.error,
        ),
      );

      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pop(context);
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaginaListas()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PerfilPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buscar',
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Botón catálogo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ver catálogo completo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Hola ¿Qué estas\nBuscando?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSearchBar(scheme),
          ),

          const SizedBox(height: 16),

          // Filtros
          _buildFilters(scheme),

          const SizedBox(height: 24),

          // Título sección
          _buildSectionTitle(scheme),

          const SizedBox(height: 16),

          // GRID
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                return _buildBookCard(_books[index], scheme);
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomBar(scheme),
    );
  }

  Widget _buildSearchBar(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.surfaceContainerHighest,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        cursorColor: AppTheme.azulSecundario,
        decoration: InputDecoration(
          hintText: 'Buscar',
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          suffixIcon: Icon(
            Icons.search,
            color: scheme.outline,
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onSubmitted: (value) {
          setState(() => _selectedFilter = value);
        },
      ),
    );
  }

  Widget _buildFilters(ColorScheme scheme) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter;
                  _searchController.text = filter;
                });
              },
              backgroundColor: scheme.surface,
              selectedColor: scheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? scheme.onPrimary : scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? scheme.primary
                      : AppTheme.azulSecundario,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedFilter,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Ver más',
              style: TextStyle(
                color: scheme.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CARD CON MISMO ICONO DE FAVORITOS DE HOME
  Widget _buildBookCard(Libro libro, ColorScheme scheme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaginaDetalleLibro(
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
        ).then((_) => setState(() {}));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen con icono
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      libro.imagenUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(Icons.book,
                              size: 40, color: scheme.outline),
                        );
                      },
                    ),
                  ),
                ),

                // ❤️ MISMO ICONO DE HOME.DART
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
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            esFavorito
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: AppTheme.azulSecundario,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Título
          Text(
            libro.titulo,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          Row(
            children: List.generate(
              libro.calificacion.toInt(),
              (i) => const Icon(
                Icons.star,
                color: AppTheme.amarilloEstrella,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomBar(ColorScheme scheme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.outlineVariant,
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
          label: '',
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
    );
  }
}
