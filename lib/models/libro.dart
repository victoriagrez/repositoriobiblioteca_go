// lib/models/libro.dart

class Libro {
  String id;
  String titulo;
  String autor;
  String imagenUrl;
  double calificacion;
  List<String> categorias;
  int paginas;
  bool esFavorito;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.imagenUrl,
    this.calificacion = 0.0,
    this.categorias = const [],
    this.paginas = 0,
    this.esFavorito = false,
  });

  // Convertir de Firebase a Libro
  factory Libro.desdeFirebase(Map<String, dynamic> datos, String id) {
    return Libro(
      id: id,
      titulo: datos['titulo'] ?? '',
      autor: datos['autor'] ?? '',
      imagenUrl: datos['imagenUrl'] ?? '',
      calificacion: (datos['calificacion'] ?? 0.0).toDouble(),
      categorias: List<String>.from(datos['categorias'] ?? []),
      paginas: datos['paginas'] ?? 0,
      esFavorito: datos['esFavorito'] ?? false,
    );
  }

  // Convertir de Libro a Map para Firebase
  Map<String, dynamic> aFirebase() {
    return {
      'titulo': titulo,
      'autor': autor,
      'imagenUrl': imagenUrl,
      'calificacion': calificacion,
      'categorias': categorias,
      'paginas': paginas,
      'esFavorito': esFavorito,
    };
  }

  // Crear copia del libro con cambios
  Libro copiarCon({
    String? id,
    String? titulo,
    String? autor,
    String? imagenUrl,
    double? calificacion,
    List<String>? categorias,
    int? paginas,
    bool? esFavorito,
  }) {
    return Libro(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      calificacion: calificacion ?? this.calificacion,
      categorias: categorias ?? this.categorias,
      paginas: paginas ?? this.paginas,
      esFavorito: esFavorito ?? this.esFavorito,
    );
  }
}