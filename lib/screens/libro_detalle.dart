import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme.dart';

class PaginaDetalleLibro extends StatefulWidget {
  final String libroId;
  final Map<String, dynamic> datosLibro;

  const PaginaDetalleLibro({
    super.key,
    required this.libroId,
    required this.datosLibro,
  });

  @override
  State<PaginaDetalleLibro> createState() => _PaginaDetalleLibroState();
}

class _PaginaDetalleLibroState extends State<PaginaDetalleLibro> {
  bool _esFavorito = false;
  bool _cargando = false;

  static const double _bookWidth = 160;
  static const double _bookHeight = 200;
  static const double _bookRadius = 8;

  @override
  void initState() {
    super.initState();
    _verificarSiEsFavorito();
  }

  // VERIFICAR FAVORITOS
  Future<void> _verificarSiEsFavorito() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('mis_favoritos')
          .doc(widget.libroId)
          .get();

      setState(() {
        _esFavorito = doc.exists;
      });
    } catch (e) {
      setState(() {
        _esFavorito = false;
      });
    }
  }

  // CRUD FAVORITOS
  Future<void> _manejarFavorito() async {
    setState(() => _cargando = true);

    try {
      if (_esFavorito) {
        // ELIMINAR
        await FirebaseFirestore.instance
            .collection('mis_favoritos')
            .doc(widget.libroId)
            .delete();
        setState(() {
          _esFavorito = false;
          _cargando = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Eliminado de favoritos'),
              duration: const Duration(seconds: 2),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } else {
        // AGREGAR
        await FirebaseFirestore.instance
            .collection('mis_favoritos')
            .doc(widget.libroId)
            .set({
          'titulo': widget.datosLibro['titulo'],
          'autor': widget.datosLibro['autor'],
          'imagenUrl': widget.datosLibro['imagenUrl'],
          'calificacion': widget.datosLibro['calificacion'],
          'categorias': widget.datosLibro['categorias'],
          'paginas': widget.datosLibro['paginas'],
          'esFavorito': true,
        });
        setState(() {
          _esFavorito = true;
          _cargando = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Agregado a favoritos'),
              duration: const Duration(seconds: 2),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.datosLibro['titulo'] ?? 'Sin título';
    final autor = widget.datosLibro['autor'] ?? 'Autor desconocido';
    final imagenUrl = widget.datosLibro['imagenUrl'] ?? '';
    final calificacion = (widget.datosLibro['calificacion'] ?? 0).toInt();
    final categorias = List<String>.from(widget.datosLibro['categorias'] ?? []);
    final paginas = widget.datosLibro['paginas'] ?? 0;

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
          const IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: null,
          ),
          const IconButton(
            icon: Icon(Icons.flag_outlined, color: Colors.white),
            onPressed: null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            //IMAGEN LIBRO
            Center(
              child: SizedBox(
                width: _bookWidth,
                height: _bookHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_bookRadius),
                  child: Container(
                    color: Colors.grey[300],
                    child: Image.asset(
                      imagenUrl,
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
            ),

            const SizedBox(height: 20),

            // TÍTULO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // AUTOR
            Text(
              autor,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // CALIFICACIÓN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < calificacion ? Icons.star : Icons.star_border,
                  color: AppTheme.amarilloEstrella,
                  size: 24,
                );
              }),
            ),
            const SizedBox(height: 16),

            // CATEGORÍAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: categorias.map((categoria) {
                  return Chip(
                    label: Text(categoria),
                    backgroundColor: AppTheme.azulSecundario,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // BOTÓN LEER
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Leer Libro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.naranjaOscuro,
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

            const SizedBox(height: 24),

            // TABS
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: scheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: scheme.primary,
                    tabs: const [
                      Tab(text: 'LIBRO'),
                      Tab(text: 'REVIEW'),
                      Tab(text: 'ESTADÍSTICAS'),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        _construirTabProgreso(paginas),
                        const Center(child: Text('Reseñas')),
                        const Center(child: Text('Estadísticas')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _construirTabProgreso(int paginas) {
    return SingleChildScrollView(
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
              color: AppTheme.azulSecundario,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '0 de $paginas Páginas leídas',
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
