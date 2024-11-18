import 'dart:convert';
import 'package:movemate_staff/utils/enums/enums_export.dart';

import 'token_model.dart';
import 'user_token.dart';

class UserModel {
  final int? id;
  final String email;
  final UserRole roleName;

  final int? roleId;
  final String? name;
  final String? phone;
  final String? gender;
  final String? avatarUrl;

  final TokenModel tokens;
  final String? fcmToken;
  final List<UserDevice>? userTokens;

  UserModel({
    required this.id,
    required this.email,
    required this.roleName,
    this.roleId,
    this.name,
    this.phone,
    this.gender,
    this.avatarUrl,
    required this.tokens,
    this.fcmToken,
    this.userTokens,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }

    result.addAll({'email': email});
    result.addAll({'roleName': roleName.type});

    if (roleId != null) {
      result.addAll({'roleId': roleId});
    }
    if (name != null) {
      result.addAll({'name': name});
    }
    if (phone != null) {
      result.addAll({'phone': phone});
    }
    if (gender != null) {
      result.addAll({'gender': gender});
    }
    if (avatarUrl != null) {
      result.addAll({'avatarUrl': avatarUrl});
    }

    result.addAll({'tokens': tokens.toMap()});
    if (fcmToken != null) {
      result.addAll({'fcmToken': fcmToken});
    }
    if (userTokens != null) {
      result.addAll({'userTokens': userTokens!.map((x) => x.toMap()).toList()});
    }

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt(),
      email: map['email'] ?? '',
      roleName: (map['roleName'] as String).toUserRoleEnum(),
      roleId: map['roleId']?.toInt() ?? 0,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      tokens: TokenModel.fromMap(map['tokens']),
      fcmToken: map['fcmToken'],
      userTokens: map['userTokens'] != null
          ? List<UserDevice>.from(
              map['userTokens']?.map((x) => UserDevice.fromMap(x)))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    int? id,
    String? email,
    int? roleId,
    String? name,
    String? phone,
    String? gender,
    String? avatarUrl,
    TokenModel? tokens,
    String? fcmToken,
    List<UserDevice>? userTokens,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      roleName: roleName ?? roleName,
      roleId: roleId ?? this.roleId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tokens: tokens ?? this.tokens,
      fcmToken: fcmToken ?? this.fcmToken,
      userTokens: userTokens ?? this.userTokens,
    );
  }
}
