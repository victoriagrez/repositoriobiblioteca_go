import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/dialogo_agregar_review.dart';

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
  final ServicioReviews _servicioReviews = ServicioReviews();

  final String _usuarioActualId = 'usuario_demo_123';
  final String _nombreUsuario = 'Germán Martínez';
  final String _fotoPerfilUsuario =
      'https://via.placeholder.com/50'; 

  static const double _bookWidth = 160;
  static const double _bookHeight = 200;
  static const double _bookRadius = 8;

  @override
  void initState() {
    super.initState();
    _verificarSiEsFavorito();
  }

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

  Future<void> _manejarFavorito() async {
    setState(() => _cargando = true);

    try {
      if (_esFavorito) {
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

  Future<void> _mostrarDialogoReview({Review? reviewExistente}) async {
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DialogoAgregarReview(
        libroId: widget.libroId,
        reviewExistente: reviewExistente,
      ),
    );

    if (resultado != null) {
      if (reviewExistente == null) {

        await _crearReview(
          resultado['calificacion'],
          resultado['textoResena'],
        );
      } else {

        await _actualizarReview(
          reviewExistente,
          resultado['calificacion'],
          resultado['textoResena'],
        );
      }
    }
  }


  Future<void> _crearReview(int calificacion, String textoResena) async {
    try {
      final reviewExistente = await _servicioReviews
          .obtenerReviewUsuarioEnLibro(widget.libroId, _usuarioActualId);

      if (reviewExistente != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya has dejado una reseña para este libro'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final nuevaReview = Review(
        id: '', 
        libroId: widget.libroId,
        usuarioId: _usuarioActualId,
        nombreUsuario: _nombreUsuario,
        fotoPerfilUrl: _fotoPerfilUsuario,
        calificacion: calificacion,
        textoResena: textoResena,
        fecha: DateTime.now(),
      );

      final exitoso = await _servicioReviews.agregarReview(nuevaReview);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                exitoso ? 'Reseña publicada' : 'Error al publicar reseña'),
            backgroundColor:
                exitoso ? AppTheme.azulSecundario : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _actualizarReview(
      Review review, int calificacion, String textoResena) async {
    try {
      final reviewActualizada = review.copiarCon(
        calificacion: calificacion,
        textoResena: textoResena,
        fecha: DateTime.now(),
      );

      final exitoso =
          await _servicioReviews.actualizarReview(reviewActualizada);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exitoso
                ? 'Reseña actualizada'
                : 'Error al actualizar reseña'),
            backgroundColor:
                exitoso ? AppTheme.azulSecundario : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarReview(Review review) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reseña'),
        content: const Text('¿Estás seguro de que quieres eliminar tu reseña?'),
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

    if (confirmar == true) {
      try {
        final exitoso = await _servicioReviews.eliminarReview(review.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(exitoso
                  ? 'Reseña eliminada'
                  : 'Error al eliminar reseña'),
              backgroundColor: exitoso ? Colors.grey : Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.datosLibro['titulo'] ?? 'Sin título';
    final autor = widget.datosLibro['autor'] ?? 'Autor desconocido';
    final imagenUrl = widget.datosLibro['imagenUrl'] ?? '';
    final calificacion = (widget.datosLibro['calificacion'] ?? 0).toInt();
    final categorias =
        List<String>.from(widget.datosLibro['categorias'] ?? []);
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

            Center(
              child: SizedBox(
                width: _bookWidth,
                height: _bookHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_bookRadius),
                  child: Container(
                    color: Colors.grey[300],
                    child: imagenUrl.isNotEmpty
                        ? Image.network(
                            imagenUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.book,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.book,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

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

            Text(
              autor,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

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
                    height: 600,
                    child: TabBarView(
                      children: [
                        _construirTabProgreso(paginas),
                        _construirTabReviews(),
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

  Widget _construirTabReviews() {
    return StreamBuilder<List<Review>>(
      stream: _servicioReviews.obtenerReviewsPorLibro(widget.libroId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final reviews = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reviews Usuarios',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoReview(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.naranjaPrimario,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (reviews.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'Aún no hay reseñas.\n¡Sé el primero en dejar una!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                ...reviews.map((review) => _construirTarjetaReview(review)),
            ],
          ),
        );
      },
    );
  }

  Widget _construirTarjetaReview(Review review) {
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final esPropia = review.usuarioId == _usuarioActualId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.azulSecundario,
                backgroundImage: review.fotoPerfilUrl.isNotEmpty
                    ? NetworkImage(review.fotoPerfilUrl)
                    : null,
                child: review.fotoPerfilUrl.isEmpty
                    ? Text(
                        review.nombreUsuario[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.nombreUsuario,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatoFecha.format(review.fecha),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (esPropia)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _mostrarDialogoReview(reviewExistente: review);
                    } else if (value == 'eliminar') {
                      _eliminarReview(review);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                '${review.calificacion}/5',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                return Icon(
                  index < review.calificacion ? Icons.star : Icons.star_border,
                  color: AppTheme.amarilloEstrella,
                  size: 16,
                );
              }),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            review.textoResena,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),

          if (review.textoResena.length > 150)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(review.nombreUsuario),
                      content: SingleChildScrollView(
                        child: Text(review.textoResena),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Ver Más',
                  style: TextStyle(
                    color: AppTheme.naranjaPrimario,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
