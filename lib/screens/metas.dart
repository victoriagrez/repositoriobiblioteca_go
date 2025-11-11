import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme.dart';

class PaginaMetas extends StatefulWidget {
  const PaginaMetas({super.key});

  @override
  State<PaginaMetas> createState() => _PaginaMetasState();
}

class _PaginaMetasState extends State<PaginaMetas> {
// CRUD 1 METAS EN ONBOARDING :)
  void _agregarMeta() async {
    final controlador = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Nueva Meta de Lectura'),
          content: TextField(
            controller: controlador,
            decoration: const InputDecoration(
              labelText: 'Escribe tu meta',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final texto = controlador.text.trim();
                if (texto.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('metas_lectura')
                      .add({
                    'metas': [texto],
                    'fecha': FieldValue.serverTimestamp(),
                    'completado': false,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Meta agregada correctamente'),
                      backgroundColor: scheme.secondary,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // CRUD (EDITAR)
  void _editarMeta(String docId, List<dynamic> metasActuales) async {
    final controlador = TextEditingController(text: metasActuales.join('\n'));

    await showDialog(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Editar Metas'),
          content: TextField(
            controller: controlador,
            decoration: const InputDecoration(
              labelText: 'Edita tus metas',
              border: OutlineInputBorder(),
              hintText: 'Escribe cada meta en una línea',
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final texto = controlador.text.trim();
                if (texto.isNotEmpty) {
                  final nuevasMetas = texto
                      .split('\n')
                      .where((linea) => linea.trim().isNotEmpty)
                      .toList();

                  await FirebaseFirestore.instance
                      .collection('metas_lectura')
                      .doc(docId)
                      .update({'metas': nuevasMetas});

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Metas actualizadas'),
                      backgroundColor: scheme.secondary,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarMeta(String docId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Eliminar Meta'),
          content: const Text('¿Estás seguro de eliminar esta meta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance
          .collection('metas_lectura')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meta eliminada'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

//COMPLETAR
  void _marcarCompletada(String docId, bool completadoActual) async {
    await FirebaseFirestore.instance
        .collection('metas_lectura')
        .doc(docId)
        .update({'completado': !completadoActual});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completadoActual ? 'Meta marcada como pendiente' : 'Meta completada ✓',
        ),
        backgroundColor:
            completadoActual ? Colors.orange : Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        title: const Row(
          children: [
            Icon(Icons.flag, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Mis Metas de Lectura',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('metas_lectura')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: scheme.primary),
            );
          }


          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes metas registradas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

// CRUD 1 MOSTRAR META
          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final metas = List<String>.from(data['metas'] ?? []);
              final completado = data['completado'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //HEADER
                      Row(
                        children: [
                          Checkbox(
                            value: completado,
                            onChanged: (_) =>
                                _marcarCompletada(doc.id, completado),
                            activeColor: scheme.primary,
                          ),
                          Expanded(
                            child: Text(
                              completado ? '✓ Completado' : 'En progreso',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: completado ? scheme.secondary : Colors.orange,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'editar') {
                                _editarMeta(doc.id, metas);
                              } else if (value == 'eliminar') {
                                _eliminarMeta(doc.id);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'editar',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'eliminar',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      //LISTA
                      ...metas.map((meta) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.azulSecundario,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    meta,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: scheme.primary,
        onPressed: _agregarMeta,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
