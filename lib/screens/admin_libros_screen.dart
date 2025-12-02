import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/theme.dart';

class AdminLibrosScreen extends StatefulWidget {
  const AdminLibrosScreen({super.key});

  @override
  State<AdminLibrosScreen> createState() => _AdminLibrosScreenState();
}

class _AdminLibrosScreenState extends State<AdminLibrosScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _paginasController = TextEditingController();
  final TextEditingController _categoriasController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String? _imagenUrl;
  String? _editingId;
  bool _isSaving = false;

  CollectionReference get _librosRef =>
      FirebaseFirestore.instance.collection('libros_admin');

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _paginasController.dispose();
    _categoriasController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (picked == null) return;

      final file = File(picked.path);
      final String fileName =
          'portadas_libros/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();

      setState(() {
        _imagenUrl = url;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir la imagen')),
      );
    }
  }

  void _openForm({DocumentSnapshot? doc}) {
    if (doc != null) {
      _editingId = doc.id;
      final data = doc.data() as Map<String, dynamic>;
      _tituloController.text = data['titulo'] ?? '';
      _autorController.text = data['autor'] ?? '';
      _paginasController.text = (data['paginas'] ?? '').toString();
      _categoriasController.text =
          (data['categorias'] as List<dynamic>? ?? []).join(', ');
      _imagenUrl = data['imagenUrl'];
    } else {
      _editingId = null;
      _tituloController.clear();
      _autorController.clear();
      _paginasController.clear();
      _categoriasController.clear();
      _imagenUrl = null;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text(_editingId == null ? 'Nuevo libro' : 'Editar libro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          color: Colors.grey.shade200,
                          image: _imagenUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_imagenUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _imagenUrl == null
                            ? const Icon(Icons.add_a_photo, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _imagenUrl == null
                            ? 'Toca para subir portada'
                            : 'Toca para cambiar portada',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _autorController,
                  decoration: const InputDecoration(
                    labelText: 'Autor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _paginasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Páginas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _categoriasController,
                  decoration: const InputDecoration(
                    labelText: 'Categorías (separadas por coma)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: _isSaving ? null : _saveLibro,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveLibro() async {
    final titulo = _tituloController.text.trim();
    final autor = _autorController.text.trim();
    final paginas = int.tryParse(_paginasController.text.trim()) ?? 0;
    final categoriasTexto = _categoriasController.text.trim();

    if (titulo.isEmpty || autor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa al menos título y autor')),
      );
      return;
    }

    final categorias = categoriasTexto.isEmpty
        ? <String>[]
        : categoriasTexto
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    setState(() {
      _isSaving = true;
    });

    try {
      final data = {
        'titulo': titulo,
        'autor': autor,
        'paginas': paginas,
        'categorias': categorias,
        'imagenUrl': _imagenUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_editingId == null) {
        await _librosRef.add(data);
      } else {
        await _librosRef.doc(_editingId).update(data);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingId == null
                  ? 'Libro creado correctamente'
                  : 'Libro actualizado correctamente',
            ),
            backgroundColor: AppTheme.azulSecundario,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el libro')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteLibro(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: const Text('¿Seguro que quieres eliminar este libro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await _librosRef.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar libros'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _librosRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar libros'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Aún no has agregado libros'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final titulo = data['titulo'] ?? '';
              final autor = data['autor'] ?? '';
              final imagenUrl = data['imagenUrl'] as String?;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imagenUrl == null || imagenUrl.isEmpty
                        ? Container(
                            width: 48,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(Icons.book, color: Colors.grey),
                          )
                        : Image.network(
                            imagenUrl,
                            width: 48,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 70,
                              color: Colors.grey[300],
                              child: const Icon(Icons.book, color: Colors.grey),
                            ),
                          ),
                  ),
                  title: Text(titulo),
                  subtitle: Text(autor),
                  onTap: () => _openForm(doc: doc),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: scheme.error),
                    onPressed: () => _deleteLibro(doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
