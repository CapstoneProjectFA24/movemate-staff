// service_booking_repository.dart

import 'package:movemate_staff/features/job/data/model/request/booking_requesst.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/data/model/response/booking_response.dart';
import 'package:movemate_staff/features/job/data/model/response/house_type_obj_response.dart';
import 'package:movemate_staff/features/job/data/model/response/house_type_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_fee_system_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_package_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_response.dart';
import 'package:movemate_staff/features/job/data/model/response/update_booking_response.dart';
import 'package:movemate_staff/features/job/data/remotes/booking_source.dart';
import 'package:movemate_staff/features/job/data/repositories/service_booking_repository_impl.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/models/response/success_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_booking_repository.g.dart';

abstract class BookingRepository {
  // House Type Methods
  Future<HouseTypeResponse> getHouseTypes({
    required PagingModel request,
    required String accessToken,
  });
  Future<HouseTypeObjResponse> getHouseDetails({
    // required PagingModel request,
    required String accessToken,
    required int id,
  });

  // Services Methods
  Future<ServicesResponse> getVehicle({
    required PagingModel request,
    required String accessToken,
  });

  // Services Fee System Methods
  Future<ServicesFeeSystemResponse> getFeeSystems({
    required PagingModel request,
    required String accessToken,
  });

  // Services Package Methods
  Future<ServicesPackageResponse> getServicesPackage({
    required PagingModel request,
    required String accessToken,
  });

  // post booking service
  Future<UpdateBookingResponse> postBookingservice({
    required BookingUpdateRequest request,
    required String accessToken,
    required int id,
  });

  Future<BookingResponse> getBookingDetails({
    required String accessToken,
    required int id,
  });

  Future<BookingResponse> getBookings({
    required String accessToken,
    required PagingModel request,
  });
  Future<BookingResponse> getBookingsDriver({
    required String accessToken,
    required PagingModel request,
  });

  Future<BookingResponse> postValuationBooking({
    required BookingRequest request,
    required String accessToken,
  });

  Future<SuccessModel> updateStateReviewer({
    required String accessToken,
    ReviewerStatusRequest? request,
    required int id,
  });
  Future<SuccessModel> updateCreateScheduleReview({
    required String accessToken,
    required ReviewerTimeRequest request,
    required int id,
  });
}

@Riverpod(keepAlive: true)
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  final bookingSource = ref.read(bookingSourceProvider);
  return BookingRepositoryImpl(bookingSource);
}
