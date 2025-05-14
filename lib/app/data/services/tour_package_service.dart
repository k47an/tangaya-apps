import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:tangaya_apps/app/data/models/tour_package_model.dart';

class TourPackageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  // Menambahkan paket wisata baru
  Future<void> addTourPackage({
    required String title,
    required String description,
    required double price,
    required List<File?> imageFiles,
  }) async {
    try {
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        for (var imageFile in imageFiles) {
          if (imageFile != null) {
            String? imageUrl = await uploadImage(imageFile);
            if (imageUrl != null) {
              imageUrls.add(imageUrl);
            }
          }
        }
      }

      await _firestore.collection('tour-package').add({
        'title': title,
        'description': description,
        'price': price,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrls': imageUrls,
      });
    } catch (e) {
      throw Exception('Gagal menambahkan paket wisata: $e');
    }
  }

  // Mengunggah gambar ke Firebase Storage dan mengembalikan URL-nya
  Future<String?> uploadImage(File imageFile) async {
    try {
      firebase_storage.Reference ref = _storage.ref().child(
        'tour_images/${DateTime.now().millisecondsSinceEpoch}',
      );
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }

  // Mengambil daftar paket wisata
  Future<List<TourPackage>> fetchTourPackages() async {
    try {
      final snapshot = await _firestore.collection('tour-package').get();
      return snapshot.docs.map((doc) {
        return TourPackage.fromDocument(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil paket wisata: $e');
    }
  }

  // Mengedit paket wisata
  Future<void> editTourPackage({
    required String docId,
    required String newTitle,
    required String newDescription,
    required double newPrice,
    required List<String> oldImageUrls,
    required List<File?> newImageFiles,
    required List<String> imagesToDelete, // Add images to be deleted
  }) async {
    try {
      // Menghapus gambar lama yang tidak dibutuhkan
      for (final url in imagesToDelete) {
        try {
          final ref = await _storage.refFromURL(url);
          await ref.delete();
          print("Deleted image: $url");
        } catch (e) {
          print("Error deleting image: $e");
        }
      }

      // Mengunggah gambar baru
      List<String> newUrls = [];
      for (final file in newImageFiles) {
        if (file != null) {
          final url = await uploadImage(file);
          if (url != null) newUrls.add(url);
        }
      }

      // Update Firestore
      await _firestore.collection('tour-package').doc(docId).update({
        'title': newTitle,
        'description': newDescription,
        'price': newPrice,
        'imageUrls': [
          ...oldImageUrls.where((url) => !imagesToDelete.contains(url)),
          ...newUrls,
        ],
      });
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
      // Menghapus gambar yang terkait
      for (final url in imageUrls) {
        try {
          final ref = await _storage.refFromURL(url);
          await ref.delete();
        } catch (_) {}
      }

      // Menghapus data paket wisata
      await _firestore.collection('tour-package').doc(docId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus paket wisata: $e');
    }
  }
}
