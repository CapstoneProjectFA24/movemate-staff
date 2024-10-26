import 'dart:convert';

import 'package:movemate_staff/models/token_model.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';

class AccountEntities {
  final int id;
  final String email;
  final UserRole roleName;
  final TokenModel tokens;

  AccountEntities({
    required this.id,
    required this.email,
    required this.roleName,
    required this.tokens,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'email': email});
    result.addAll({'roleName': roleName.type});
    result.addAll({'tokens': tokens.toMap()});

    return result;
  }

  factory AccountEntities.fromMap(Map<String, dynamic> map) {
    return AccountEntities(
      id: map['id']?.toInt() ?? 0,
      email: map['email'] ?? '',
       roleName: (map['roleName'] as String).toUserRoleEnum(),
      tokens: TokenModel.fromMap(map['tokens']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountEntities.fromJson(String source) =>
      AccountEntities.fromMap(json.decode(source));
}