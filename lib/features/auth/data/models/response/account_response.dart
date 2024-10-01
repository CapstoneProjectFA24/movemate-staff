import 'dart:convert';

import 'package:movemate_staff/features/auth/domain/entities/account_entities.dart';
import 'package:movemate_staff/models/token_model.dart';

class AccountReponse {
  final AccountEntities payload;

  AccountReponse({
    required this.payload,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'payload': payload.toMap()});

    return result;
  }

  factory AccountReponse.fromMap(Map<String, dynamic> map) {
    return AccountReponse(
      payload: AccountEntities.fromMap(map["payload"]),
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountReponse.fromJson(String source) =>
      AccountReponse.fromMap(json.decode(source));
}
