import 'dart:convert';

import 'package:movemate_staff/features/job/data/model/request/resource.dart';

class UpdateResourseRequest {
  final List<Resource> resourceList;

  UpdateResourseRequest({
    required this.resourceList,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (resourceList != null) {
      map['resourceList'] = resourceList?.map((e) => e.toMap()).toList();
    }
    return map;
  }

  factory UpdateResourseRequest.fromMap(Map<String, dynamic> map) {
    return UpdateResourseRequest(
      resourceList: List<Resource>.from(
          map['resourceList']?.map((x) => Resource.fromMap(x)) ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateResourseRequest.fromJson(String source) =>
      UpdateResourseRequest.fromMap(json.decode(source));
}
