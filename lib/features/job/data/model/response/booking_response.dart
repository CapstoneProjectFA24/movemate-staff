import 'dart:convert';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

class BookingResponse {
  final List<BookingResponseEntity> payload;

  BookingResponse({
    required this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'payload': payload.map((e) => e.toMap()).toList(),
    };
  }

  factory BookingResponse.fromMap(Map<String, dynamic> map) {
    return BookingResponse(
      payload: List<BookingResponseEntity>.from(
        (map['payload'] ?? []).map((x) => BookingResponseEntity.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingResponse.fromJson(String source) =>
      BookingResponse.fromMap(json.decode(source));
}
