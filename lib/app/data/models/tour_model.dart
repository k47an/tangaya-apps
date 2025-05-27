class TourPackage {
  String? id;
  String? title;
  String? description;
  double? price;
  List<String>? imageUrls;

  TourPackage({
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrls,
  });

  factory TourPackage.fromJson(String id, Map<String, dynamic> data) {
    return TourPackage(
      id: id,
      title: data['title'] as String?,
      description: data['description'] as String?,
      price: (data['price'] as num?)?.toDouble(),
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
    };
  }
}