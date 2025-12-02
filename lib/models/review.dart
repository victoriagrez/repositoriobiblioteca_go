import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String libroId;
  final String usuarioId;
  final String nombreUsuario;
  final String fotoPerfilUrl;
  final int calificacion;
  final String textoResena;
  final DateTime fecha;

  Review({
    required this.id,
    required this.libroId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.fotoPerfilUrl,
    required this.calificacion,
    required this.textoResena,
    required this.fecha,
  });

  Review copiarCon({
    String? id,
    String? libroId,
    String? usuarioId,
    String? nombreUsuario,
    String? fotoPerfilUrl,
    int? calificacion,
    String? textoResena,
    DateTime? fecha,
  }) {
    return Review(
      id: id ?? this.id,
      libroId: libroId ?? this.libroId,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      calificacion: calificacion ?? this.calificacion,
      textoResena: textoResena ?? this.textoResena,
      fecha: fecha ?? this.fecha,
    );
  }

  factory Review.desdeFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['fecha'] as Timestamp?;
    return Review(
      id: doc.id,
      libroId: data['libroId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      nombreUsuario: data['nombreUsuario'] ?? '',
      fotoPerfilUrl: data['fotoPerfilUrl'] ?? '',
      calificacion: (data['calificacion'] ?? 0).toInt(),
      textoResena: data['textoResena'] ?? '',
      fecha: timestamp != null ? timestamp.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'libroId': libroId,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'fotoPerfilUrl': fotoPerfilUrl,
      'calificacion': calificacion,
      'textoResena': textoResena,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}
