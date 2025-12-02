import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../data/portadas_urls.dart'; 

class BuscarPage extends StatefulWidget {
  const BuscarPage({super.key});

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1; // "Buscar"
  String _selectedFilter = 'No ficción';

  // Filtros
  final List<String> _filters = [
    'Ficción',
    'Clásicos',
    'No ficción',
    'Historia',
  ];

  // Libros de ejemplo usando URLs de Storage
  final List<Map<String, dynamic>> _books = [
  {
    'title': 'Mi año romano',
    'author': 'André Aciman',
    'imageUrl': kUrlPortadaRomano,
    'rating': 5,
  },
  {
    'title': 'Mi nombre es\nEmilia del Valle',
    'author': 'Isabel Allende',
    'imageUrl': kUrlPortadaEmilia,
    'rating': 5,
  },
  {
    'title': 'Amanecer en\nla cosecha',
    'author': 'Autor desconocido',
    'imageUrl': kUrlPortadaAmanecer,
    'rating': 5,
  },
  {
    'title': 'La muy catastrófica\nvisita al zoo',
    'author': 'Joel Dicker',
    'imageUrl': kUrlPortadaZoo,
    'rating': 5,
  },
  {
    'title': 'El albatros\nnegro',
    'author': 'María Oruña',
    'imageUrl': kUrlPortadaAlbatros,
    'rating': 5,
  },
  {
    'title': 'Nuestra desquiciada\nhistoria de amor',
    'author': 'Sandy Nelson',
    'imageUrl': kUrlPortadaDesquiciada,
    'rating': 5,
  },
  {
    'title': 'Cartas que nunca\nescribí',
    'author': 'Autor ficticio',
    'imageUrl': kUrlPortadaLetters,
    'rating': 4,
  },
  {
    'title': 'Arte y creatividad',
    'author': 'Varios autores',
    'imageUrl': kUrlPortadaArt,
    'rating': 4,
  },
  {
    'title': 'Historia del diseño',
    'author': 'Autor ficticio',
    'imageUrl': kUrlPortadaDesign,
    'rating': 4,
  },
  {
    'title': 'Volvemos a empezar',
    'author': 'Autor ficticio',
    'imageUrl': kUrlPortadaVolvemos,
    'rating': 4,
  },
  {
    'title': 'Woman',
    'author': 'Autor ficticio',
    'imageUrl': kUrlPortadaWoman,
    'rating': 4,
  },
  {
    'title': 'El Principito',
    'author': 'Antoine de Saint-Exupéry',
    'imageUrl': kUrlPortadaPrincipito,
    'rating': 5,
  },
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final onPrimary = scheme.onPrimary;
    final surface = scheme.surface;
    final surfaceHighest = scheme.surfaceContainerHighest;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buscar',
          style: TextStyle(
            color: onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: onPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Botón "Ver catálogo completo"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
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
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: surfaceHighest, // ✅ en vez de surfaceVariant
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
                  setState(() {
                    _selectedFilter = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filtros
          SizedBox(
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
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                        _searchController.text = filter;
                      });
                    },
                    backgroundColor: surface,
                    selectedColor: primary,
                    labelStyle: TextStyle(
                      color: isSelected ? onPrimary : scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? primary
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
          ),

          const SizedBox(height: 24),

          // Título sección
          Padding(
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
                      color: primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Grid de libros
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

      // Bottom bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
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
      ),
    );
  }

  Widget _buildBookCard(
    Map<String, dynamic> book,
    ColorScheme scheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen (SIEMPRE de red)
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
                    book['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.book,
                          size: 40,
                          color: scheme.outline,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Marcador
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.azulSecundario,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          book['title'].split('\n')[0],
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
            book['rating'] as int,
            (index) => const Icon(
              Icons.star,
              color: AppTheme.amarilloEstrella,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }
}
