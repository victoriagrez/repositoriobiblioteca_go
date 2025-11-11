import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/libro.dart';

class ServicioFirebase {
  final CollectionReference _favoritos =
      FirebaseFirestore.instance.collection('mis_favoritos');

  //AGREGAR FAVS
  Future<bool> agregarAFavoritos(Libro libro) async {
    try {
      await _favoritos.doc(libro.id).set(libro.aFirebase());
      print('Libro agregado a favoritos: ${libro.titulo}');
      return true;
    } catch (error) {
      print('Error al agregar favorito: $error');
      return false;
    }
  }

  //READ
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

  //VERIFICAR FAV
  Future<bool> esFavorito(String libroId) async {
    try {
      final doc = await _favoritos.doc(libroId).get();
      return doc.exists;
    } catch (error) {
      print('Error al verificar favorito: $error');
      return false;
    }
  }

  //ACTUALIZAR FAVS
  Future<bool> actualizarFavorito(Libro libro) async {
    try {
      await _favoritos.doc(libro.id).update(libro.aFirebase());
      print('Favorito actualizado: ${libro.titulo}');
      return true;
    } catch (error) {
      print('Error al actualizar favorito: $error');
      return false;
    }
  }

  //ELIMINAR FAVS
  Future<bool> eliminarDeFavoritos(String libroId) async {
    try {
      await _favoritos.doc(libroId).delete();
      print('Libro eliminado de favoritos');
      return true;
    } catch (error) {
      print('Error al eliminar favorito: $error');
      return false;
    }
  }

  //+ O -
  Future<bool> alternarFavorito(Libro libro) async {
    final yaEsFavorito = await esFavorito(libro.id);
    
    if (yaEsFavorito) {
      return await eliminarDeFavoritos(libro.id);
    } else {
      return await agregarAFavoritos(libro);
    }
  }
}