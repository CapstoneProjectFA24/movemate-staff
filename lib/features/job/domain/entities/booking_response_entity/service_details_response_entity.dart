class ServiceDetailsResponseEntity {
  final int id;
  final int serviceId;
  final int bookingId;
  final int quantity;
  final double? price; // Đã chuyển từ String? sang double?
  final String? isQuantity;
  final String? description;

  ServiceDetailsResponseEntity({
    required this.id,
    required this.serviceId,
    required this.bookingId,
    required this.quantity,
    this.price, // Cập nhật kiểu dữ liệu
    this.isQuantity,
    this.description,
  });

  factory ServiceDetailsResponseEntity.fromMap(Map<String, dynamic> json) {
    return ServiceDetailsResponseEntity(
      id: json['id'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      // price: (json['price'] as num ).toDouble(),
      price: json['price'] != null
          ? (json['price'] is double
              ? json['price']
              : (json['price'] is int
                  ? (json['price'] as int).toDouble()
                  : null))
          : null,
      isQuantity: json['isQuantity']?.toString(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'bookingId': bookingId,
      'quantity': quantity,
      'price': price, // Giữ kiểu double
      'isQuantity': isQuantity,
      'description': description,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
