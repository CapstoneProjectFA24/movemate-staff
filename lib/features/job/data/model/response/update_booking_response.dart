import 'dart:convert';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

class UpdateBookingResponse {
  final int statusCode;
  final String message;
  final bool isError;
  final BookingResponseEntity payload;
  final dynamic metaData;
  final List<dynamic> errors;

  UpdateBookingResponse({
    required this.statusCode,
    required this.message,
    required this.isError,
    required this.payload,
    this.metaData,
    required this.errors,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'statusCode': statusCode});
    result.addAll({'message': message});
    result.addAll({'isError': isError});
    result.addAll({'payload': payload.toMap()});
    result.addAll({'metaData': metaData});
    result.addAll({'errors': errors});
    return result;
  }

  factory UpdateBookingResponse.fromMap(Map<String, dynamic> map) {
    return UpdateBookingResponse(
      statusCode: map['statusCode'] ?? 0,
      message: map['message'] ?? '',
      isError: map['isError'] ?? false,
      payload: BookingResponseEntity.fromMap(map['payload']),
      metaData: map['metaData'],
      errors: List<dynamic>.from(map['errors'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateBookingResponse.fromJson(String source) =>
      UpdateBookingResponse.fromMap(json.decode(source));
}
