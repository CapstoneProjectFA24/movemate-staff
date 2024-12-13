import 'dart:convert';

class AssignmentsResponseEntity {
  final int id;
  final int userId;
  final int bookingId;
  final String status;
  final double? price;
  final String staffType;
  final String? failedReason;
  final bool? isResponsible;

  AssignmentsResponseEntity({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.status,
    this.price,
    required this.staffType,
    this.isResponsible,
    this.failedReason,
  });

  factory AssignmentsResponseEntity.fromMap(Map<String, dynamic> json) {
    return AssignmentsResponseEntity(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      status: json['status'] ?? '',
      price: json['price'] != null
          ? (json['price'] is double
              ? json['price']
              : (json['price'] is int
                  ? (json['price'] as int).toDouble()
                  : null))
          : null,
      staffType: json['staffType'] ?? '',
      failedReason: json['failedReason'] ?? '',
      isResponsible: json['isResponsible'] != null
          ? (json['isResponsible'] is bool
              ? json['isResponsible']
              : (json['isResponsible'] is int
                  ? json['isResponsible'] == 0
                  : null))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookingId': bookingId,
      'status': status,
      'price': price,
      'staffType': staffType,
      'failedReason': failedReason,
      'isResponsible': isResponsible,
    };
  }

  String toJson() => json.encode(toMap());

  factory AssignmentsResponseEntity.fromJson(String source) =>
      AssignmentsResponseEntity.fromMap(json.decode(source));
}
