import 'dart:convert';

import 'package:movemate_staff/features/job/domain/entities/staff_entity.dart';

class AvailableStaffEntities {
  final int bookingNeedStaffs;
  final List<StaffEntity> staffInSlot;
  final List<StaffEntity> otherStaffs;
  final int countStaffInslots;
  final int countOtherStaff;
  final String staffType;
  final bool isSussed;

  AvailableStaffEntities({
    required this.bookingNeedStaffs,
    required this.staffInSlot,
    required this.otherStaffs,
    required this.countStaffInslots,
    required this.countOtherStaff,
    required this.staffType,
    required this.isSussed,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingNeedStaffs': bookingNeedStaffs,
      'staffInSlot': staffInSlot.map((x) => x.toMap()).toList(),
      'otherStaffs': otherStaffs.map((x) => x.toMap()).toList(),
      'countStaffInslots': countStaffInslots,
      'countOtherStaff': countOtherStaff,
      'staffType': staffType,
      'isSussed': isSussed,
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
      isSussed: map['isSussed'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AvailableStaffEntities.fromJson(String source) =>
      AvailableStaffEntities.fromMap(json.decode(source));
}
