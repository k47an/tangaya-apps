import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tracking_model.dart';

class TrackingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan daftar tracking dari Firestore
  Future<List<TrackingModel>> getTrackingList() async {
    try {
      QuerySnapshot snapshot = await _db.collection('tracking').get();
      return snapshot.docs
          .map(
            (doc) => TrackingModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      print('Error fetching tracking list: $e');
      return [];
    }
  }

  // Mendapatkan satu tracking berdasarkan ID
  Future<TrackingModel?> getTrackingById(String id) async {
    try {
      DocumentSnapshot doc = await _db.collection('tracking').doc(id).get();
      if (doc.exists) {
        return TrackingModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }
    } catch (e) {
      print('Error fetching tracking by ID: $e');
    }
    return null;
  }
}
