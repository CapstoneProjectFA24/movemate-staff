import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:movemate_staff/services/realtime_service/booking_realtime_entity/booking_realtime_entity.dart';
import 'package:movemate_staff/utils/enums/booking_status_type.dart';

class BookingStatusResult {
  final String statusMessage;
  final bool canReviewOffline;
  final bool canReviewOnline;
  final bool isWaitingForPayment;
  final bool isStaffEnroute;
  final bool isStaffArrived;
  final bool isReviewed;
  final bool isInProgress;
  final bool isInTransit;
  final bool isDelivered;
  final bool isCompleted;
  final bool isSuggested;
  final bool canCreateSchedule;

  BookingStatusResult({
    required this.statusMessage,
    required this.canReviewOffline,
    required this.canReviewOnline,
    required this.isWaitingForPayment,
    required this.isStaffEnroute,
    required this.isStaffArrived,
    required this.isReviewed,
    required this.isInProgress,
    required this.isInTransit,
    required this.isDelivered,
    required this.isCompleted,
    required this.isSuggested,
    required this.canCreateSchedule,
  });
}

BookingStatusResult useBookingStatus(
    BookingRealtimeEntity? booking, bool isReviewOnline) {
  return useMemoized(() {
    if (booking == null) {
      return BookingStatusResult(
        statusMessage: "",
        canReviewOffline: false,
        canReviewOnline: false,
        isWaitingForPayment: false,
        isStaffEnroute: false,
        isStaffArrived: false,
        isReviewed: false,
        isInProgress: false,
        isInTransit: false,
        isDelivered: false,
        isCompleted: false,
        isSuggested: false,
        canCreateSchedule: false,
      );
    }

    final assignments = booking.assignments ?? [];
    final status = booking.status.toBookingTypeEnum();

    // Check for offline reviewer assignment
    final hasReviewer = assignments.any((assignment) =>
        assignment.status.toAssignmentsTypeEnum() ==
            AssignmentsStatusType.suggested &&
        assignment.staffType == "REVIEWER");

    // Check if any assignment is in SUGGESTED state
    final isSuggested = assignments.any((assignment) =>
        assignment.status.toAssignmentsTypeEnum() ==
        AssignmentsStatusType.suggested);

    // Determine review capabilities
    final canReviewOffline = hasReviewer &&
        (status == BookingStatusType.reviewing && !isReviewOnline);

    final canReviewOnline =
        isReviewOnline && status == BookingStatusType.reviewing;

    // Check staff status
    final isStaffEnroute = assignments.any((a) =>
        a.status.toAssignmentsTypeEnum() == AssignmentsStatusType.enroute);

    final isStaffArrived = assignments.any((a) =>
        a.status.toAssignmentsTypeEnum() == AssignmentsStatusType.arrived);

    // Check delivery status
    final isInProgress = assignments.any((a) =>
        a.status.toAssignmentsTypeEnum() == AssignmentsStatusType.inProgress);

    final isInTransit = status ==
        // BookingStatusType.inTransit ||
        assignments.any((a) =>
            a.status.toAssignmentsTypeEnum() ==
            AssignmentsStatusType.inTransit);

    final isDelivered = assignments.any((a) =>
        a.status.toAssignmentsTypeEnum() == AssignmentsStatusType.delivered);

    final isCompleted = status == BookingStatusType.completed ||
        assignments.any((a) =>
            a.status.toAssignmentsTypeEnum() ==
            AssignmentsStatusType.completed);

    // Determine status message
    String statusMessage = "";
    switch (status) {
      case BookingStatusType.pending:
        statusMessage = "Chờ xác nhận";
        break;
      case BookingStatusType.depositing:
        statusMessage = "Chờ khách hàng thanh toán";
        break;
      case BookingStatusType.assigned:
        statusMessage = canReviewOffline
            ? "Chờ bạn xếp lịch với khách hàng"
            : "Đã được phân công";
        break;
      case BookingStatusType.waiting:
        statusMessage = "Đang chờ khách hàng chấp nhận lịch";
        break;
      case BookingStatusType.reviewing:
        if (isStaffEnroute) {
          statusMessage = "Nhân viên đang di chuyển";
        } else if (isStaffArrived) {
          statusMessage = "Nhân viên đã đến";
        } else {
          statusMessage = "Đang đợi bạn đánh giá";
        }
        break;
      case BookingStatusType.reviewed:
        statusMessage = "Đã đánh giá xong";
        break;
      case BookingStatusType.inProgress:
        statusMessage = "Đang thực hiện";
        break;
      // case BookingStatusType.inTransit:
      //   statusMessage = "Đang vận chuyển";
      //   break;
      // case BookingStatusType.delivered:
      //   statusMessage = "Đã giao hàng";
      //   break;
      case BookingStatusType.completed:
        statusMessage = "Hoàn thành";
        break;
      case BookingStatusType.cancelled:
        statusMessage = "Đã hủy";
        break;
      case BookingStatusType.refunded:
        statusMessage = "Đã hoàn tiền";
        break;
      default:
        statusMessage = "Không xác định";
    }

    return BookingStatusResult(
      statusMessage: statusMessage,
      canReviewOffline: canReviewOffline,
      canReviewOnline: canReviewOnline,
      isWaitingForPayment: status == BookingStatusType.depositing,
      isStaffEnroute: isStaffEnroute,
      isStaffArrived: isStaffArrived,
      isReviewed: status == BookingStatusType.reviewed,
      isInProgress: isInProgress,
      isInTransit: isInTransit,
      isDelivered: isDelivered,
      isCompleted: isCompleted,
      isSuggested: isSuggested,
      canCreateSchedule: status == BookingStatusType.assigned,
    );
  }, [booking]);
}
