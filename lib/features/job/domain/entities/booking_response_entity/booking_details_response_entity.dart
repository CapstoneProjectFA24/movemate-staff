class BookingDetailsResponseEntity {
  final int id;
  final int serviceId;
  final int bookingId;
  final int quantity;
  final double? price; // Đã chuyển từ String? sang double?
  final String? status;
  final String? type;
  final String? isQuantity;
  final String? name;
  final String? description;

  BookingDetailsResponseEntity({
    required this.id,
    required this.serviceId,
    required this.bookingId,
    required this.quantity,
    this.status,
    this.type,
    this.price, // Cập nhật kiểu dữ liệu
    this.isQuantity,
    this.name,
    this.description,
  });

  factory BookingDetailsResponseEntity.fromMap(Map<String, dynamic> json) {
    return BookingDetailsResponseEntity(
      id: json['id'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      // price:
      //     (json['price'] as num).toDouble(), // Sử dụng hàm hỗ trợ để chuyển đổi
      price: json['price'] != null
          ? (json['price'] is double
              ? json['price']
              : (json['price'] is int
                  ? (json['price'] as int).toDouble()
                  : null))
          : null,
      isQuantity: json['isQuantity']?.toString(),
      name: json['name']?.toString(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'bookingId': bookingId,
      'quantity': quantity,
      'status': status,
      'type': type,
      'price': price, // Giữ kiểu double
      'isQuantity': isQuantity,
      'name': name,
      'description': description,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  /// Hàm hỗ trợ chuyển đổi giá trị sang double?
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
