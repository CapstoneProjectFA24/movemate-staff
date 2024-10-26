import 'dart:convert';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

class BookingResponse {
  final int statusCode;
  final String message;
  final bool isError;
  final List<BookingResponseEntity> payload;
  final dynamic metaData;
  final List<dynamic> errors;

  BookingResponse({
    required this.statusCode,
    required this.message,
    required this.isError,
    required this.payload,
    this.metaData,
    required this.errors,
  });

  Map<String, dynamic> toMap() {
    return {
      'statusCode': statusCode,
      'message': message,
      'isError': isError,
      'payload': payload.map((e) => e.toMap()).toList(),
      'metaData': metaData,
      'errors': errors,
    };
  }

  factory BookingResponse.fromMap(Map<String, dynamic> map) {
    return BookingResponse(
      statusCode: map['statusCode'] ?? 0,
      message: map['message'] ?? '',
      isError: map['isError'] ?? false,
      payload: List<BookingResponseEntity>.from(
        (map['payload'] ?? []).map((x) => BookingResponseEntity.fromMap(x)),
      ),
      metaData: map['metaData'],
      errors: List<dynamic>.from(map['errors'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingResponse.fromJson(String source) => BookingResponse.fromMap(json.decode(source));
}
