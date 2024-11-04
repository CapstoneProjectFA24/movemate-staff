import 'dart:convert';

import 'package:movemate_staff/utils/enums/booking_status_type.dart';

class ReviewerStatusRequest {
 final BookingStatusType? status;
  final double? estimatedDeliveryTime;
  

  ReviewerStatusRequest({
     this.status,
    this.estimatedDeliveryTime,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (status != null) {
      map['status'] = status!.type;
    }
    map['estimatedDeliveryTime'] = estimatedDeliveryTime;
    return map;
  }

  factory ReviewerStatusRequest.fromMap(Map<String, dynamic> map) {
    return ReviewerStatusRequest(
      status:  map['status'] != null ?(map['status'] as String).toBookingTypeEnum(): null,
      estimatedDeliveryTime: map['estimatedDeliveryTime'] ?? null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewerStatusRequest.fromJson(String source) =>
      ReviewerStatusRequest.fromMap(json.decode(source));
}
