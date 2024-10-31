class BookingDetailsResponseEntity {
  final int id;
  final int serviceId;
  final int bookingId;
  final int quantity;
  final String? price;
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
    this.price,
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
      price: json['price']?.toString(),
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
      'price': price,
      'isQuantity': isQuantity,
      'name': name,
      'description': description,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
