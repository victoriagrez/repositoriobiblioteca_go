import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import '../theme/theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
//METAS EJ: 
  final List<Map<String, dynamic>> _metas = [
    {'titulo': 'Rastrear y mejorar mis hábitos', 'seleccionada': false},
    {'titulo': 'Compartir mi viaje de lectura', 'seleccionada': false},
    {'titulo': 'Organizar mi biblioteca', 'seleccionada': false},
    {'titulo': 'Recordar mejor lo que leo', 'seleccionada': false},
    {'titulo': 'Descubrir nuevos libros', 'seleccionada': false},
  ];

  bool _guardando = false;

  void _cambiarSeleccion(int index) {
    setState(() {
      _metas[index]['seleccionada'] = !_metas[index]['seleccionada'];
    });
  }

// CRUD METAS
  Future<void> _guardarMetas() async {
    setState(() => _guardando = true);

    try {
    //SELECCION META
      final metasSeleccionadas = _metas
          .where((meta) => meta['seleccionada'] == true)
          .map((meta) => meta['titulo'])
          .toList();

      if (metasSeleccionadas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona al menos una meta'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _guardando = false);
        return;
      }

    //FIREBASE METAS LECTURA
      await FirebaseFirestore.instance.collection('metas_lectura').add({
        'metas': metasSeleccionadas,
        'fecha': FieldValue.serverTimestamp(),
        'completado': false,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar metas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              const Text(
                '¿Cuáles son tus\nmetas?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Esto personalizará tu experiencia y nos ayudará a priorizar futuras actualizaciones',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Icon(
                Icons.star,
                color: AppTheme.amarilloEstrella,
                size: 32,
              ),
              
              const SizedBox(height: 32),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _metas.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _construirBotonMeta(
                        _metas[index]['titulo'],
                        _metas[index]['seleccionada'],
                        () => _cambiarSeleccion(index),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
            // BOTON CONTINUAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardarMetas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

//BOTON 
  Widget _construirBotonMeta(String titulo, bool seleccionada, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: seleccionada ? scheme.primary.withOpacity(0.12) : Colors.white,
          border: Border.all(
            color: seleccionada ? scheme.primary : const Color(0xFFE0E0E0),
            width: seleccionada ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          titulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: seleccionada ? scheme.primary : Colors.grey[500],
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
