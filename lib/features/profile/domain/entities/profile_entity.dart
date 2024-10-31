import 'dart:convert';

//  "id": 1,
//     "roleId": 1,
//     "name": "Admin",
//     "phone": "0123456789",
//     "password": "hashedPassword123",
//     "gender": "Male",
//     "email": "johndoe@example.com",
//     "avatarUrl": null,
//     "dob": null,
//     "isBanned": false,
//     "isDeleted": false,
//     "createdAt": null,
//     "updatedAt": null,
//     "createdBy": null,
//     "updatedBy": null,
//     "isInitUsed": null,
//     "isDriver": false,
//     "codeIntroduce": null,
//     "numberIntroduce": null
class ProfileEntity {
  final int id;
  final String type;
  final String imageUrl;
  final String value;
  final int userId;
  final int roleId;
  final String name;
  final String phone;
  final String password;
  final String gender;
  final String email;
  final String avatarUrl;
  final String dob;
  final bool isBanned;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final String updatedBy;
  final bool isInitUsed;
  final bool isDriver;
  final String codeIntroduce;
  final String numberIntroduce;

  ProfileEntity({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.value,
    required this.userId,
    required this.roleId,
    required this.name,
    required this.phone,
    required this.password,
    required this.gender,
    required this.email,
    required this.avatarUrl,
    required this.dob,
    required this.isBanned,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.isInitUsed,
    required this.isDriver,
    required this.codeIntroduce,
    required this.numberIntroduce,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({"id": id});
    result.addAll({"type": type});
    result.addAll({"imageUrl": imageUrl});
    result.addAll({"value": value});
    result.addAll({"userId": userId});
    result.addAll({"roleId": roleId});
    result.addAll({"name": name});
    result.addAll({"phone": phone});
    result.addAll({"password": password});

    return result;
  }

  factory ProfileEntity.fromMap(Map<String, dynamic> map) {
    return ProfileEntity(
      id: map["id"]?.toInt() ?? 0,
      type: map["type"] ?? '',
      imageUrl: map["imageUrl"] ?? '',
      value: map["value"] ?? '',
      userId: map["userId"]?.toInt() ?? 0,
      roleId: map["roleId"]?.toInt() ?? 0,
      name: map["name"] ?? '',
      phone: map["phone"] ?? '',
      password: map["password"] ?? '',
      gender: map["gender"] ?? '',
      email: map["email"] ?? '',
      avatarUrl: map["avatarUrl"] ?? '',
      dob: map["dob"] ?? '',
      isBanned: map["isBanned"] ?? false,
      isDeleted: map["isDeleted"] ?? false,
      createdAt: map["createdAt"] ?? '',
      updatedAt: map["updatedAt"] ?? '',
      createdBy: map["createdBy"] ?? '',
      updatedBy: map["updatedBy"] ?? '',
      isInitUsed: map["isInitUsed"] ?? false,
      isDriver: map["isDriver"] ?? false,
      codeIntroduce: map["codeIntroduce"] ?? '',
      numberIntroduce: map["numberIntroduce"] ?? '',
    );
  }
  String toJson() => json.encode(toMap());

  factory ProfileEntity.fromJson(String source) =>
      ProfileEntity.fromMap(json.decode(source));
}
