import 'dart:convert';

class DriverReportIncidentRequest {
  final String failReason;

  DriverReportIncidentRequest({
    required this.failReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'failReason': failReason,
    };
  }

  factory DriverReportIncidentRequest.fromMap(Map<String, dynamic> map) {
    return DriverReportIncidentRequest(
      failReason: map['failReason'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  @override
  String toString() => 'DriverReportIncidentRequest(failReason: $failReason)';
  factory DriverReportIncidentRequest.fromJson(String source) =>
      DriverReportIncidentRequest.fromMap(json.decode(source));
}
