import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/auth/domain/repositories/auth_repository.dart';
import 'package:movemate_staff/features/auth/presentation/screens/sign_in/sign_in_controller.dart';
import 'package:movemate_staff/features/drivers/data/models/request/update_resourse_request.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/drivers_screen_widget/custom_bottom_sheet.dart';
import 'package:movemate_staff/features/job/data/model/request/driver_report_incident_request.dart';
import 'package:movemate_staff/features/job/domain/entities/available_staff_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/repositories/service_booking_repository.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/functions/functions_common_export.dart';
import 'package:movemate_staff/utils/commons/widgets/snack_bar.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';
import 'package:movemate_staff/utils/extensions/status_code_dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

part 'driver_controller.g.dart';

final refreshDriverList = StateProvider.autoDispose<bool>(
  (ref) => true,
);

@riverpod
class DriverController extends _$DriverController {
  @override
  FutureOr<void> build() {}

  Future<List<BookingResponseEntity>> getBookingsByDriver(
    PagingModel request,
    BuildContext context,
  ) async {
    List<BookingResponseEntity> bookings = [];
    final filterStatusType = ref.watch(filterSystemStatus).type;
    state = const AsyncLoading();
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      final response = await bookingRepository.getBookingsDriver(
        accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
        request: request,
        filterStatusType: filterStatusType,
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
          await getBookingsByDriver(request, context);
        }
      });
    }

    return bookings;
  }

  Future<void> updateStatusDriverWithoutResourse({
    required int id,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      await ref
          .read(bookingRepositoryProvider)
          .updateStatusDriverWithoutResourse(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            id: id,
          );

      ref
          .read(refreshDriverList.notifier)
          .update((state) => !ref.read(refreshDriverList));

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

      // if (state.hasError) {
      //   await ref.read(signInControllerProvider.notifier).signOut(context);
      // }
    }
  }

//Driver confirms receipt of cash from customer
  Future<void> driverConfirmCashPayment({
    required BuildContext context,
    required int id,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');
    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).driverConfirmCashPayment(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            id: id,
          );

      showSnackBar(
        context: context,
        content: "Cập nhật trạng thái thành công",
        icon: AssetsConstants.iconSuccess,
        backgroundColor: Colors.green,
        textColor: AssetsConstants.whiteColor,
      );
    });

    // if (state.hasValue) {
    //   final tabsRouter = context.router.root
    //       .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
    //   if (tabsRouter != null) {
    //     tabsRouter.setActiveIndex(0);
    //     context.router.popUntilRouteWithName(TabViewScreenRoute.name);
    //   } else {
    //     context.router.replaceAll([
    //       const TabViewScreenRoute(children: [HomeScreenRoute()]),
    //     ]);
    //   }
    // }

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

  Future<void> updateStatusDriverResourse({
    required int id,
    required UpdateResourseRequest request,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');
    print(
        "check 1 contrller request ${request.resourceList.firstWhere((e) => e.type != null).resourceUrl}");
    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).updateStatusDriverResourse(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            request: request,
            id: id,
          );

      ref
          .read(refreshDriverList.notifier)
          .update((state) => !ref.read(refreshDriverList));

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

//get driver available
  Future<AvailableStaffEntities?> getDriverAvailableByBookingId(
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
      final response = await bookingRepository.getDriverAvailableByBookingId(
          accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
          id: id);
      bookings = response.payload;
      return response.payload;
    });
    state = result;

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

    if (result is AsyncData<AvailableStaffEntities>) {
      return result.value;
    } else {
      return null;
    }
  }

// assign manual  driver available
  Future<void> updateManualDriverAvailableByBookingId(
    BuildContext context,
    int id,
  ) async {
    // AvailableStaffEntities? bookings;
    state = const AsyncLoading();
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');
    state = await AsyncValue.guard(() async {
      await ref
          .read(bookingRepositoryProvider)
          .updateManualDriverAvailableByBookingId(
            accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
            id: id,
          );

      ref
          .read(refreshDriverList.notifier)
          .update((state) => !ref.read(refreshDriverList));

      showSnackBar(
        context: context,
        content: "Cập nhật trạng thái thành công",
        icon: AssetsConstants.iconSuccess,
        backgroundColor: Colors.green,
        textColor: AssetsConstants.whiteColor,
      );
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

        if (statusCode != StatusCodeType.unauthentication.type) {}
      });
    }
  }

//Driver report whern driver can not arived
  Future<void> driverReportIncident({
    required BuildContext context,
    required int id,
    required String request,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    print('check requets $request');
    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).driverReportIncident(
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
}
