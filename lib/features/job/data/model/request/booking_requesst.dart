// format code ở đây để request
// //

// POST /api/v1/bookings/register-booking
// {
//   "pickupAddress": "string",
//   "pickupPoint": "string",
//   "deliveryAddress": "string",
//   "deliveryPoint": "string",
//   "estimatedDistance": "3",
//   "houseTypeId": 1,
//   "note": "string",
//   "estimatedDeliveryTime": "3",
//   "isRoundTrip": true,
//   "isManyItems": true,
//   "roomNumber": "1",
//   "floorsNumber": "2",
//   "serviceDetails": [
//     {
//       "id": 1,
//       "isQuantity": true,
//       "quantity": 1
//     }
//   ],
//   "truckCategoryId": 1,
//   "bookingAt": "2024-09-27T04:05:29.705Z",
//   "resourceList": [
//     {
//       "type": "IMG",
//       "resourceUrl": "https://hoanghamobile.com/tin-tuc/wp-content/webp-express/webp-images/uploads/2024/03/anh-meme-hai.jpg.webp",
//       "resourceCode": "string"
//     }
//   ]
// }

import 'dart:convert';
import 'package:movemate_staff/features/job/data/model/request/resource.dart';
import 'package:movemate_staff/features/job/data/model/request/service_detail.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_enities.dart';
import 'package:movemate_staff/features/job/domain/entities/image_data.dart';

class BookingRequest {
  final String pickupAddress;
  final String pickupPoint;
  final String deliveryAddress;
  final String deliveryPoint;
  final String estimatedDistance;
  final int houseTypeId;
  final String note;
  final String estimatedDeliveryTime;
  final bool isReviewOnline;
  final bool isRoundTrip;
  final bool isManyItems;
  final String roomNumber;
  final String floorsNumber;
  final List<ServiceDetail> serviceDetails;
  final int truckCategoryId;
  final String bookingAt;
  final List<Resource> resourceList;

  BookingRequest({
    required this.pickupAddress,
    required this.pickupPoint,
    required this.deliveryAddress,
    required this.deliveryPoint,
    required this.estimatedDistance,
    required this.houseTypeId,
    required this.isReviewOnline,
    required this.note,
    required this.estimatedDeliveryTime,
    required this.isRoundTrip,
    required this.isManyItems,
    required this.roomNumber,
    required this.floorsNumber,
    required this.serviceDetails,
    required this.truckCategoryId,
    required this.bookingAt,
    required this.resourceList,
  });

  Map<String, dynamic> toMap() {
    return {
      'pickupAddress': pickupAddress,
      'pickupPoint': pickupPoint,
      'deliveryAddress': deliveryAddress,
      'deliveryPoint': deliveryPoint,
      'estimatedDistance': estimatedDistance,
      'houseTypeId': houseTypeId,
      'note': note,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'isRoundTrip': isRoundTrip,
      'isReviewOnline': isReviewOnline,
      'isManyItems': isManyItems,
      'roomNumber': roomNumber,
      'floorsNumber': floorsNumber,
      'serviceDetails': serviceDetails.map((x) => x.toMap()).toList(),
      'truckCategoryId': truckCategoryId,
      'bookingAt': bookingAt,
      'resourceList': resourceList.map((x) => x.toMap()).toList(),
    };
  }

  factory BookingRequest.fromMap(Map<String, dynamic> map) {
    return BookingRequest(
      pickupAddress: map['pickupAddress'] ?? '',
      pickupPoint: map['pickupPoint'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      deliveryPoint: map['deliveryPoint'] ?? '',
      estimatedDistance: map['estimatedDistance'] ?? '0',
      houseTypeId: map['houseTypeId'] ?? 1,
      note: map['note'] ?? '',
      estimatedDeliveryTime: map['estimatedDeliveryTime'] ?? '0',
      isRoundTrip: map['isRoundTrip'] ?? false,
      isReviewOnline: map['isReviewOnline'] ?? false,
      isManyItems: map['isManyItems'] ?? false,
      roomNumber: map['roomNumber'] ?? '0',
      floorsNumber: map['floorsNumber'] ?? '0',
      serviceDetails: map['serviceDetails'] != null
          ? List<ServiceDetail>.from(
              map['serviceDetails']?.map((x) => ServiceDetail.fromMap(x)))
          : [],
      truckCategoryId: map['truckCategoryId'] ?? 1,
      bookingAt: map['bookingAt'] ?? '',
      resourceList: map['resourceList'] != null
          ? List<Resource>.from(
              map['resourceList']?.map((x) => Resource.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingRequest.fromJson(String source) =>
      BookingRequest.fromMap(json.decode(source));

  // Phương thức xử lý để tạo BookingRequest từ một đối tượng Booking
  factory BookingRequest.fromBooking(Booking booking) {
    // Khởi tạo danh sách serviceDetails
    List<ServiceDetail> serviceDetails = [];

    // Thêm selectedSubServices vào serviceDetails

    serviceDetails.addAll(booking.selectedSubServices.map((subService) {
      return ServiceDetail(
        serviceId: subService.id,
        // isQuantity: subService.isQuantity, // Sử dụng subService.isQuantity
        quantity: subService.quantity ?? 1,
      );
    }).toList());

    // Filter servicesFeeList to include only fees with quantity > 0
    List<ServiceDetail> feeServiceDetails = booking.servicesFeeList
        .where((serviceFee) =>
            serviceFee.quantity != null && serviceFee.quantity! > 0)
        .map((serviceFee) {
      return ServiceDetail(
        serviceId: serviceFee.id,
        // isQuantity: true,
        quantity: serviceFee.quantity!,
      );
    }).toList();

    // Add filtered fees to serviceDetails
    serviceDetails.addAll(feeServiceDetails);

    // Add selectedPackages with quantities to serviceDetails
    serviceDetails.addAll(booking.selectedPackages
        .where((package) => package.quantity != null && package.quantity! > 0)
        .map((package) {
      return ServiceDetail(
        serviceId: package.id,
        // isQuantity:
        //     true, // Assuming that packages with quantities are isQuantity == true
        quantity: package.quantity!,
      );
    }).toList());

    // Chuyển đổi hình ảnh thành Resource
    List<Resource> resourceList = [];

    void addImagesToResourceList(List<ImageData> images, String resourceCode) {
      resourceList.addAll(images.map((imageData) => Resource(
            type: 'IMG',
            resourceUrl: imageData.url,
            resourceCode: resourceCode,
          )));
    }

    addImagesToResourceList(booking.livingRoomImages, 'living_room');
    addImagesToResourceList(booking.bedroomImages, 'bedroom');
    addImagesToResourceList(booking.diningRoomImages, 'dining_room');
    addImagesToResourceList(booking.officeRoomImages, 'office_room');
    addImagesToResourceList(booking.bathroomImages, 'bathroom');

    // Tính toán khoảng cách ước tính (ví dụ)
    String estimatedDistance = '3'; // Có thể tính toán dựa trên tọa độ

    // Tính toán thời gian giao hàng ước tính (ví dụ)
    String estimatedDeliveryTime =
        '3'; // Có thể tính toán hoặc đặt giá trị phù hợp

    // Chuyển đổi thời gian đặt chỗ sang định dạng ISO8601
    String bookingAt = booking.bookingDate?.toIso8601String() ??
        DateTime.now().toIso8601String();

    return BookingRequest(
      pickupAddress: booking.pickUpLocation?.address ?? '',
      pickupPoint: booking.pickUpLocation != null
          ? '${booking.pickUpLocation!.latitude},${booking.pickUpLocation!.longitude}'
          : '',
      deliveryAddress: booking.dropOffLocation?.address ?? 'string',
      deliveryPoint: booking.dropOffLocation != null
          ? '${booking.dropOffLocation!.latitude},${booking.dropOffLocation!.longitude}'
          : '',
      estimatedDistance: estimatedDistance,
      houseTypeId: booking.houseType?.id ?? 1,
      note: booking.notes,
      estimatedDeliveryTime: estimatedDeliveryTime,
      isRoundTrip: booking.isRoundTrip,
      isReviewOnline: booking.isReviewOnline,
      isManyItems: booking.selectedSubServices.isNotEmpty,
      roomNumber: (booking.numberOfRooms ?? 1).toString(),
      floorsNumber: (booking.numberOfFloors ?? 1).toString(),
      serviceDetails: serviceDetails,
      truckCategoryId: booking.selectedVehicle?.id ?? 1,
      bookingAt: bookingAt,
      resourceList: resourceList,
    );
  }
}
// PUT apidata
// {
//   "truckCategoryId": 0,
//   "houseTypeId": 0,
//   "pickupAddress": "string",
//   "pickupPoint": "string",
//   "deliveryAddress": "string",
//   "deliveryPoint": "string",
//   "estimatedDistance": "string",
//   "isRoundTrip": true,
//   "typeBooking": "string",
//   "roomNumber": "string",
//   "floorsNumber": "string",
//   "note": "string",
//   "bookingAt": "2024-10-28T20:00:25.775Z",
//   "bookingDetails": [
//     {
//       "serviceId": 0,
//       "quantity": 0
//     }
//   ]
// }

class BookingUpdateRequest {
  final int truckCategoryId;
  final int houseTypeId;
  final String pickupAddress;
  final String pickupPoint;
  final String deliveryAddress;
  final String deliveryPoint;
  final String estimatedDistance;
  final bool isRoundTrip;
  final String typeBooking;
  final String roomNumber;
  final String floorsNumber;
  final String note;
  final String bookingAt;
  final List<ServiceDetail> bookingDetails;

  BookingUpdateRequest({
    required this.truckCategoryId,
    required this.houseTypeId,
    required this.pickupAddress,
    required this.pickupPoint,
    required this.deliveryAddress,
    required this.deliveryPoint,
    required this.estimatedDistance,
    required this.isRoundTrip,
    required this.typeBooking,
    required this.roomNumber,
    required this.floorsNumber,
    required this.note,
    required this.bookingAt,
    required this.bookingDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'truckCategoryId': truckCategoryId,
      'houseTypeId': houseTypeId,
      'pickupAddress': pickupAddress,
      'pickupPoint': pickupPoint,
      'deliveryAddress': deliveryAddress,
      'deliveryPoint': deliveryPoint,
      'estimatedDistance': estimatedDistance,
      'isRoundTrip': isRoundTrip,
      'typeBooking': typeBooking,
      'roomNumber': roomNumber,
      'floorsNumber': floorsNumber,
      'note': note,
      'bookingAt': bookingAt,
      'bookingDetails': bookingDetails.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  factory BookingUpdateRequest.fromJson(String source) =>
      BookingUpdateRequest.fromMap(json.decode(source));

  factory BookingUpdateRequest.fromMap(Map<String, dynamic> map) {
    return BookingUpdateRequest(
      truckCategoryId: map['truckCategoryId'] ?? 0,
      houseTypeId: map['houseTypeId'] ?? 1,
      pickupAddress: map['pickupAddress'] ?? '',
      pickupPoint: map['pickupPoint'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      deliveryPoint: map['deliveryPoint'] ?? '',
      estimatedDistance: map['estimatedDistance'] ?? '0',
      isRoundTrip: map['isRoundTrip'] ?? false,
      typeBooking: map['typeBooking'] ?? '',
      roomNumber: map['roomNumber'] ?? 1,
      floorsNumber: map['floorsNumber'] ?? 1,
      note: map['note'] ?? '',
      bookingAt: map['bookingAt'] ?? '',
      bookingDetails: map['bookingDetails'] != null
          ? List<ServiceDetail>.from(
              map['bookingDetails']?.map((x) => ServiceDetail.fromMap(x)))
          : [],
    );
  }

  // Phương thức xử lý để tạo BookingUpdateRequest từ một đối tượng Booking
  factory BookingUpdateRequest.fromBookingUpdate(Booking booking) {
    // Khởi tạo danh sách bookingDetails
    List<ServiceDetail> bookingDetails = [];

    // Thêm selectedSubServices vào bookingDetails
    bookingDetails.addAll(booking.selectedSubServices.map((subService) {
      return ServiceDetail(
        serviceId: subService.id,
        quantity: subService.quantity ?? 1,
      );
    }).toList());

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
        DateTime.now().add(Duration(days: 2)).toIso8601String();

    return BookingUpdateRequest(
      truckCategoryId: booking.selectedVehicle?.id ?? 0,
      houseTypeId: booking.houseType?.id ?? 1,
      pickupAddress: booking.pickUpLocation?.address ?? '',
      pickupPoint: booking.pickUpLocation != null
          ? '${booking.pickUpLocation!.latitude},${booking.pickUpLocation!.longitude}'
          : '',
      deliveryAddress: booking.dropOffLocation?.address ?? '',
      deliveryPoint: booking.dropOffLocation != null
          ? '${booking.dropOffLocation!.latitude},${booking.dropOffLocation!.longitude}'
          : '',
      estimatedDistance: '3', // Có thể tính toán dựa trên tọa độ
      isRoundTrip: booking.isRoundTrip,
      typeBooking: 'string', // Thiết lập typeBooking theo nhu cầu
      roomNumber: (booking.numberOfRooms ?? 1).toString(),
      floorsNumber: (booking.numberOfFloors ?? 1).toString(),
      note: booking.notes ?? '',
      bookingAt: bookingAt,
      bookingDetails: bookingDetails,
    );
  }
}
