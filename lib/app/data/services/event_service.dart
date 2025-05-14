import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/event_model.dart';

class EventService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _collection = 'events';

  Future<List<Event>> fetchEvents() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => Event.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    required File? imageFile,
  }) async {
    final imageUrl = await _uploadImage(imageFile);
    await _firestore.collection(_collection).add({
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate,
      'imageUrl': imageUrl,
    });
  }

  Future<void> editEvent({
    required String docId,
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    required String oldImageUrl,
    required File? newImageFile,
    required bool deleteOldImage,
  }) async {
    String updatedImageUrl = oldImageUrl;

    // Hapus gambar lama jika diminta dan ada gambar baru
    if (deleteOldImage && newImageFile != null) {
      await _storage.refFromURL(oldImageUrl).delete();
      updatedImageUrl = await _uploadImage(newImageFile);
    }

    await _firestore.collection(_collection).doc(docId).update({
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate,
      'imageUrl': updatedImageUrl,
    });
  }

  Future<void> deleteEvent({
    required String docId,
    required String imageUrl,
  }) async {
    await _storage.refFromURL(imageUrl).delete();
    await _firestore.collection(_collection).doc(docId).delete();
  }

  Future<String> _uploadImage(File? imageFile) async {
    if (imageFile == null) return '';
    final ref = _storage.ref().child(
      'event_images/${DateTime.now().millisecondsSinceEpoch}',
    );
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}
