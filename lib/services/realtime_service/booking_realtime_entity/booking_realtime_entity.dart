import 'dart:convert';

class BookingRealtimeEntity {
  final String id;
  final String status;
  final String bookingAt;
  final List<AssignmentsRealtimeEntity> assignments;
  final bool? isCredit;

  BookingRealtimeEntity({
    required this.id,
    required this.status,
    required this.bookingAt,
    required this.assignments,
    this.isCredit,
  });

  factory BookingRealtimeEntity.fromMap(Map<String, dynamic> data, String id) {
    return BookingRealtimeEntity(
      id: id,
      status: data['Status'],
      bookingAt: data['BookingAt'],
      assignments: (data['Assignments'] as List<dynamic>?)
              ?.map((e) => AssignmentsRealtimeEntity.fromMap(e))
              .toList() ??
          [],
      isCredit: data['IsCredit'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Status': status,
      'BookingAt': bookingAt,
      'Assignments': assignments.map((e) => e.toMap()).toList(),
      'IsCredit': isCredit,
    };
  }

  String toJson() => json.encode(toMap());
}

class AssignmentsRealtimeEntity {
  final String status;
  final String staffType;

  AssignmentsRealtimeEntity({
    required this.status,
    required this.staffType,
  });

  factory AssignmentsRealtimeEntity.fromMap(Map<String, dynamic> data) {
    return AssignmentsRealtimeEntity(
      status: data['Status'],
      staffType: data['StaffType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Status': status,
      'StaffType': staffType,
    };
  }

  String toJson() => json.encode(toMap());
}
