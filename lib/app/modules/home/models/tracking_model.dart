class TrackingModel {
  String id;
  String name;
  String description;
  List<String> images; // List untuk menampung banyak gambar
  int price;

  TrackingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.price,
  });

  // Factory method untuk membuat objek dari Map (Firestore)
  factory TrackingModel.fromMap(String id, Map<String, dynamic> data) {
    List<String> imageList = [];
    if (data['image'] != null) {
      Map<String, dynamic> imageMap = data['image'];
      imageList = imageMap.values.map((e) => e.toString()).toList();
    }

    return TrackingModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      images: imageList,
      price: data['price'] ?? 0,
    );
  }

  // Konversi objek menjadi Map untuk penyimpanan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': {
        for (var i = 0; i < images.length; i++) 'img${i + 1}': images[i],
      },
      'price': price,
    };
  }
}
