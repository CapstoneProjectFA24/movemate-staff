import 'dart:convert';

class StaffEntity {
  final int id;
  final int scheduleId;
  final String? roleName;
  final int walletId;
  final String name;
  final String phone;
  final String email;
  final bool isDeleted;
  final String avatarUrl;

  StaffEntity({
    required this.id,
    required this.scheduleId,
    this.roleName,
    required this.walletId,
    required this.name,
    required this.phone,
    required this.email,
    required this.isDeleted,
    required this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({"id": id});
    result.addAll({"scheduleId": scheduleId});
    if (roleName != null) {
      result.addAll({"roleName": roleName});
    }
    result.addAll({"walletId": walletId});
    result.addAll({"name": name});
    result.addAll({"phone": phone});
    result.addAll({"email": email});
    result.addAll({"isDeleted": isDeleted});
    result.addAll({"avatarUrl": avatarUrl});

    return result;
  }

  factory StaffEntity.fromMap(Map<String, dynamic> map) {
    // print('StaffEntity raw map: $map');
    return StaffEntity(
      id: map["id"]?.toInt() ?? 0,
      scheduleId: map["scheduleId"]?.toInt() ?? 0,
      roleName: map["roleName"],
      walletId: map["walletId"]?.toInt() ?? 0,
      name: map["name"] ?? '',
      phone: map["phone"] ?? '',
      email: map["email"] ?? '',
      isDeleted: map["isDeleted"] ?? false,
      avatarUrl: map["avatarUrl"] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StaffEntity.fromJson(String source) =>
      StaffEntity.fromMap(json.decode(source));
}
