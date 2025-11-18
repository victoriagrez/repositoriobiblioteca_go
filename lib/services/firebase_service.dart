import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/libro.dart';

class ServicioFirebase {
  final CollectionReference _favoritos =
      FirebaseFirestore.instance.collection('mis_favoritos');

  //AGREGAR FAVS
  Future<bool> agregarAFavoritos(Libro libro) async {
    try {
      await _favoritos.doc(libro.id).set(libro.aFirebase());
      debugPrint('Libro agregado a favoritos: ${libro.titulo}');
      return true;
    } catch (error) {
      debugPrint('Error al agregar favorito: $error');
      return false;
    }
  }

  Stream<List<Libro>> obtenerFavoritos() {
    return _favoritos.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Libro.desdeFirebase(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  Future<bool> esFavorito(String libroId) async {
    try {
      final doc = await _favoritos.doc(libroId).get();
      return doc.exists;
    } catch (error) {
      debugPrint('Error al verificar favorito: $error');
      return false;
    }
  }

  Future<bool> actualizarFavorito(Libro libro) async {
    try {
      await _favoritos.doc(libro.id).update(libro.aFirebase());
      debugPrint('Favorito actualizado: ${libro.titulo}');
      return true;
    } catch (error) {
      debugPrint('Error al actualizar favorito: $error');
      return false;
    }
  }

  Future<bool> eliminarDeFavoritos(String libroId) async {
    try {
      await _favoritos.doc(libroId).delete();
      debugPrint('Libro eliminado de favoritos');
      return true;
    } catch (error) {
      debugPrint('Error al eliminar favorito: $error');
      return false;
    }
  }

  Future<bool> alternarFavorito(Libro libro) async {
    final yaEsFavorito = await esFavorito(libro.id);
    
    if (yaEsFavorito) {
      return await eliminarDeFavoritos(libro.id);
    } else {
      return await agregarAFavoritos(libro);
    }
  }
}