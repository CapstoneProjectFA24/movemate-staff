import 'dart:convert';

import 'package:movemate_staff/features/job/data/model/request/resource.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_enities.dart';
import 'package:movemate_staff/features/job/domain/entities/image_data.dart';
import 'package:movemate_staff/utils/enums/booking_status_type.dart';

class ReviewerStatusRequest {
  final BookingStatusType? status;
  final double? estimatedDeliveryTime;
  final List<Resource>? resourceList;

  ReviewerStatusRequest({
    this.status,
    this.estimatedDeliveryTime,
    this.resourceList = const [],
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (status != null) {
      map['status'] = status!.type;
    }
    map['estimatedDeliveryTime'] = estimatedDeliveryTime;
    if (status != null) {
      map['resourceList'] = resourceList?.map((e) => e.toMap()).toList();
    }
    return map;
  }

  void addImagesToResourceList(List<ImageData> images, String resourceCode) {
    resourceList?.addAll(images.map((imageData) => Resource(
          type: 'IMG',
          resourceUrl: imageData.url,
          resourceCode: resourceCode,
        )));
  }

  factory ReviewerStatusRequest.fromMap(Map<String, dynamic> map) {
    return ReviewerStatusRequest(
      status: map['status'] != null
          ? (map['status'] as String).toBookingTypeEnum()
          : null,
      estimatedDeliveryTime: map['estimatedDeliveryTime'],
      resourceList: List<Resource>.from(
          map['resourceList']?.map((x) => Resource.fromMap(x)) ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ReviewerStatusRequest(status: $status, estimatedDeliveryTime: $estimatedDeliveryTime, resourceList: $resourceList)';
  factory ReviewerStatusRequest.fromJson(String source) =>
      ReviewerStatusRequest.fromMap(json.decode(source));
}
