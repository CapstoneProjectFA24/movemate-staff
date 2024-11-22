import 'dart:convert';

import 'package:movemate_staff/features/job/domain/entities/staff_entity.dart';

class AvailableStaffEntities {
  final int bookingNeedStaffs;
  final List<StaffEntity> staffInSlot;
  final List<StaffEntity> otherStaffs;
  final int countStaffInslots;
  final int countOtherStaff;
  final String staffType;
  final bool isSuccessed;
  final List<AssignmentEntity> assignmentInBooking;

  AvailableStaffEntities({
    required this.bookingNeedStaffs,
    required this.staffInSlot,
    required this.otherStaffs,
    required this.countStaffInslots,
    required this.countOtherStaff,
    required this.staffType,
    required this.isSuccessed,
    required this.assignmentInBooking,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingNeedStaffs': bookingNeedStaffs,
      'staffInSlot': staffInSlot.map((x) => x.toMap()).toList(),
      'otherStaffs': otherStaffs.map((x) => x.toMap()).toList(),
      'countStaffInslots': countStaffInslots,
      'countOtherStaff': countOtherStaff,
      'staffType': staffType,
      'isSuccessed': isSuccessed,
      'assignmentInBooking': assignmentInBooking.map((x) => x.toMap()).toList(),
    };
  }

  factory AvailableStaffEntities.fromMap(Map<String, dynamic> map) {
    print('Raw payload: $map'); // Kiểm tra payload raw

    return AvailableStaffEntities(
      bookingNeedStaffs: map['bookingNeedStaffs'] ?? 0,
      staffInSlot: map['staffInSlot'] != null
          ? List<StaffEntity>.from(
              map['staffInSlot'].map((x) => StaffEntity.fromMap(x)))
          : [],
      otherStaffs: map['otherStaffs'] != null
          ? List<StaffEntity>.from(
              map['otherStaffs'].map((x) => StaffEntity.fromMap(x)))
          : [],
      countStaffInslots: map['countStaffInslots'] ?? 0,
      countOtherStaff: map['countOtherStaff'] ?? 0,
      staffType: map['staffType'] ?? '',
      isSuccessed: map['isSuccessed'] ?? false,
      assignmentInBooking: map['assignmentInBooking'] != null
          ? List<AssignmentEntity>.from(map['assignmentInBooking']
              .map((x) => AssignmentEntity.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory AvailableStaffEntities.fromJson(String source) =>
      AvailableStaffEntities.fromMap(json.decode(source));
}

class AssignmentEntity {
  final int id;
  final int userId;
  final int bookingId;
  final String status;
  final double? price;
  final String staffType;
  final bool isResponsible;
  final String? failedReason;

  AssignmentEntity({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.status,
    this.price,
    required this.staffType,
    required this.isResponsible,
    this.failedReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookingId': bookingId,
      'status': status,
      'price': price,
      'staffType': staffType,
      'isResponsible': isResponsible,
      'failedReason': failedReason,
    };
  }

  factory AssignmentEntity.fromMap(Map<String, dynamic> map) {
    return AssignmentEntity(
      id: map['id'],
      userId: map['userId'],
      bookingId: map['bookingId'],
      status: map['status'],
      price: map['price'],
      staffType: map['staffType'],
      isResponsible: map['isResponsible'],
      failedReason: map['failedReason'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AssignmentEntity.fromJson(String source) =>
      AssignmentEntity.fromMap(json.decode(source));
}
