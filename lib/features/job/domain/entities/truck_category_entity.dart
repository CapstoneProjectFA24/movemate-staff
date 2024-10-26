import 'dart:convert';

class TruckCategoryEntity {
  final int id;
  final String categoryName;
  final int maxLoad;
  final String description;
  final String imgUrl;
  final String estimatedLength;
  final String estimatedWidth;
  final String estimatedHeight;
  final int price;
  final int totalTrips;

  TruckCategoryEntity({
    required this.id,
    required this.categoryName,
    required this.maxLoad,
    required this.description,
    required this.imgUrl,
    required this.estimatedLength,
    required this.estimatedWidth,
    required this.estimatedHeight,
    required this.price,
    required this.totalTrips,
  });

  factory TruckCategoryEntity.fromMap(Map<String, dynamic> map) {
    return TruckCategoryEntity(
      id: map['id'] ?? 0,
      categoryName: map['categoryName'] ?? '',
      maxLoad: map['maxLoad'] ?? 0,
      description: map['description'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
      estimatedLength: map['estimatedLength'] ?? '',
      estimatedWidth: map['estimatedWidth'] ?? '',
      estimatedHeight: map['estimatedHeight'] ?? '',
      price: map['price'] ?? 0,
      totalTrips: map['totalTrips'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryName': categoryName,
      'maxLoad': maxLoad,
      'description': description,
      'imgUrl': imgUrl,
      'estimatedLength': estimatedLength,
      'estimatedWidth': estimatedWidth,
      'estimatedHeight': estimatedHeight,
      'price': price,
      'totalTrips': totalTrips,
    };
  }

  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'TruckCategoryEntity(id: $id, categoryName: $categoryName, maxLoad: $maxLoad, description: $description, imgUrl: $imgUrl, estimatedLength: $estimatedLength, estimatedWidth: $estimatedWidth, estimatedHeight: $estimatedHeight, price: $price, totalTrips: $totalTrips)';
  }

  factory TruckCategoryEntity.fromJson(String source) =>
      TruckCategoryEntity.fromMap(json.decode(source));
}
