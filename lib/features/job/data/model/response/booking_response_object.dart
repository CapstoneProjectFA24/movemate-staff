import 'dart:convert';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

class BookingResponseObject {
  final BookingResponseEntity payload;

  BookingResponseObject({
    required this.payload,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'payload': payload.toMap()});
    return result;
  }

  factory BookingResponseObject.fromMap(Map<String, dynamic> map) {
    return BookingResponseObject(
      payload: BookingResponseEntity.fromMap(map['payload'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingResponseObject.fromJson(String source) =>
      BookingResponseObject.fromMap(json.decode(source));
}
