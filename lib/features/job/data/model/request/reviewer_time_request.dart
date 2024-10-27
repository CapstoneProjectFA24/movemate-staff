import 'dart:convert';

class ReviewerTimeRequest {
  final DateTime reviewAt;

  ReviewerTimeRequest({
    required this.reviewAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewAt': reviewAt.toIso8601String(),
    };
  }

  factory ReviewerTimeRequest.fromMap(Map<String, dynamic> map) {
    return ReviewerTimeRequest(
      reviewAt: DateTime.parse(map['reviewAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewerTimeRequest.fromJson(String source) =>
      ReviewerTimeRequest.fromMap(json.decode(source));
}
