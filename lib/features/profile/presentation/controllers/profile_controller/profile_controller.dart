import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movemate_staff/features/auth/domain/repositories/auth_repository.dart';
import 'package:movemate_staff/features/auth/presentation/screens/sign_in/sign_in_controller.dart';
import 'package:movemate_staff/features/profile/domain/entities/profile_entity.dart';
import 'package:movemate_staff/features/profile/domain/repositories/profile_repository.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/functions/api_utils.dart';
import 'package:movemate_staff/utils/commons/functions/shared_preference_utils.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/enums/status_code_type.dart';
import 'package:movemate_staff/utils/extensions/extensions_export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// config

// domain - data

// utils

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {}

  Future<ProfileEntity?> getUserInfo(
    int id,
    BuildContext context,
  ) async {
    ProfileEntity? userInfo;

    final profileRepository = ref.read(profileRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    final result = await AsyncValue.guard(() async {
      final response = await profileRepository.getUserInfo(
        accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
        id: id,
      );

      return response.payload;
    });

    state = result;

    if (result.hasError) {
      final statusCode = (result.error as DioException).onStatusDio();
      await handleAPIError(
        statusCode: statusCode,
        stateError: result.error!,
        context: context,
        onCallBackGenerateToken: () async => await reGenerateToken(
          authRepository,
          context,
        ),
      );

      if (statusCode != StatusCodeType.unauthentication.type) {}
    }

    if (result is AsyncData<ProfileEntity>) {
      return result.value;
    } else {
      return null;
    }
  }
}
