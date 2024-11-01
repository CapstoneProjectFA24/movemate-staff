import 'dart:convert';

class BookingQueries {
  final String? search;
  final int page;
  final int perPage;
  final int? userId;
  final bool? IsReviewOnl;

  BookingQueries({
    this.search,
    required this.page,
    this.perPage = 10,
    this.userId,
    this.IsReviewOnl,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (search != null) {
      result['Search'] = search;
    }
    result['page'] = page;
    result['per_page'] = perPage;
    if (userId != null) {
      result['UserId'] = userId;
    }
    if (IsReviewOnl != null) {
      result['IsReviewOnl'] = IsReviewOnl;
    }

    return result;
  }

  factory BookingQueries.fromMap(Map<String, dynamic> map) {
    return BookingQueries(
      search: map['Search'],
      page: map['page']?.toInt() ?? 1,
      perPage: map['per_page']?.toInt() ?? 10,
      userId: map['UserId']?.toInt(),
      IsReviewOnl: map['IsReviewOnl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingQueries.fromJson(String source) =>
      BookingQueries.fromMap(json.decode(source));
}
