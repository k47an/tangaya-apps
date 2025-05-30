// services
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/event_model.dart'; // Pastikan path ini benar

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
    double? price, // <-- Ubah menjadi nullable (double?)
  }) async {
    final imageUrl = await _uploadImage(imageFile);
    await _firestore.collection(_collection).add({
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate,
      'imageUrl': imageUrl,
      'price': price, // <-- Kirim price apa adanya
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
    double? price, // <-- Ubah menjadi nullable (double?)
  }) async {
    String updatedImageUrl = oldImageUrl;

    if (deleteOldImage && oldImageUrl.isNotEmpty) {
      try {
        if (oldImageUrl.startsWith('http')) {
          await _storage.refFromURL(oldImageUrl).delete();
        }
      } catch (e) {
        print("Error deleting old image: $e");
      }
      updatedImageUrl =
          newImageFile != null ? await _uploadImage(newImageFile) : '';
    } else if (newImageFile != null) {
      if (oldImageUrl.isNotEmpty && oldImageUrl.startsWith('http')) {
        try {
          await _storage.refFromURL(oldImageUrl).delete();
        } catch (e) {
          print("Error deleting old image during replacement: $e");
        }
      }
      updatedImageUrl = await _uploadImage(newImageFile);
    }

    await _firestore.collection(_collection).doc(docId).update({
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate,
      'imageUrl': updatedImageUrl,
      'price': price, // <-- Kirim price apa adanya
    });
  }

  Future<void> deleteEvent({
    required String docId,
    required String imageUrl,
  }) async {
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (e) {
        print("Error deleting image from storage: $e");
      }
    }
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
