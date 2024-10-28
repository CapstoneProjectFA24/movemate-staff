import 'dart:convert';

import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';

class HouseTypeObjResponse {
  final HouseEntities payload;

  HouseTypeObjResponse({
    required this.payload,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'payload': payload.toMap()});

    return result;
  }

  factory HouseTypeObjResponse.fromMap(Map<String, dynamic> map) {
    return HouseTypeObjResponse(
      payload: HouseEntities.fromMap(map['payload']),
    );
  }

  String toJson() => json.encode(toMap());

  factory HouseTypeObjResponse.fromJson(String source) =>
      HouseTypeObjResponse.fromMap(json.decode(source));
}
