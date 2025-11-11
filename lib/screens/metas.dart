import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      builder: (context) => AlertDialog(
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
              backgroundColor: const Color(0xFFE85D2E),
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
                  const SnackBar(
                    content: Text('Meta agregada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // CRUD (EDITAR) :0
  void _editarMeta(String docId, List<dynamic> metasActuales) async {
    final controlador = TextEditingController(text: metasActuales.join('\n'));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              backgroundColor: const Color(0xFFE85D2E),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final texto = controlador.text.trim();
              if (texto.isNotEmpty) {
                final nuevasMetas = texto.split('\n')
                    .where((linea) => linea.trim().isNotEmpty)
                    .toList();
                    
                await FirebaseFirestore.instance
                    .collection('metas_lectura')
                    .doc(docId)
                    .update({'metas': nuevasMetas});
                    
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Metas actualizadas'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

// CRUD 1 (ELIMINAR) :(
  void _eliminarMeta(String docId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Meta'),
        content: const Text('¿Estás seguro de eliminar esta meta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance
          .collection('metas_lectura')
          .doc(docId)
          .delete();
          
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meta eliminada'),
          backgroundColor: Colors.red,
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
        backgroundColor: completadoActual ? Colors.orange : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE85D2E),
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
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE85D2E)),
            );
          }

//ERROR?...
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

//SI NO HAY META...
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
                            onChanged: (_) => _marcarCompletada(doc.id, completado),
                            activeColor: const Color(0xFFE85D2E),
                          ),
                          Expanded(
                            child: Text(
                              completado ? '✓ Completado' : 'En progreso',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: completado ? Colors.green : Colors.orange,
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
                              color: Color(0xFF28A9B8),
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
        backgroundColor: const Color(0xFFE85D2E),
        onPressed: _agregarMeta,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}