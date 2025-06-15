import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';

class TourPackageService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  // Menambahkan paket wisata baru
  Future<void> addTourPackage({
    required String title,
    required String description,
    required double price,
    required List<File> imageFiles,
  }) async {
    try {
      List<String> imageUrls = [];
      for (var imageFile in imageFiles) {
        String? imageUrl = await _uploadImage(imageFile);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }

      final newTourPackage = TourPackage(
        title: title,
        description: description,
        price: price,
        imageUrls: imageUrls,
      );

      await _firestore.collection('tours').add(newTourPackage.toJson());
    } catch (e) {
      throw Exception('Gagal menambahkan paket wisata: $e');
    }
  }

  // Mengunggah gambar ke Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName =
          'tour_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      firebase_storage.Reference ref = _storage.ref().child(fileName);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Gagal mengunggah gambar: $e');
      return null;
    }
  }

  // Mengambil daftar paket wisata
  Future<List<TourPackage>> fetchTourPackages() async {
    try {
      final snapshot = await _firestore.collection('tours').get();
      return snapshot.docs
          .map((doc) => TourPackage.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil paket wisata: $e');
    }
  }

  // Mengambil detail paket wisata berdasarkan ID
  Future<TourPackage?> getTourPackageById(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('tours').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return TourPackage.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil detail paket wisata: $e');
    }
  }

  // Mengedit paket wisata
  Future<void> editTourPackage({
    required String docId,
    required String newTitle,
    required String newDescription,
    required double newPrice,
    required List<String> oldImageUrls,
    required List<File> newImageFiles,
    required List<String> imagesToDelete,
  }) async {
    try {
      // Hapus gambar lama dari storage
      for (final url in imagesToDelete) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (e) {
          print("Gagal menghapus gambar lama: $e");
        }
      }

      // Unggah gambar baru
      List<String> newUrls = [];
      for (final file in newImageFiles) {
        final url = await _uploadImage(file);
        if (url != null) newUrls.add(url);
      }

      final updatedTourPackageData = {
        'title': newTitle,
        'description': newDescription,
        'price': newPrice,
        'imageUrls': [
          ...oldImageUrls.where((url) => !imagesToDelete.contains(url)),
          ...newUrls,
        ],
      };

      await _firestore
          .collection('tours')
          .doc(docId)
          .update(updatedTourPackageData);
    } catch (e) {
      throw Exception('Gagal mengedit paket wisata: $e');
    }
  }

  // Menghapus paket wisata
  Future<void> deleteTourPackage({
    required String docId,
    required List<String> imageUrls,
  }) async {
    try {
      for (final url in imageUrls) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (_) {}
      }
      await _firestore.collection('tours').doc(docId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus paket wisata: $e');
    }
  }
}
