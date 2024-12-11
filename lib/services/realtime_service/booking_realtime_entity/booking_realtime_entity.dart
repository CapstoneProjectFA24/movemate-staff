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

class BookingTrackersEntity {
  final String type;
  final List<TrackerSourseEntity> trackerSources;

  BookingTrackersEntity({
    required this.type,
    required this.trackerSources,
  });

  factory BookingTrackersEntity.fromMap(Map<String, dynamic> data) {
    return BookingTrackersEntity(
      type: data['Type'],
      trackerSources: (data['TrackerSources'] as List<dynamic>?)
              ?.map((e) => TrackerSourseEntity.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Type': type,
      'TrackerSources': trackerSources.map((e) => e.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}

class TrackerSourseEntity {
  final String resourceUrl;
  final String resourceCode;

  TrackerSourseEntity({
    required this.resourceUrl,
    required this.resourceCode,
  });

  factory TrackerSourseEntity.fromMap(Map<String, dynamic> data) {
    return TrackerSourseEntity(
      resourceUrl: data['ResourceUrl'],
      resourceCode: data['ResourceCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ResourceUrl': resourceUrl,
      'ResourceCode': resourceCode,
    };
  }

  String toJson() => json.encode(toMap());
}
