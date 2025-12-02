import 'package:flutter/material.dart';
import '../models/review.dart';
import '../theme/theme.dart';

class DialogoAgregarReview extends StatefulWidget {
  final String libroId;
  final Review? reviewExistente;

  const DialogoAgregarReview({
    super.key,
    required this.libroId,
    this.reviewExistente,
  });

  @override
  State<DialogoAgregarReview> createState() => _DialogoAgregarReviewState();
}

class _DialogoAgregarReviewState extends State<DialogoAgregarReview> {
  late int _calificacion;
  late TextEditingController _textoController;

  @override
  void initState() {
    super.initState();
    _calificacion = widget.reviewExistente?.calificacion ?? 3;
    _textoController = TextEditingController(
      text: widget.reviewExistente?.textoResena ?? '',
    );
  }

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  void _guardar() {
    final texto = _textoController.text.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un comentario')),
      );
      return;
    }

    Navigator.pop<Map<String, dynamic>>(context, {
      'calificacion': _calificacion,
      'textoResena': texto,
    });
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.reviewExistente != null;

    return AlertDialog(
      title: Text(esEdicion ? 'Editar reseña' : 'Agregar reseña'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Calificación',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final selected = starIndex <= _calificacion;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _calificacion = starIndex;
                    });
                  },
                  icon: Icon(
                    selected ? Icons.star : Icons.star_border,
                    color: AppTheme.amarilloEstrella,
                  ),
                  padding: EdgeInsets.zero,
                );
              }),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Comentario',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textoController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe tu opinión sobre el libro...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: Text(esEdicion ? 'Actualizar' : 'Publicar'),
        ),
      ],
    );
  }
}
