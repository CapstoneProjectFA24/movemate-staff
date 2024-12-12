// service_booking_repository.dart

import 'package:movemate_staff/features/drivers/data/models/request/driver_update_service_request.dart';
import 'package:movemate_staff/features/drivers/data/models/request/porter_update_service_request.dart';
import 'package:movemate_staff/features/drivers/data/models/request/update_resourse_request.dart';
import 'package:movemate_staff/features/job/data/model/request/booking_requesst.dart';
import 'package:movemate_staff/features/job/data/model/request/driver_report_incident_request.dart';
import 'package:movemate_staff/features/job/data/model/request/porter_accept_incident_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/data/model/response/booking_response.dart';
import 'package:movemate_staff/features/job/data/model/response/booking_response_object.dart';
import 'package:movemate_staff/features/job/data/model/response/house_type_obj_response.dart';
import 'package:movemate_staff/features/job/data/model/response/house_type_response.dart';
import 'package:movemate_staff/features/job/data/model/response/incident_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_fee_system_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_package_response.dart';
import 'package:movemate_staff/features/job/data/model/response/services_response.dart';
import 'package:movemate_staff/features/job/data/model/response/staff_response.dart';
import 'package:movemate_staff/features/job/data/model/response/update_booking_response.dart';
import 'package:movemate_staff/features/job/data/remotes/booking_source.dart';
import 'package:movemate_staff/features/job/data/repositories/service_booking_repository_impl.dart';
import 'package:movemate_staff/features/porter/data/models/request/porter_update_resourse_request.dart';
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

  Future<BookingResponseObject> getBookingDetails({
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
    String? filterStatusType,
  });
  Future<BookingResponse> getBookingsPorter({
    required String accessToken,
    required PagingModel request,
    String? filterPorterSystemStatus,
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
  Future<SuccessModel> updateAssignStaffIsResponsibility({
    required String accessToken,
    required int assignmentId,
  });

  Future<SuccessModel> updateStatusDriverWithoutResourse({
    required String accessToken,
    required int id,
  });

  Future<SuccessModel> updateStatusDriverResourse({
    required String accessToken,
    required UpdateResourseRequest request,
    required int id,
  });

  // get driver available
  Future<StaffResponse> getDriverAvailableByBookingId({
    required String accessToken,
    required int id,
  });
  //Driver confirms receipt of cash from customer
  Future<SuccessModel> driverConfirmCashPayment({
    required String accessToken,
    required int id,
  });
  //Driver report incldent s
  Future<SuccessModel> driverReportIncident({
    required DriverReportIncidentRequest request,
    required String accessToken,
    required int id,
  });
  Future<SuccessModel> porterAcceptIncidentByBookingId({
    required PorterAcceptIncidentRequest request,
    required String accessToken,
    required int id,
  });

  //driver update
  Future<SuccessModel> driverUpdateNewService({
    required String accessToken,
    required DriverUpdateServiceRequest request,
    required int id,
  });

  //porter report incldent s
  Future<SuccessModel> porterReportIncident({
    required DriverReportIncidentRequest request,
    required String accessToken,
    required int id,
  });
  //get  incident list
  Future<IncidentResponse> getIncidentListByBookingId({
    PagingModel request,
    required String accessToken,
    required int bookingId,
  });
  //porter update
  Future<SuccessModel> porterUpdateNewService({
    required String accessToken,
    required PorterUpdateServiceRequest request,
    required int id,
  });

  // assign manual driver available
  Future<SuccessModel> updateManualDriverAvailableByBookingId({
    required String accessToken,
    required int id,
  });

  // get porter available
  Future<StaffResponse> getPorterAvailableByBookingId({
    required String accessToken,
    required int id,
  });
  //  assign manual  porter available
  Future<SuccessModel> updateManualPorterAvailableByBookingId({
    required String accessToken,
    required int id,
  });

  Future<SuccessModel> updateStatusPorterWithoutResourse({
    required String accessToken,
    required int id,
  });

  Future<SuccessModel> updateStatusPorterResourse({
    required String accessToken,
    required PorterUpdateResourseRequest request,
    required int id,
  });
}


@Riverpod(keepAlive: true)
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  final bookingSource = ref.read(bookingSourceProvider);
  return BookingRepositoryImpl(bookingSource);
}
