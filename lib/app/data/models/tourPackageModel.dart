class TourPackage {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;

  TourPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
  });

  // Mengonversi dokumen Firestore menjadi objek TourPackage
  factory TourPackage.fromDocument(Map<String, dynamic> doc, String id) {
    return TourPackage(
      id: id,
      title: doc['title'],
      description: doc['description'],
      price: doc['price'],
      imageUrls: List<String>.from(doc['imageUrls'] ?? []),
    );
  }

  // Mengonversi objek TourPackage menjadi Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
    };
  }
}
