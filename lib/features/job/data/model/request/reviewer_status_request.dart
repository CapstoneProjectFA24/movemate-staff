import 'dart:convert';

import 'package:movemate_staff/utils/enums/booking_status_type.dart';

class ReviewerStatusRequest {
  final BookingStatusType status;

  ReviewerStatusRequest({
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status.type,
    };
  }

  factory ReviewerStatusRequest.fromMap(Map<String, dynamic> map) {
    return ReviewerStatusRequest(
      status: (map['status'] as String).toBookingTypeEnum(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewerStatusRequest.fromJson(String source) =>
      ReviewerStatusRequest.fromMap(json.decode(source));
}
