import 'dart:convert';

class DriverReportIncidentRequest {
  final String type;

  DriverReportIncidentRequest({
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
    };
  }

  factory DriverReportIncidentRequest.fromMap(Map<String, dynamic> map) {
    return DriverReportIncidentRequest(
      type: map['type'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  @override
  String toString() => 'DriverReportIncidentRequest(type: $type)';
  factory DriverReportIncidentRequest.fromJson(String source) =>
      DriverReportIncidentRequest.fromMap(json.decode(source));
}
