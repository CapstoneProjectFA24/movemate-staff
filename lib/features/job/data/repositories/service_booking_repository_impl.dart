// service_booking_repository_impl.dart

import 'package:movemate_staff/features/job/data/model/request/booking_requesst.dart';
import 'package:movemate_staff/features/job/data/model/response/booking_response.dart';
import 'package:movemate_staff/features/job/data/model/response/house_type_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_fee_system_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_package_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_response.dart';
import 'package:movemate_staff/features/job/data/remotes/booking_source.dart';
import 'package:movemate_staff/features/job/domain/repositories/service_booking_repository.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/resources/remote_base_repository.dart';

class BookingRepositoryImpl extends RemoteBaseRepository
    implements BookingRepository {
  final bool addDelay;
  final BookingSource _bookingSource;

  BookingRepositoryImpl(this._bookingSource, {this.addDelay = true});

  @override
  Future<HouseTypeResponse> getHouseTypes({
    required PagingModel request,
    required String accessToken,
  }) async {
    return getDataOf(
      request: () =>
          _bookingSource.getHouseTypes(APIConstants.contentType, accessToken),
    );
  }

    @override
  Future<HouseTypeResponse> getHouseDetails({
    required String accessToken,
    required int id,
  }) async {
    return getDataOf(
      request: () => _bookingSource.getHouseDetails(
          APIConstants.contentType, accessToken, id),
    );
  }

  @override
  Future<ServicesResponse> getServices({
    required PagingModel request,
    required String accessToken,
  }) async {
    return getDataOf(
      request: () =>
          _bookingSource.getServices(APIConstants.contentType, accessToken),
    );
  }

  // Services Fee System Methods
  @override
  Future<ServicesFeeSystemResponse> getFeeSystems({
    required PagingModel request,
    required String accessToken,
  }) async {
    return getDataOf(
      request: () =>
          _bookingSource.getFeeSystems(APIConstants.contentType, accessToken),
    );
  }

  // Services Package Methods
  @override
  Future<ServicesPackageResponse> getPackageServices({
    required PagingModel request,
    required String accessToken,
  }) async {
    return getDataOf(
      request: () => _bookingSource.getPackageServices(
        APIConstants.contentType,
        accessToken,
      ),
    );
  }

  @override
  Future<BookingResponse> postBookingservice({
    required BookingRequest request,
    required String accessToken,
  }) {
    return getDataOf(
      request: () => _bookingSource.postBookingservice(
          request, APIConstants.contentType, accessToken),
    );
  }

  @override
  Future<BookingResponse> getBookingDetails({
    required String accessToken,
    required int id,
  }) async {
    return getDataOf(
      request: () => _bookingSource.getBookingDetails(
          APIConstants.contentType, accessToken, id),
    );
  }

    @override
  Future<BookingResponse> getBookings({
    required String accessToken,
  }) async {
    return getDataOf(
      request: () =>
          _bookingSource.getBookings(APIConstants.contentType, accessToken),
    );
  }

  @override
  Future<BookingResponse> postValuationBooking({
    required BookingRequest request,
    required String accessToken,
  }) {
    return getDataOf(
      request: () => _bookingSource.postValuationBooking(
        request,
        APIConstants.contentType,
        accessToken,
      ),
    );
  }
}
