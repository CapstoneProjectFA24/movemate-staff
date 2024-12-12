// service_booking_source.dart

import 'package:dio/dio.dart';
import 'package:movemate_staff/features/drivers/data/models/request/update_resourse_request.dart';
import 'package:movemate_staff/features/job/data/model/queries/booking_queries.dart';
import 'package:movemate_staff/features/job/data/model/request/driver_report_incident_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/data/model/response/booking_response_object.dart';
import 'package:movemate_staff/features/job/data/model/response/house_type_obj_response.dart';
import 'package:movemate_staff/features/job/data/model/response/staff_response.dart';
import 'package:movemate_staff/features/job/data/model/response/update_booking_response.dart';
import 'package:movemate_staff/features/porter/data/models/request/porter_update_resourse_request.dart';
import 'package:movemate_staff/models/response/success_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import response models
import 'package:movemate_staff/features/job/data/model/response/booking_response.dart';
import 'package:movemate_staff/features/job/data/model/request/booking_requesst.dart';
import 'package:movemate_staff/features/job/data/model/response/house_type_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_fee_system_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_package_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_response.dart';

// Utils
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/providers/common_provider.dart';

part 'booking_source.g.dart';

@RestApi(baseUrl: APIConstants.baseUrl, parser: Parser.MapSerializable)
abstract class BookingSource {
  factory BookingSource(Dio dio, {String baseUrl}) = _BookingSource;

  // House Types
  @GET(APIConstants.get_house_types)
  Future<HttpResponse<HouseTypeResponse>> getHouseTypes(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
  );
  @GET('${APIConstants.get_house_types}/{id}')
  Future<HttpResponse<HouseTypeObjResponse>> getHouseDetails(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );
  // Services
  @GET(APIConstants.get_service_truck_cate)
  Future<HttpResponse<ServicesResponse>> getVehicle(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
  );

  // System Fees
  @GET(APIConstants.get_fees_system)
  Future<HttpResponse<ServicesFeeSystemResponse>> getFeeSystems(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
  );

  // Package Services
  @GET(APIConstants.get_service_not_type_truck)
  Future<HttpResponse<ServicesPackageResponse>> getServicesPackage(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Queries() Map<String, dynamic> queries,
  );
//Post , put
  // Post booking service
  @GET(APIConstants.bookings)
  Future<HttpResponse<BookingResponse>> getBookings(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Queries() BookingQueries queries,
  );

  @PUT('${APIConstants.post_booking_service}/{id}')
  Future<HttpResponse<UpdateBookingResponse>> postBookingservice(
    @Body() BookingUpdateRequest request,
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );
  @GET('${APIConstants.bookings}/{id}')
  Future<HttpResponse<BookingResponseObject>> getBookingDetails(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );
  // Post valuation booking service
  @POST(APIConstants.post_valuation_booking_service)
  Future<HttpResponse<BookingResponse>> postValuationBooking(
    @Body() BookingRequest request,
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
  );

  // PUT status staff reviwer

  // PUT status staff reviwer
  @PUT('${APIConstants.reviewer_state}/{id}')
  Future<HttpResponse<SuccessModel>> updateStateReviewer(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Body() ReviewerStatusRequest? request,
    @Path('id') int id,
  );

  @PUT('${APIConstants.reviewer_at}/{id}')
  Future<HttpResponse<SuccessModel>> updateCreateScheduleReview(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Body() ReviewerTimeRequest request,
    @Path('id') int id,
  );
  @PATCH('${APIConstants.assignments}/{id}')
  Future<HttpResponse<SuccessModel>> updateAssignStaffIsResponsibility(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int assignmentId,
  );

  // drivers
  @PUT('${APIConstants.drivers}/{id}')
  Future<HttpResponse<SuccessModel>> updateStatusDriverWithoutResourse(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );

  @PUT('${APIConstants.drivers}/{id}')
  Future<HttpResponse<SuccessModel>> updateStatusDriverResourse(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Body() UpdateResourseRequest request,
    @Path('id') int id,
  );

  //get available driver
  @GET('${APIConstants.available_drivers}/{id}')
  Future<HttpResponse<StaffResponse>> getDriverAvailableByBookingId(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );

  //assign manual available driver
  @PATCH('${APIConstants.assign_manual_available_drivers}/{id}')
  Future<HttpResponse<SuccessModel>> updateManualDriverAvailableByBookingId(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );
  // Driver confirms receipt of cash from customer

  @PATCH('${APIConstants.driver_confirms_cash}/{bookingId}')
  Future<HttpResponse<SuccessModel>> driverConfirmCashPayment(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('bookingId') int id,
  );

  // Driver report incident

  @PUT('${APIConstants.put_driver_incident}/{id}')
  Future<HttpResponse<SuccessModel>> driverReportIncident(
    @Body() String request,
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );

  //get available porter
  @GET('${APIConstants.available_porters}/{id}')
  Future<HttpResponse<StaffResponse>> getPorterAvailableByBookingId(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );

  //assign manual available porter
  @PATCH('${APIConstants.assign_manual_available_porters}/{id}')
  Future<HttpResponse<SuccessModel>> updateManualPorterAvailableByBookingId(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );

  // porter
  @PUT('${APIConstants.porters}/{id}')
  Future<HttpResponse<SuccessModel>> updateStatusPorterWithoutResourse(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Path('id') int id,
  );

  @PUT('${APIConstants.porters}/{id}')
  Future<HttpResponse<SuccessModel>> updateStatusPorterResourse(
    @Header(APIConstants.contentHeader) String contentType,
    @Header(APIConstants.authHeader) String accessToken,
    @Body() PorterUpdateResourseRequest request,
    @Path('id') int id,
  );
}

@riverpod
BookingSource bookingSource(BookingSourceRef ref) {
  final dio = ref.read(dioProvider);
  return BookingSource(dio);
}
