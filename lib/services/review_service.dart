import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ServicioReviews {
  final CollectionReference _reviewsRef =
      FirebaseFirestore.instance.collection('reviews');

  Stream<List<Review>> obtenerReviewsPorLibro(String libroId) {
    return _reviewsRef
        .where('libroId', isEqualTo: libroId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Review.desdeFirestore(doc))
          .toList();
    });
  }

  Future<Review?> obtenerReviewUsuarioEnLibro(
      String libroId, String usuarioId) async {
    final query = await _reviewsRef
        .where('libroId', isEqualTo: libroId)
        .where('usuarioId', isEqualTo: usuarioId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return Review.desdeFirestore(query.docs.first);
  }

  Future<bool> agregarReview(Review review) async {
    try {
      await _reviewsRef.add(review.aMapa());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizarReview(Review review) async {
    try {
      await _reviewsRef.doc(review.id).update(review.aMapa());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminarReview(String reviewId) async {
    try {
      await _reviewsRef.doc(reviewId).delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}
