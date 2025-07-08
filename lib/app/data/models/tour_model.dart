
class TourPackage {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final List<String>? imageUrls;

  TourPackage({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
  });

  factory TourPackage.fromJson(String id, Map<String, dynamic> json) {
    return TourPackage(
      id: id,
      title: json['title'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
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
