import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/auth/presentation/screens/sign_in/sign_in_controller.dart';
import 'package:movemate_staff/features/job/data/model/request/booking_requesst.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/service_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/domain/repositories/service_booking_repository.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';

import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/functions/shared_preference_utils.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

// config

// domain - data
import 'package:movemate_staff/features/auth/domain/repositories/auth_repository.dart';

// utils
import 'package:movemate_staff/utils/commons/functions/api_utils.dart';
import 'package:movemate_staff/utils/extensions/extensions_export.dart';

part 'booking_controller.g.dart';

final bookingResponseProvider =
    StateProvider<BookingResponseEntity?>((ref) => null);

@riverpod
class BookingController extends _$BookingController {
  int? bookingId;
  @override
  FutureOr<void> build() {}

  Future<List<BookingResponseEntity>> getBookings(
    PagingModel request,
    BuildContext context,
  ) async {
    List<BookingResponseEntity> bookings = [];

    state = const AsyncLoading();
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      final response = await bookingRepository.getBookings(
        accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
        request: request,
      );
      bookings = response.payload;

      print(bookings.length);
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
          await getBookings(request, context);
        }
      });
    }

    return bookings;
  }

  Future<List<ServiceEntity>> getVehicle(
    PagingModel request,
    BuildContext context,
  ) async {
    List<ServiceEntity> getVehicles = [];

    state = const AsyncLoading();
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      final response = await bookingRepository.getVehicle(
        accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
        request: request,
      );
      getVehicles = response.payload;
      // print("object: ${getVehicles}");
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

        await getVehicle(request, context);
      });
    }
    return getVehicles;
  }

  Future<List<ServicesPackageEntity>> getServicesPackage(
    PagingModel request,
    BuildContext context,
  ) async {
    List<ServicesPackageEntity> servicePackages = [];

    state = const AsyncLoading();
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    state = await AsyncValue.guard(() async {
      final response = await bookingRepository.getServicesPackage(
        accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
        request: request,
      );
      servicePackages = response.payload;
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

        await getServicesPackage(request, context);
      });
    }
    return servicePackages;
  }

  Future<BookingResponseEntity?> updateBooking({
    required int id,
    required BuildContext context,
  }) async {
    // Kiểm tra nếu đã đang xử lý thì không làm gì cả
    // if (state is AsyncLoading) {
    //   return null;
    // }
    state = const AsyncLoading();
    final bookingState = ref.read(bookingProvider);
    final bookingRequest = BookingUpdateRequest.fromBookingUpdate(bookingState);
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');

    // Debugging
    // print('Booking Request: ${jsonEncode(bookingRequest.toMap())}');

    state = await AsyncValue.guard(() async {
      // print("go here 1");
      await bookingRepository.postBookingservice(
        request: bookingRequest,
        accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
        id: id,
      );
      // print("go here 2");
      final updateReviewerStatusRequest = ReviewerStatusRequest(
        estimatedDeliveryTime:
            double.parse(bookingRequest.estimatedDeliveryTime),
        resourceList: bookingRequest.resourceList,
      );
      // print("go here 3 ${updateReviewerStatusRequest.toJson()} ");
      await ref.read(bookingRepositoryProvider).updateStateReviewer(
            accessToken: APIConstants.prefixToken + user.tokens.accessToken,
            request: updateReviewerStatusRequest,
            id: id,
          );
      // print("go here 4");
      // print("bookingResponse $bookingResponse");
      // print(
      //     'Booking bookingResponse.payload.toMap : ${jsonEncode(bookingResponse.payload.toMap())}');
    });

    if (state.hasError) {
      if (kDebugMode) {
        print('Error: at controller ${state.error}');
      }
      final statusCode = (state.error as DioException).onStatusDio();
      handleAPIError(
        statusCode: statusCode,
        stateError: state.error!,
        context: context,
      );
      return null;
    } else {
      print('Booking success state ${state.toString()}');
      return ref.read(bookingResponseProvider);
    }
  }

  Future<BookingResponseEntity?> getBookingById(
    int id,
    BuildContext context,
  ) async {
    BookingResponseEntity bookingById;

    state = const AsyncLoading();
    final serviceBookingRepository = ref.read(bookingRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final user = await SharedPreferencesUtils.getInstance('user_token');
    // print("tuan object check controller 1  ");
    state = await AsyncValue.guard(() async {
      // print("tuan object check controller 2  ");
      final response = await serviceBookingRepository.getBookingDetails(
        accessToken: APIConstants.prefixToken + user!.tokens.accessToken,
        id: id,
      );
      // print("tuan object check controller 3  ");
      bookingById = response.payload;
      ref.read(bookingResponseProvider.notifier).state = response.payload;

      // print("tuan object check controller 4 ${bookingById} ");
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
        await getBookingById(id, context);
      });
    }
    return null;
  }
}
