import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';

class EventService extends GetxService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final String _collectionPath = 'events';

  Future<List<Event>> fetchEvents() async {
    final snapshot =
        await _firestore
            .collection(_collectionPath)
            .orderBy('eventDate', descending: true)
            .get();
    return snapshot.docs
        .map((doc) => Event.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    required File imageFile,
    double? price,
  }) async {
    String imageUrl = await _uploadImage(imageFile);
    await _firestore.collection(_collectionPath).add({
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate,
      'imageUrl': imageUrl,
      'price': price,
    });
  }

  Future<void> editEvent({
    required String docId,
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    String? oldImageUrl,
    File? newImageFile,
    double? price,
  }) async {
    String finalImageUrl = oldImageUrl ?? '';

    if (newImageFile != null) {
      finalImageUrl = await _uploadImage(newImageFile);
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          await _storage.refFromURL(oldImageUrl).delete();
        } catch (e) {
          print("Gagal menghapus gambar lama saat mengganti: $e");
        }
      }
    }

    await _firestore.collection(_collectionPath).doc(docId).update({
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate,
      'imageUrl': finalImageUrl,
      'price': price,
    });
  }

  Future<void> deleteEvent({
    required String docId,
    required String imageUrl,
  }) async {
    if (imageUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (e) {
        print("Gagal menghapus gambar dari storage: $e");
      }
    }
    await _firestore.collection(_collectionPath).doc(docId).delete();
  }

  Future<String> _uploadImage(File imageFile) async {
    final ref = _storage.ref().child(
      'event_images/${DateTime.now().millisecondsSinceEpoch}',
    );
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<Event?> getEventById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Event.fromJson(doc.data()!, doc.id);
      }
      return null; 
    } catch (e) {
      print("Error fetching event by ID: $e");
      throw Exception('Gagal mengambil detail event: $e');
    }
  }
}
