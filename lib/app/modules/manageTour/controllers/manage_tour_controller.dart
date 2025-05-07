// manage_tour_controller.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageTourController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TabController tabController;
  final RxInt currentTab = 0.obs;
  final List<String> tabs = ['Tour Package', 'Events'];
  final RxBool isLoading = false.obs;
  var title = ''.obs;
  var description = ''.obs;
  var price = 0.0.obs;

  final RxList<String> existingImageUrls = <String>[].obs;

  final RxString userRole = ''.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final RxList<File?> selectedImages = <File?>[].obs;

  final RxList<Map<String, dynamic>> tourPackages =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      currentTab.value = tabController.index;
    });

    fetchUserRole();
    fetchTourPackages();
  }

  @override
  void onClose() {
    tabController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> fetchUserRole() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists && userDoc.data()!.containsKey('role')) {
          userRole.value = userDoc['role'];
        }
      }
    } catch (e) {
      print("Gagal mengambil role user: $e");
    }
  }

  Future<void> addTourPackage({
    required String title,
    required String description,
    required double price,
    List<File?>? imageFiles,
  }) async {
    if (userRole.value != 'admin') {
      Get.snackbar('Akses ditolak', 'Hanya admin yang dapat menambahkan paket');
      return;
    }

    isLoading.value = true;

    try {
      List<String> imageUrls = [];
      if (imageFiles != null && imageFiles.isNotEmpty) {
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

      Get.snackbar('Sukses', 'Paket tour berhasil ditambahkan');
      await fetchTourPackages();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      firebase_storage.Reference ref = _storage.ref().child(
        'tour_images/${DateTime.now().millisecondsSinceEpoch}',
      );
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> fetchTourPackages() async {
    try {
      final snapshot = await _firestore.collection('tour-package').get();
      tourPackages.assignAll(
        snapshot.docs.map(
          (doc) => {
            'id': doc.id,
            'title': doc['title'],
            'description': doc['description'],
            'price': doc['price'],
            'imageUrls': List<String>.from(doc['imageUrls']),
          },
        ),
      );
    } catch (e) {
      print("Error fetching tour packages: $e");
    }
  }

  Future<void> editTourPackage(
    String docId,
    String newTitle,
    String newDescription,
    double newPrice,
    List<String> oldImageUrls,
    List<File?> newImageFiles,
  ) async {
    if (userRole.value != 'admin') {
      Get.snackbar('Akses ditolak', 'Hanya admin yang dapat mengedit paket');
      return;
    }

    isLoading.value = true;

    try {
      // Menghapus gambar lama
      for (final url in oldImageUrls) {
        try {
          final ref = await _storage.refFromURL(url);
          await ref.delete();
        } catch (_) {}
      }

      // Mengunggah gambar baru
      List<String> newUrls = [];
      for (final file in newImageFiles) {
        if (file != null) {
          final url = await uploadImage(file);
          if (url != null) newUrls.add(url);
        }
      }
    
      // Update data tour package
      await _firestore.collection('tour-package').doc(docId).update({
        'title': newTitle,
        'description': newDescription,
        'price': newPrice,
        'imageUrls': newUrls,
      });

      Get.snackbar('Berhasil', 'Paket berhasil diperbarui');
      await fetchTourPackages();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengedit paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTourPackage(String docId, List<String> imageUrls) async {
    if (userRole.value != 'admin') {
      Get.snackbar('Akses ditolak', 'Hanya admin yang dapat menghapus paket');
      return;
    }

    isLoading.value = true;

    try {
      // Hapus gambar yang terkait
      for (final url in imageUrls) {
        try {
          final ref = await _storage.refFromURL(url);
          await ref.delete();
        } catch (_) {}
      }

      // Hapus data paket wisata
      await _firestore.collection('tour-package').doc(docId).delete();
      Get.snackbar('Berhasil', 'Paket berhasil dihapus');
      await fetchTourPackages();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadExistingImages(String docId) async {
    try {
      var doc = await _firestore.collection('tour-package').doc(docId).get();
      if (doc.exists) {
        final urls = List<String>.from(doc.data()?['imageUrls'] ?? []);
        existingImageUrls.assignAll(urls);
      }
    } catch (e) {
      print("Gagal memuat gambar lama: $e");
    }
  }
}
