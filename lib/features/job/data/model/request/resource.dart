import 'dart:convert';

class Resource {
  final String type;
  final String resourceUrl;
  final String resourceCode;

  Resource({
    required this.type,
    required this.resourceUrl,
    required this.resourceCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'resourceUrl': resourceUrl,
      'resourceCode': resourceCode,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      type: map['type'] ?? '',
      resourceUrl: map['resourceUrl'] ?? '',
      resourceCode: map['resourceCode'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  @override
  String toString() =>
      'Resource(type: $type, resourceUrl: $resourceUrl, resourceCode: $resourceCode)';
  factory Resource.fromJson(String source) =>
      Resource.fromMap(json.decode(source));
}
