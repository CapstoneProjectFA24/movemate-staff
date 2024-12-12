import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/auth/domain/repositories/auth_repository.dart';
import 'package:movemate_staff/features/auth/presentation/screens/sign_in/sign_in_controller.dart';
import 'package:movemate_staff/features/drivers/data/models/request/porter_update_service_request.dart';
import 'package:movemate_staff/features/job/data/model/request/driver_report_incident_request.dart';
import 'package:movemate_staff/features/job/domain/entities/available_staff_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/repositories/service_booking_repository.dart';
import 'package:movemate_staff/features/porter/data/models/request/porter_update_resourse_request.dart';
import 'package:movemate_staff/features/porter/domain/entities/order_tracker_entity_response.dart';
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
      final error = state.error!;
      if (error is DioException) {
        final statusCode = error.response?.statusCode ?? error.onStatusDio();

        if (statusCode != 400) {
          await handleAPIError(
            statusCode: statusCode,
            stateError: state.error!,
            context: context,
            onCallBackGenerateToken: () async => await reGenerateToken(
              authRepository,
              context,
            ),
          );
        }
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
      final error = state.error!;
      if (error is DioException) {
        final statusCode = error.response?.statusCode ?? error.onStatusDio();

        handleAPIError(
          statusCode: statusCode,
          stateError: state.error!,
          context: context,
        );
      } else {
        showSnackBar(
          context: context,
          content: error.toString(),
          icon: AssetsConstants.iconError,
          backgroundColor: Colors.red,
          textColor: AssetsConstants.whiteColor,
        );
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

// assign manual  porter available
  Future<void> updateManualPorterAvailableByBookingId(
    int id,
    BuildContext context,
  ) async {
    // AvailableStaffEntities? bookings;
    state = const AsyncLoading();
    print("tuan check id in controller 1 $id ");
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');
    state = await AsyncValue.guard(() async {
      print("tuan check id in controller 2 $id ");
      await ref
          .read(bookingRepositoryProvider)
          .updateManualPorterAvailableByBookingId(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            id: id,
          );

      ref
          .read(refreshPorterList.notifier)
          .update((state) => !ref.read(refreshPorterList));
      print("tuan check id in controller 3 $id ");
      showSnackBar(
        context: context,
        content: "Cập nhật trạng thái thành công",
        icon: AssetsConstants.iconSuccess,
        backgroundColor: Colors.green,
        textColor: AssetsConstants.whiteColor,
      );
    });

    if (state.hasError) {
      final error = state.error!;
      if (error is DioException) {
        final statusCode = error.response?.statusCode ?? error.onStatusDio();

        handleAPIError(
          statusCode: statusCode,
          stateError: state.error!,
          context: context,
        );
      } else {
        showSnackBar(
          context: context,
          content: error.toString(),
          icon: AssetsConstants.iconError,
          backgroundColor: Colors.red,
          textColor: AssetsConstants.whiteColor,
        );
      }
    }
  }

//porter report whern porter can not arived
  Future<void> porterReportIncident({
    required BuildContext context,
    required int id,
    required DriverReportIncidentRequest request,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    print('check requets $request');
    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).porterReportIncident(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            id: id,
            request: request,
          );

      showSnackBar(
        context: context,
        content: "Gửi yêu cầu thành công",
        icon: AssetsConstants.iconSuccess,
        backgroundColor: Colors.orange,
        textColor: AssetsConstants.whiteColor,
      );
      // if (res.statusCode == 200) {
      //   context.router.replaceAll([
      //     const TabViewScreenRoute(children: [HomeScreenRoute()]),
      //   ]);
      // }
    });

    if (!state.hasError) {
      context.router.replaceAll([
        const TabViewScreenRoute(children: [HomeScreenRoute()]),
      ]);
    }

    if (state.hasError) {
      final error = state.error!;
      if (error is DioException) {
        final statusCode = error.response?.statusCode ?? error.onStatusDio();

        handleAPIError(
          statusCode: statusCode,
          stateError: state.error!,
          context: context,
        );
      } else {
        showSnackBar(
          context: context,
          content: error.toString(),
          icon: AssetsConstants.iconError,
          backgroundColor: Colors.red,
          textColor: AssetsConstants.whiteColor,
        );
      }
    }
  }

//Porter update service
  Future<void> porterUpdateNewService({
    required BuildContext context,
    required int id,
    required PorterUpdateServiceRequest request,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');
    // final porterRequest = porterUpdateServiceRequest.fromBookingUpdate;
    // print('check requets $request');
    state = await AsyncValue.guard(() async {
      final res = await ref
          .read(bookingRepositoryProvider)
          .porterUpdateNewService(
            request: request,
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            id: id,
          );
      showSnackBar(
        context: context,
        content: "Gửi yêu cầu thành công",
        icon: AssetsConstants.iconSuccess,
        backgroundColor: Colors.orange,
        textColor: AssetsConstants.whiteColor,
      );
    });

    if (state.hasError) {
      final error = state.error!;
      if (error is DioException) {
        final statusCode = error.response?.statusCode ?? error.onStatusDio();

        handleAPIError(
          statusCode: statusCode,
          stateError: state.error!,
          context: context,
        );
      } else {
        showSnackBar(
          context: context,
          content: error.toString(),
          icon: AssetsConstants.iconError,
          backgroundColor: Colors.red,
          textColor: AssetsConstants.whiteColor,
        );
      }
    }
  }

//get list incident by booking id

  Future<List<BookingTrackersIncidentEntity>> getIncidentListByBookingId(
    PagingModel request,
    BuildContext context,
    int bookingId,
  ) async {
    List<BookingTrackersIncidentEntity> incidents = [];

    state = const AsyncLoading();
    final incidentRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      final response = await incidentRepository.getIncidentListByBookingId(
        accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
        request: request,
        bookingId: bookingId,
      );
      incidents = response.payload;
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

        // if (state.hasError) {
        //   await ref.read(signInControllerProvider.notifier).signOut(context);
        // }

        if (statusCode != StatusCodeType.unauthentication.type) {}
        await getIncidentListByBookingId(request, context, bookingId);
      });
    }

    return incidents;
  }
}
