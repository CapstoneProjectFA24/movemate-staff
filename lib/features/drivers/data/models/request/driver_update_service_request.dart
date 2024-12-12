import 'dart:convert';

import 'package:movemate_staff/features/job/data/model/request/resource.dart';
import 'package:movemate_staff/features/job/data/model/request/service_detail.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_enities.dart';
import 'package:movemate_staff/features/job/domain/entities/image_data.dart';

class DriverUpdateServiceRequest {
  final int truckCategoryId;
  final List<ServiceDetail> bookingDetails;

  DriverUpdateServiceRequest({
    required this.truckCategoryId,
    required this.bookingDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'truckCategoryId': truckCategoryId,
      'bookingDetails': bookingDetails.map((x) => x.toMap()).toList(),
    };
  }

  factory DriverUpdateServiceRequest.fromMap(Map<String, dynamic> map) {
    return DriverUpdateServiceRequest(
      truckCategoryId: map['truckCategoryId'] ?? 0,
      bookingDetails: map['bookingDetails'] != null
          ? List<ServiceDetail>.from(
              map['bookingDetails']?.map((x) => ServiceDetail.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory DriverUpdateServiceRequest.fromJson(String source) =>
      DriverUpdateServiceRequest.fromMap(json.decode(source));

  // Phương thức xử lý để tạo BookingUpdateRequest từ một đối tượng Booking
  factory DriverUpdateServiceRequest.fromBookingUpdate(Booking booking) {
    // Khởi tạo danh sách bookingDetails
    List<ServiceDetail> bookingDetails = [];

    // Thêm selectedSubServices vào bookingDetails
    bookingDetails.addAll(booking.selectedSubServices.map((subService) {
      return ServiceDetail(
        serviceId: subService.id,
        quantity: subService.quantity ?? 1,
      );
    }).toList());

    final selectedVehicleOld = booking.selectedVehicleOld;
    if (selectedVehicleOld != null) {
      bookingDetails.add(
        ServiceDetail(
          serviceId: selectedVehicleOld.id,
          quantity: 0,
        ),
      );
    }
    final selectedVehicle = booking.selectedVehicle;
    if (selectedVehicle != null) {
      bookingDetails.add(
        ServiceDetail(
          serviceId: selectedVehicle.id,
          quantity: 1,
        ),
      );
    }
    String estimatedDeliveryTime = booking.estimatedDeliveryTime;

    // Thêm selectedPackages với số lượng vào bookingDetails
    bookingDetails.addAll(booking.selectedPackages
        .where((package) => package.quantity != null && package.quantity! > 0)
        .map((package) {
      return ServiceDetail(
        serviceId: package.id,
        quantity: package.quantity!,
      );
    }).toList());

    // Chuyển đổi thời gian đặt chỗ sang định dạng ISO8601
    String bookingAt = booking.bookingDate?.toIso8601String() ??
        DateTime.now().add(const Duration(days: 2)).toIso8601String();

    // Chuyển đổi hình ảnh thành Resource
    List<Resource> resourceList = [];

    void addImagesToResourceList(List<ImageData> images, String resourceCode) {
      resourceList.addAll(images.map((imageData) => Resource(
            type: 'IMG',
            resourceUrl: imageData.url,
            resourceCode: resourceCode,
          )));
    }

    addImagesToResourceList(booking.livingRoomImages ?? [], 'living_room');

    return DriverUpdateServiceRequest(
      truckCategoryId: booking.selectedVehicle?.truckCategory?.id ?? 0,
      bookingDetails: bookingDetails,
    );
  }
}
