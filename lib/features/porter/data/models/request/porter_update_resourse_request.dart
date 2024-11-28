import 'dart:convert';

import 'package:movemate_staff/features/job/data/model/request/resource.dart';

class PorterUpdateResourseRequest {
  final List<Resource> resourceList;

  PorterUpdateResourseRequest({
    required this.resourceList,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['resourceList'] = resourceList.map((e) => e.toMap()).toList();
      return map;
  }

  factory PorterUpdateResourseRequest.fromMap(Map<String, dynamic> map) {
    return PorterUpdateResourseRequest(
      resourceList: List<Resource>.from(
          map['resourceList']?.map((x) => Resource.fromMap(x)) ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory PorterUpdateResourseRequest.fromJson(String source) =>
      PorterUpdateResourseRequest.fromMap(json.decode(source));
}
