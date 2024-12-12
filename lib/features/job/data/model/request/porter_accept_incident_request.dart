import 'dart:convert';

class PorterAcceptIncidentRequest {
  final String failReason;
  //   "status": "string",
  // "failedReason": "string"

  PorterAcceptIncidentRequest({
    required this.failReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'failReason': failReason,
    };
  }

  factory PorterAcceptIncidentRequest.fromMap(Map<String, dynamic> map) {
    return PorterAcceptIncidentRequest(
      failReason: map['failReason'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  @override
  String toString() => 'PorterAcceptIncidentRequest(failReason: $failReason)';
  factory PorterAcceptIncidentRequest.fromJson(String source) =>
      PorterAcceptIncidentRequest.fromMap(json.decode(source));
}
