import 'dart:convert';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

class BookingResponseObject {
  final int statusCode;
  final String message;
  final bool isError;
  final BookingResponseEntity payload;
  final dynamic metaData;
  final List<dynamic> errors;

  BookingResponseObject({
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
      'payload': payload.toMap(),
      'metaData': metaData,
      'errors': errors,
    };
  }

  factory BookingResponseObject.fromMap(Map<String, dynamic> map) {
    return BookingResponseObject(
      statusCode: map['statusCode'] ?? 0,
      message: map['message'] ?? '',
      isError: map['isError'] ?? false,
      payload: BookingResponseEntity.fromMap(map['payload'] ?? {}),
      metaData: map['metaData'],
      errors: List<dynamic>.from(map['errors'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingResponseObject.fromJson(String source) =>
      BookingResponseObject.fromMap(json.decode(source));
}
