// service_booking_repository_impl.dart

import 'package:movemate_staff/features/drivers/data/models/request/update_resourse_request.dart';
import 'package:movemate_staff/features/job/data/model/queries/booking_queries.dart';
import 'package:movemate_staff/features/job/data/model/request/booking_requesst.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/data/model/response/booking_response.dart';
import 'package:movemate_staff/features/job/data/model/response/booking_response_object.dart';
import 'package:movemate_staff/features/job/data/model/response/house_type_obj_response.dart';
import 'package:movemate_staff/features/job/data/model/response/house_type_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_fee_system_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_package_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_response.dart';
import 'package:movemate_staff/features/job/data/model/response/staff_response.dart';
import 'package:movemate_staff/features/job/data/model/response/update_booking_response.dart';
import 'package:movemate_staff/features/job/data/remotes/booking_source.dart';
import 'package:movemate_staff/features/job/domain/repositories/service_booking_repository.dart';
import 'package:movemate_staff/features/porter/data/models/request/porter_update_resourse_request.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/models/response/success_model.dart';
import 'package:movemate_staff/utils/commons/functions/shared_preference_utils.dart';
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
  Future<HouseTypeObjResponse> getHouseDetails({
    required String accessToken,
    required int id,
  }) async {
    print("repo log $id");
    return getDataOf(
      request: () => _bookingSource.getHouseDetails(
        APIConstants.contentType,
        accessToken,
        id,
      ),
    );
  }

  @override
  Future<ServicesResponse> getVehicle({
    required PagingModel request,
    required String accessToken,
  }) async {
    return getDataOf(
      request: () =>
          _bookingSource.getVehicle(APIConstants.contentType, accessToken),
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
  Future<ServicesPackageResponse> getServicesPackage({
    required PagingModel request,
    required String accessToken,
  }) async {
    // Convert PagingModel to a Map of query parameters
    final Map<String, dynamic> queries = {
      'page': request.pageNumber,
      'per_page': request.pageSize,
      'SortColumn': request.sortColumn,
      // Add other parameters if needed
    };
    return getDataOf(
      request: () => _bookingSource.getServicesPackage(
        APIConstants.contentType,
        accessToken,
        queries,
      ),
    );
  }

  @override
  Future<UpdateBookingResponse> postBookingservice({
    required BookingUpdateRequest request,
    required String accessToken,
    required int id,
  }) {
    return getDataOf(
      request: () => _bookingSource.postBookingservice(
          request, APIConstants.contentType, accessToken, id),
    );
  }

  @override
  Future<BookingResponseObject> getBookingDetails({
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
    required PagingModel request,
  }) async {
    final user = await SharedPreferencesUtils.getInstance('user_token');
    final bookingQueries = BookingQueries(
      page: request.pageNumber,
      perPage: 50,
      userId: user!.id,
      IsReviewOnl: request.isReviewOnline,
    );
    return getDataOf(
      request: () => _bookingSource.getBookings(
          APIConstants.contentType, accessToken, bookingQueries),
    );
  }

  @override
  Future<BookingResponse> getBookingsDriver({
    required String accessToken,
    required PagingModel request,
    String? filterStatusType,
  }) async {
    final user = await SharedPreferencesUtils.getInstance('user_token');
    final bookingQueries = BookingQueries(
      page: request.pageNumber,
      perPage: request.pageSize,
      userId: user!.id,
      status: filterStatusType,
    );

    return getDataOf(
      request: () => _bookingSource.getBookings(
          APIConstants.contentType, accessToken, bookingQueries),
    );
  }

  @override
  Future<BookingResponse> getBookingsPorter({
    required String accessToken,
    required PagingModel request,
    String? filterPorterSystemStatus,
  }) async {
    final user = await SharedPreferencesUtils.getInstance('user_token');
    final bookingQueries = BookingQueries(
      page: request.pageNumber,
      perPage: request.pageSize,
      userId: user!.id,
      status: filterPorterSystemStatus,
    );

    return getDataOf(
      request: () => _bookingSource.getBookings(
          APIConstants.contentType, accessToken, bookingQueries),
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

  //reviewer state
  @override
  Future<SuccessModel> updateStateReviewer({
    required String accessToken,
    ReviewerStatusRequest? request,
    required int id,
  }) async {
    return getDataOf(
      request: () => _bookingSource.updateStateReviewer(
          APIConstants.contentType, accessToken, request, id),
    );
  }

  @override
  Future<SuccessModel> updateCreateScheduleReview({
    required String accessToken,
    required ReviewerTimeRequest request,
    required int id,
  }) async {
    // print("repo log ${request.toJson()}");
    // print("repo log $id");

    return getDataOf(
      request: () => _bookingSource.updateCreateScheduleReview(
          APIConstants.contentType, accessToken, request, id),
    );
  }

  @override
  Future<SuccessModel> updateAssignStaffIsResponsibility({
    required String accessToken,
    required int assignmentId,
  }) async {
    // print("repo log ${request.toJson()}");
    print("repo log $assignmentId");

    return getDataOf(
      request: () => _bookingSource.updateAssignStaffIsResponsibility(
          APIConstants.contentType, accessToken, assignmentId),
    );
  }

  // driver
  @override
  Future<SuccessModel> updateStatusDriverWithoutResourse({
    required String accessToken,
    required int id,
  }) async {
    return getDataOf(
      request: () => _bookingSource.updateStatusDriverWithoutResourse(
          APIConstants.contentType, accessToken, id),
    );
  }

//Driver confirms receipt of cash from customer
  @override
  Future<SuccessModel> driverConfirmCashPayment({
    required String accessToken,
    required int id,
  }) async {
    print("tuan checking repo  $id ");

    return getDataOf(
      request: () => _bookingSource.driverConfirmCashPayment(
          APIConstants.contentType, accessToken, id),
    );
  }

  @override
  Future<SuccessModel> updateStatusDriverResourse({
    required String accessToken,
    required UpdateResourseRequest request,
    required int id,
  }) async {
    return getDataOf(
      request: () => _bookingSource.updateStatusDriverResourse(
          APIConstants.contentType, accessToken, request, id),
    );
  }

  // get available driver
  @override
  Future<StaffResponse> getDriverAvailableByBookingId({
    required String accessToken,
    required int id,
  }) async {
    // print("  check list repo log $id");
    return getDataOf(
      request: () => _bookingSource.getDriverAvailableByBookingId(
          APIConstants.contentType, accessToken, id),
    );
  }

  //  assign manual  available driver
  @override
  Future<SuccessModel> updateManualDriverAvailableByBookingId({
    required String accessToken,
    required int id,
  }) async {
    // print("  check list repo log $id");
    return getDataOf(
      request: () => _bookingSource.updateManualDriverAvailableByBookingId(
          APIConstants.contentType, accessToken, id),
    );
  }

  // get available porter
  @override
  Future<StaffResponse> getPorterAvailableByBookingId({
    required String accessToken,
    required int id,
  }) async {
    // print("  check list repo log $id");
    return getDataOf(
      request: () => _bookingSource.getPorterAvailableByBookingId(
          APIConstants.contentType, accessToken, id),
    );
  }

  //  assign manual available porter
  @override
  Future<SuccessModel> updateManualPorterAvailableByBookingId({
    required String accessToken,
    required int id,
  }) async {
    print("tuan check id in repo 1 $id ");
    return getDataOf(
      request: () => _bookingSource.updateManualPorterAvailableByBookingId(
          APIConstants.contentType, accessToken, id),
    );
  }

  @override
  Future<SuccessModel> updateStatusPorterWithoutResourse({
    required String accessToken,
    required int id,
  }) async {
    return getDataOf(
      request: () => _bookingSource.updateStatusPorterWithoutResourse(
          APIConstants.contentType, accessToken, id),
    );
  }

  @override
  Future<SuccessModel> updateStatusPorterResourse({
    required String accessToken,
    required PorterUpdateResourseRequest request,
    required int id,
  }) async {
    return getDataOf(
      request: () => _bookingSource.updateStatusPorterResourse(
          APIConstants.contentType, accessToken, request, id),
    );
  }
}
