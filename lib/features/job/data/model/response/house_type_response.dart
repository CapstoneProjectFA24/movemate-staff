import 'dart:convert';

import 'package:movemate_staff/features/job/domain/entities/house_type_entity.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';

class HouseTypeResponse {
  final List<HouseEntities> payload;

  HouseTypeResponse({
    required this.payload,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'payload': payload.map((x) => x.toMap()).toList()});

    return result;
  }

  factory HouseTypeResponse.fromMap(Map<String, dynamic> map) {
    return HouseTypeResponse(
      payload: List<HouseEntities>.from(
          map['payload']?.map((x) => HouseEntities.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory HouseTypeResponse.fromJson(String source) =>
      HouseTypeResponse.fromMap(json.decode(source));
}
