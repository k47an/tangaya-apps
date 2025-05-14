class TourPackage {
  String? id;
  String? title;
  String? description;
  double? price;
  List<String>? imageUrls;
  // Tambahkan properti lain sesuai dengan struktur data Anda

  TourPackage({
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrls,
    // Inisialisasi properti lain di sini
  });

  // Method fromJson
  factory TourPackage.fromJson(String id, Map<String, dynamic> data) {
    return TourPackage(
      id: id,
      title: data['title'] as String?,
      description: data['description'] as String?,
      price: (data['price'] as num?)?.toDouble(),
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.cast<String>(),
      // Map properti lain dari data ke model di sini
    );
  }

  // Anda juga mungkin memerlukan method toJson untuk menyimpan data kembali ke Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      // Map properti model ke format data yang sesuai untuk Firestore
    };
  }
}