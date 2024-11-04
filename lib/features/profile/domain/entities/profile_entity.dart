import 'dart:convert';

class ProfileEntity {
  final int id;
  final int roleId;
  final String name;
  final String phone;
  final String gender;
  final String email;

  ProfileEntity({
    required this.id,
    required this.roleId,
    required this.name,
    required this.phone,
    required this.gender,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "roleId": roleId,
      "name": name,
      "phone": phone,
      "gender": gender,
      "email": email,
    };
  }

  factory ProfileEntity.fromMap(Map<String, dynamic> map) {
    return ProfileEntity(
      id: map["id"] ?? 0,
      roleId: map["roleId"] ?? 0,
      name: map["name"] ?? '',
      phone: map["phone"] ?? '',
      gender: map["gender"] ?? '',
      email: map["email"] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileEntity.fromJson(String source) =>
      ProfileEntity.fromMap(json.decode(source));
}
