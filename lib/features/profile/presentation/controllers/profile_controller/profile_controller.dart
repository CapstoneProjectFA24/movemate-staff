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

  // Future<List<ProfileEntity>> getProfile(
  //   PagingModel request,
  //   BuildContext context,
  // ) async {
  //   List<ProfileEntity> profile = [];

  //   // state = const AsyncLoading();
  //   final profileRepository = ref.read(profileRepositoryProvider);
  //   final authRepository = ref.read(authRepositoryProvider);
  //   final user = await SharedPreferencesUtils.getInstance('user_token');

  //   state = await AsyncValue.guard(() async {
  //     final response = await profileRepository.getprofiles(
  //       accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
  //       request: request,
  //     );
  //     profile = response.payload;
  //     // print("controller ${profile.length}");
  //   });

  //   if (state.hasError) {
  //     state = await AsyncValue.guard(() async {
  //       final statusCode = (state.error as DioException).onStatusDio();
  //       await handleAPIError(
  //         statusCode: statusCode,
  //         stateError: state.error!,
  //         context: context,
  //         onCallBackGenerateToken: () async => await reGenerateToken(
  //           authRepository,
  //           context,
  //         ),
  //       );

  //       if (state.hasError) {
  //         await ref.read(signInControllerProvider.notifier).signOut(context);
  //       }

  //       if (statusCode != StatusCodeType.unauthentication.type) {}
  //     });
  //   }

  //   return profile;
  // }

  // Future<HouseEntities?> getHouseDetails(
  //   int id,
  //   BuildContext context,
  // ) async {
  //   HouseEntities? houseDetails;

  //   // state = const AsyncLoading();
  //   final profileRepository = ref.read(bookingRepositoryProvider);
  //   final authRepository = ref.read(authRepositoryProvider);
  //   final user = await SharedPreferencesUtils.getInstance('user_token');

  //   final result = await AsyncValue.guard(() async {
  //     final response = await houseTypeRepository.getHouseDetails(
  //       accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
  //       id: id,
  //     );
  //     // print("controller ${response.payload}");
  //     return response.payload;
  //   });

  //   state = result;

  //   if (result.hasError) {
  //     final statusCode = (result.error as DioException).onStatusDio();
  //     await handleAPIError(
  //       statusCode: statusCode,
  //       stateError: result.error!,
  //       context: context,
  //       onCallBackGenerateToken: () async => await reGenerateToken(
  //         authRepository,
  //         context,
  //       ),
  //     );

  //     if (statusCode != StatusCodeType.unauthentication.type) {}
  //   }

  //   if (result is AsyncData<HouseEntities>) {
  //     return result.value;
  //   } else {
  //     return null;
  //   }
  // }
}
