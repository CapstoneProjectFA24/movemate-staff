import 'dart:convert';

class PorterAcceptIncidentRequest {
  final String? failReason;
  final String? status;
  // "failedReason": "string"

  PorterAcceptIncidentRequest({
    this.failReason,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'failReason': failReason,
      'status': status,
    };
  }

  factory PorterAcceptIncidentRequest.fromMap(Map<String, dynamic> map) {
    return PorterAcceptIncidentRequest(
      failReason: map['failReason'] ?? '',
      status: map['status'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  @override
  String toString() => 'PorterAcceptIncidentRequest(failReason: $failReason)';
  factory PorterAcceptIncidentRequest.fromJson(String source) =>
      PorterAcceptIncidentRequest.fromMap(json.decode(source));
}
