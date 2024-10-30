import 'dart:convert';

import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_details_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_trackers_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/fee_details_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/service_details_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/house_type_entity.dart';
import 'package:movemate_staff/utils/enums/booking_status_type.dart';

class BookingResponseEntity {
  final int id;
  final int userId;
  final int houseTypeId;
  final HouseTypeEntity? houseType;
  final double deposit;
  final String status;
  final String pickupAddress;
  final String pickupPoint;
  final String deliveryAddress;
  final String deliveryPoint;
  final bool isUseBox;
  final String? boxType;
  final String estimatedDistance;
  final double total;
  final double totalReal;
  final String? estimatedDeliveryTime;
  final bool isDeposited;
  final bool isBonus;
  final bool isReported;
  final String? reportedReason;
  final bool isDeleted;
  final String createdAt;
  final String? createdBy;
  final String updatedAt;
  final String? updatedBy;
  final String? review;
  final String? bonus;
  final String typeBooking;
  final String? estimatedAcreage;
  final String roomNumber;
  final String floorsNumber;
  final bool isManyItems;
  final bool isCancel;
  final String? cancelReason;
  final bool isPorter;
  final bool isRoundTrip;
  final String note;
  final double totalFee;
  final String? feeInfo;
  final bool isReviewOnline;
  final String bookingAt; // Thêm trường bookingAt
  final String? reviewAt; // Thêm trường reviewAt
  final List<BookingDetailsResponseEntity> bookingDetails;
  final List<BookingTrackersResponseEntity> bookingTrackers;
  final List<ServiceDetailsResponseEntity> serviceDetails;
  final List<FeeDetailsResponseEntity> feeDetails;
  final List<AssignmentsResponseEntity> assignments; // Thêm trường này
  

  BookingResponseEntity({
    this.houseType,
    required this.id,
    required this.userId,
    required this.houseTypeId,
    required this.deposit,
    required this.status,
    required this.pickupAddress,
    required this.pickupPoint,
    required this.deliveryAddress,
    required this.deliveryPoint,
    required this.isUseBox,
    this.boxType,
    required this.estimatedDistance,
    required this.total,
    required this.totalReal,
    this.estimatedDeliveryTime,
    required this.isDeposited,
    required this.isBonus,
    required this.isReported,
    this.reportedReason,
    required this.isDeleted,
    required this.createdAt,
    this.createdBy,
    required this.updatedAt,
    this.updatedBy,
    this.review,
    this.bonus,
    required this.typeBooking,
    this.estimatedAcreage,
    required this.roomNumber,
    required this.floorsNumber,
    required this.isManyItems,
    required this.isCancel,
    this.cancelReason,
    required this.isPorter,
    required this.isRoundTrip,
    required this.note,
    required this.totalFee,
    this.feeInfo,
    required this.isReviewOnline,
    required this.bookingAt, // Thêm vào constructor
    this.reviewAt, // Thêm vào constructor
    required this.bookingDetails,
    required this.bookingTrackers,
    required this.serviceDetails,
    required this.feeDetails,
    required this.assignments,
  });

  factory BookingResponseEntity.fromMap(Map<String, dynamic> json) {
    return BookingResponseEntity(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      houseTypeId: json['houseTypeId'] ?? 0,
      // deposit: json['deposit'] ?? 0,
      deposit: (json['deposit'] is double)
          ? json['deposit']
          : (json['deposit'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      pickupAddress: json['pickupAddress'] ?? '',
      pickupPoint: json['pickupPoint'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      deliveryPoint: json['deliveryPoint'] ?? '',
      isUseBox: json['isUseBox'] ?? false,
      boxType: json['boxType'],
      estimatedDistance: json['estimatedDistance'] ?? '',
      // total: json['total'] ?? 0,
      // totalReal: json['totalReal'] ?? 0,
      total: (json['total'] is double)
          ? json['total']
          : (json['total'] ?? 0).toDouble(),
      totalReal: (json['totalReal'] is double)
          ? json['totalReal']
          : (json['totalReal'] ?? 0).toDouble(),

      estimatedDeliveryTime: json['estimatedDeliveryTime'],
      isDeposited: json['isDeposited'] ?? false,
      isBonus: json['isBonus'] ?? false,
      isReported: json['isReported'] ?? false,
      reportedReason: json['reportedReason'],
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      createdBy: json['createdBy'],
      updatedAt: json['updatedAt'] ?? '',
      updatedBy: json['updatedBy'],
      review: json['review'],
      bonus: json['bonus'],
      typeBooking: json['typeBooking'] ?? '',
      estimatedAcreage: json['estimatedAcreage'],
      roomNumber: json['roomNumber'] ?? '',
      floorsNumber: json['floorsNumber'] ?? '',
      isManyItems: json['isManyItems'] ?? false,
      isCancel: json['isCancel'] ?? false,
      cancelReason: json['cancelReason'],
      isPorter: json['isPorter'] ?? false,
      isRoundTrip: json['isRoundTrip'] ?? false,
      note: json['note'] ?? '',
      // totalFee: json['totalFee'] ?? 0,
      totalFee: (json['totalFee'] is double)
          ? json['totalFee']
          : (json['totalFee'] ?? 0).toDouble(),
      feeInfo: json['feeInfo'],
      isReviewOnline: json['isReviewOnline'] ?? false,
      bookingAt: json['bookingAt'] ?? '', // Thêm vào fromMap
      reviewAt: json['reviewAt'],
      bookingDetails: (json['bookingDetails'] as List<dynamic>?)
              ?.map((e) => BookingDetailsResponseEntity.fromMap(e))
              .toList() ??
          [],
      bookingTrackers: (json['bookingTrackers'] as List<dynamic>?)
              ?.map((e) => BookingTrackersResponseEntity.fromMap(e))
              .toList() ??
          [],
      serviceDetails: (json['serviceDetails'] as List<dynamic>?)
              ?.map((e) => ServiceDetailsResponseEntity.fromMap(e))
              .toList() ??
          [],
      feeDetails: (json['feeDetails'] as List<dynamic>?)
              ?.map((e) => FeeDetailsResponseEntity.fromMap(e))
              .toList() ??
          [],
      assignments: (json['assignments'] as List<dynamic>?)
              ?.map((e) => AssignmentsResponseEntity.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'houseTypeId': houseTypeId,
      'deposit': deposit,
      'status': status,
      'pickupAddress': pickupAddress,
      'pickupPoint': pickupPoint,
      'deliveryAddress': deliveryAddress,
      'deliveryPoint': deliveryPoint,
      'isUseBox': isUseBox,
      'boxType': boxType,
      'estimatedDistance': estimatedDistance,
      'total': total,
      'totalReal': totalReal,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'isDeposited': isDeposited,
      'isBonus': isBonus,
      'isReported': isReported,
      'reportedReason': reportedReason,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
      'review': review,
      'bonus': bonus,
      'typeBooking': typeBooking,
      'estimatedAcreage': estimatedAcreage,
      'roomNumber': roomNumber,
      'floorsNumber': floorsNumber,
      'isManyItems': isManyItems,
      'isCancel': isCancel,
      'cancelReason': cancelReason,
      'isPorter': isPorter,
      'isRoundTrip': isRoundTrip,
      'note': note,
      'totalFee': totalFee,
      'feeInfo': feeInfo,
      'isReviewOnline': isReviewOnline,
      'bookingAt': bookingAt, // Thêm vào toMap
      'reviewAt': reviewAt, // Thêm vào toMap
      'bookingDetails': bookingDetails.map((e) => e.toMap()).toList(),
      'bookingTrackers': bookingTrackers.map((e) => e.toMap()).toList(),
      'serviceDetails': serviceDetails.map((e) => e.toMap()).toList(),
      'feeDetails': feeDetails.map((e) => e.toMap()).toList(),
      'assignments': assignments.map((e) => e.toMap()).toList(),
    };
  }

  BookingResponseEntity copyWith({
    int? id,
    int? userId,
    int? houseTypeId,
    HouseTypeEntity? houseType,
    double? deposit,
    String? status,
    String? pickupAddress,
    String? pickupPoint,
    String? deliveryAddress,
    String? deliveryPoint,
    bool? isUseBox,
    String? boxType,
    String? estimatedDistance,
    double? total,
    double? totalReal,
    String? estimatedDeliveryTime,
    bool? isDeposited,
    bool? isBonus,
    bool? isReported,
    String? reportedReason,
    bool? isDeleted,
    String? createdAt,
    String? createdBy,
    String? updatedAt,
    String? updatedBy,
    String? review,
    String? bonus,
    String? typeBooking,
    String? estimatedAcreage,
    String? roomNumber,
    String? floorsNumber,
    bool? isManyItems,
    bool? isCancel,
    String? cancelReason,
    bool? isPorter,
    bool? isRoundTrip,
    String? note,
    double? totalFee,
    String? feeInfo,
    bool? isReviewOnline,
    String? bookingAt, // Thêm vào copyWith
    String? reviewAt, // Thêm vào copyWith
    List<BookingDetailsResponseEntity>? bookingDetails,
    List<BookingTrackersResponseEntity>? bookingTrackers,
    List<ServiceDetailsResponseEntity>? serviceDetails,
    List<FeeDetailsResponseEntity>? feeDetails,
    List<AssignmentsResponseEntity>? assignments,
  }) {
    return BookingResponseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      houseTypeId: houseTypeId ?? this.houseTypeId,
      houseType: houseType ?? this.houseType,
      deposit: deposit ?? this.deposit,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryPoint: deliveryPoint ?? this.deliveryPoint,
      isUseBox: isUseBox ?? this.isUseBox,
      boxType: boxType ?? this.boxType,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      total: total ?? this.total,
      totalReal: totalReal ?? this.totalReal,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      isDeposited: isDeposited ?? this.isDeposited,
      isBonus: isBonus ?? this.isBonus,
      isReported: isReported ?? this.isReported,
      reportedReason: reportedReason ?? this.reportedReason,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      review: review ?? this.review,
      bonus: bonus ?? this.bonus,
      typeBooking: typeBooking ?? this.typeBooking,
      estimatedAcreage: estimatedAcreage ?? this.estimatedAcreage,
      roomNumber: roomNumber ?? this.roomNumber,
      floorsNumber: floorsNumber ?? this.floorsNumber,
      isManyItems: isManyItems ?? this.isManyItems,
      isCancel: isCancel ?? this.isCancel,
      cancelReason: cancelReason ?? this.cancelReason,
      isPorter: isPorter ?? this.isPorter,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      note: note ?? this.note,
      totalFee: totalFee ?? this.totalFee,
      feeInfo: feeInfo ?? this.feeInfo,
      isReviewOnline: isReviewOnline ?? this.isReviewOnline,
      bookingAt: bookingAt ?? this.bookingAt, // Thêm vào copyWith
      reviewAt: reviewAt ?? this.reviewAt, // Thêm vào copyWith
      bookingDetails: bookingDetails ?? this.bookingDetails,
      bookingTrackers: bookingTrackers ?? this.bookingTrackers,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      feeDetails: feeDetails ?? this.feeDetails,
      assignments: assignments ?? this.assignments,
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingResponseEntity.fromJson(String source) =>
      BookingResponseEntity.fromMap(json.decode(source));
}
