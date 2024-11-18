import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/auth/presentation/screens/sign_in/sign_in_controller.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/domain/repositories/service_booking_repository.dart';

import 'package:movemate_staff/utils/commons/functions/shared_preference_utils.dart';
import 'package:movemate_staff/utils/commons/widgets/snack_bar.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

// config

// domain - data
import 'package:movemate_staff/features/auth/domain/repositories/auth_repository.dart';

// utils
import 'package:movemate_staff/utils/commons/functions/api_utils.dart';
import 'package:movemate_staff/utils/extensions/extensions_export.dart';

part 'reviewer_update_controller.g.dart';

final refreshJobList = StateProvider.autoDispose<bool>(
  (ref) => true,
);

@riverpod
class ReviewerUpdateController extends _$ReviewerUpdateController {
  @override
  FutureOr<void> build() {}

  Future<void> updateCreateScheduleReview({
    required ReviewerTimeRequest request,
    required int id,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');
    // print("tuan log update request 1:  $request");
    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).updateCreateScheduleReview(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            request: request,
            id: id,
          );
      // print("tuan log update request 2:  $request");
      showSnackBar(
        context: context,
        content: "Cập nhật lịch hẹn thành công",
        icon: AssetsConstants.iconSuccess,
        backgroundColor: Colors.green,
        textColor: AssetsConstants.whiteColor,
      );
    });

    if (state.hasError) {
      final statusCode = (state.error as DioException).onStatusDio();

      await handleAPIError(
        statusCode: statusCode,
        stateError: state.error!,
        context: context,
        onCallBackGenerateToken: () async => await reGenerateToken(
          authRepository,
          context,
        ),
      );

      if (state.hasError) {
        await ref.read(signInControllerProvider.notifier).signOut(context);
      }
    }
  }

  Future<void> updateReviewerStatus({
    ReviewerStatusRequest? request,
    required int id,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      print("log here go 1");
      print("log here go 2 $request ");
      final response = await ref
          .read(bookingRepositoryProvider)
          .updateStateReviewer(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            request: request,
            id: id,
          );
      print('resourceLisst response: $response');
      showSnackBar(
        context: context,
        content: "Cập nhật trạng thái thành công",
        icon: AssetsConstants.iconSuccess,
        backgroundColor: Colors.green,
        textColor: AssetsConstants.whiteColor,
      );
    });

    if (state.hasError) {
      final statusCode = (state.error as DioException).onStatusDio();
      await handleAPIError(
        statusCode: statusCode,
        stateError: state.error!,
        context: context,
        onCallBackGenerateToken: () async => await reGenerateToken(
          authRepository,
          context,
        ),
      );

      if (state.hasError) {
        await ref.read(signInControllerProvider.notifier).signOut(context);
      }
    }
  }

  Future<void> updateAssignStaffIsResponsibility({
    required int assignmentId,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      await ref
          .read(bookingRepositoryProvider)
          .updateAssignStaffIsResponsibility(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            assignmentId: assignmentId,
          );

      ref
          .read(refreshJobList.notifier)
          .update((state) => !ref.read(refreshJobList));

      showSnackBar(
        context: context,
        content: "Cập người chịu trách nhiệm thành công",
        icon: AssetsConstants.iconSuccess,
        backgroundColor: Colors.green,
        textColor: AssetsConstants.whiteColor,
      );
    });

    if (state.hasError) {
      final statusCode = (state.error as DioException).onStatusDio();

      await handleAPIError(
        statusCode: statusCode,
        stateError: state.error!,
        context: context,
        onCallBackGenerateToken: () async => await reGenerateToken(
          authRepository,
          context,
        ),
      );

      if (state.hasError) {
        await ref.read(signInControllerProvider.notifier).signOut(context);
      }
    }
  }
}
