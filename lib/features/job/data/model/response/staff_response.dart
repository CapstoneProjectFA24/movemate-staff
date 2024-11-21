import 'dart:convert';

import 'package:movemate_staff/features/job/domain/entities/available_staff_entities.dart';

class StaffResponse {
  final AvailableStaffEntities payload;

  StaffResponse({
    required this.payload,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'payload': payload.toMap()});

    return result;
  }

  factory StaffResponse.fromMap(Map<String, dynamic> map) {
    // print('Raw map: $map'); // Kiểm tra raw map
    if (!map.containsKey('payload')) {
      throw Exception('Missing key: payload');
    }
    return StaffResponse(
      payload: AvailableStaffEntities.fromMap(map['payload'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory StaffResponse.fromJson(String source) =>
      StaffResponse.fromMap(json.decode(source));
}
