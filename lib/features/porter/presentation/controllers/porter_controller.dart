import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/auth/domain/repositories/auth_repository.dart';
import 'package:movemate_staff/features/auth/presentation/screens/sign_in/sign_in_controller.dart';
import 'package:movemate_staff/features/job/domain/entities/available_staff_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/repositories/service_booking_repository.dart';
import 'package:movemate_staff/features/porter/data/models/request/porter_update_resourse_request.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/porter_screen_widget/porter_bottom_sheet.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/functions/functions_common_export.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';
import 'package:movemate_staff/utils/extensions/status_code_dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

part 'porter_controller.g.dart';

final refreshPorterList = StateProvider.autoDispose<bool>(
  (ref) => true,
);

@riverpod
class PorterController extends _$PorterController {
  @override
  FutureOr<void> build() {}

  Future<List<BookingResponseEntity>> getBookingsByPorter(
    PagingModel request,
    BuildContext context,
  ) async {
    List<BookingResponseEntity> bookings = [];
    final filterStatusType = ref.watch(filterPorterSystemStatus).type;
    state = const AsyncLoading();
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      final response = await bookingRepository.getBookingsPorter(
        accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
        request: request,
        filterPorterSystemStatus: filterStatusType,
      );
      bookings = response.payload;
    });

    if (state.hasError) {
      state = await AsyncValue.guard(() async {
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

        if (statusCode != StatusCodeType.unauthentication.type) {
          await getBookingsByPorter(request, context);
        }
      });
    }

    return bookings;
  }

  Future<void> updateStatusPorterWithoutResourse({
    required int id,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      await ref
          .read(bookingRepositoryProvider)
          .updateStatusPorterWithoutResourse(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            id: id,
          );

      ref
          .read(refreshPorterList.notifier)
          .update((state) => !ref.read(refreshPorterList));

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

  Future<void> updateStatusPorterResourse({
    required int id,
    required PorterUpdateResourseRequest request,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');
    print(
        "check 1 contrller request ${request.resourceList.firstWhere((e) => e.type != null).resourceUrl}");
    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).updateStatusPorterResourse(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            request: request,
            id: id,
          );

      ref
          .read(refreshPorterList.notifier)
          .update((state) => !ref.read(refreshPorterList));

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

//get porter available
  Future<AvailableStaffEntities?> getPorterAvailableByBookingId(
    BuildContext context,
    int id,
  ) async {
    AvailableStaffEntities? bookings;
    state = const AsyncLoading();
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');
    // print(" check list controller 1");
    final result = await AsyncValue.guard(() async {
      final response = await bookingRepository.getPorterAvailableByBookingId(
          accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
          id: id);

      bookings = response.payload;
      return response.payload;
    });
    state = result;

    if (state.hasError) {
      state = await AsyncValue.guard(() async {
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

        if (statusCode != StatusCodeType.unauthentication.type) {}
      });
    }

    if (result is AsyncData<AvailableStaffEntities>) {
      return result.value;
    } else {
      return null;
    }
  }
}
