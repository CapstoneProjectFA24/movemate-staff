import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_enities.dart';
import 'package:movemate_staff/services/realtime_service/booking_realtime_entity/booking_realtime_entity.dart';
import 'package:movemate_staff/utils/enums/booking_status_type.dart';

class BookingStatusResult {
  final String statusMessage;
  final String? driverStatusMessage;
  final String? porterStatusMessage;
  // Reviewer states
  final bool canReviewOffline;
  final bool canReviewOnline;
  final bool canCreateSchedule;
  final bool canConfirmReview;
  final bool canUpdateServices;
  final bool canConfirmArrival;
  final bool canConfirmMoving;
  final bool canConfirmSuggestion;
  final bool canExpandStatus;

  // Status indicators
  final bool isWaitingCustomer;
  final bool isWaitingPayment;
  final bool isStaffEnroute;
  final bool isStaffArrived;
  final bool isSuggested;
  final bool isReviewed;
  final bool isBookingComing;
  final bool isInProgress;
  final bool isConfirmed;
  final bool isCompleted;

  // Driver states
  final bool canDriverConfirmIncoming;
  final bool canDriverConfirmArrived;
  final bool canDriverStartMoving;
  final bool canDriverCompleteDelivery;
  final bool isDriverAssigned;
  final bool isDriverWaiting;
  final bool isDriverMoving;

  // driver tracking
  final bool isDriverStartPoint;
  final bool isDriverAtDeliveryPoint;
  final bool isDriverEndDeliveryPoint;

  // Porter states
  final bool canPorterConfirmIncoming;
  final bool canPorterConfirmArrived;
  final bool canPorterConfirmInprogress;
  final bool canPorterConfirmPacking;
  final bool canPorterConfirmOngoing;
  final bool canPorterConfirmDelivered;
  final bool canPorterCompleteUnloading;
  final bool canPorterComplete;
  final bool isPorterAssigned;
  final bool isPorterWaiting;
  final bool isPorterMoving;
  final bool isPorterConfirm;

  // porter tracking
  bool isPorterStartPoint = false;
  bool isPorterAtDeliveryPoint = false;
  bool isPorterEndDeliveryPoint = false;

  BookingStatusResult({
    required this.statusMessage,
    this.driverStatusMessage,
    this.porterStatusMessage,
    this.canReviewOffline = false,
    this.canReviewOnline = false,
    this.canCreateSchedule = false,
    this.canConfirmReview = false,
    this.canUpdateServices = false,
    this.canConfirmArrival = false,
    this.canConfirmMoving = false,
    this.canConfirmSuggestion = false,
    this.isWaitingCustomer = false,
    this.isWaitingPayment = false,
    this.isStaffEnroute = false,
    this.isStaffArrived = false,
    this.isSuggested = false,
    this.isReviewed = false,
    this.isInProgress = false,
    this.isConfirmed = false,
    this.isBookingComing = false,
    this.isCompleted = false,
    this.canDriverConfirmIncoming = false,
    this.canDriverConfirmArrived = false,
    this.canDriverStartMoving = false,
    this.canDriverCompleteDelivery = false,
    this.canExpandStatus = false,
    this.isDriverAssigned = false,
    this.isDriverWaiting = false,
    this.isDriverMoving = false,
    this.isDriverStartPoint = false,
    this.isDriverAtDeliveryPoint = false,
    this.isDriverEndDeliveryPoint = false,
    this.canPorterConfirmIncoming = false,
    this.canPorterConfirmArrived = false,
    this.canPorterConfirmInprogress = false,
    this.canPorterConfirmPacking = false,
    this.canPorterConfirmOngoing = false,
    this.canPorterConfirmDelivered = false,
    this.canPorterCompleteUnloading = false,
    this.canPorterComplete = false,
    this.isPorterAssigned = false,
    this.isPorterWaiting = false,
    this.isPorterMoving = false,
    this.isPorterConfirm = false,
    this.isPorterStartPoint = false,
    this.isPorterAtDeliveryPoint = false,
    this.isPorterEndDeliveryPoint = false,
  });
}

BookingStatusResult useBookingStatus(
    BookingRealtimeEntity? booking, bool isReviewOnline) {
  return useMemoized(() {
    if (booking == null) {
      return BookingStatusResult(statusMessage: "");
    }

    final status = booking.status.toBookingTypeEnum();
    final assignments = booking.assignments ?? [];

// check valid Date and Time >= 30phuts (poster and driver )
    final bookingAt = booking.bookingAt;
    final now = DateTime.now();
    final format = DateFormat("MM/dd/yyyy HH:mm:ss");
    final bookingDateTime = format.parse(bookingAt);
    final isValidDate = now.difference(bookingDateTime).inMinutes >= 30;

    // Helper functions
    bool hasAssignmentWithStatus(
        String staffType, AssignmentsStatusType status) {
      return assignments.any((a) {
        return a.staffType == staffType.toString() &&
            a.status.toAssignmentsTypeEnum() == status;
      });
    }

    final hasReviewerAssignment =
        hasAssignmentWithStatus("REVIEWER", AssignmentsStatusType.assigned);

    // Trạng thái của assignments
    final isStaffEnroute =
        hasAssignmentWithStatus("REVIEWER", AssignmentsStatusType.incoming);

    final isStaffArrived =
        hasAssignmentWithStatus("REVIEWER", AssignmentsStatusType.arrived);

    final isSuggested =
        hasAssignmentWithStatus("REVIEWER", AssignmentsStatusType.suggested);

    // Driver states
    final isDriverWaiting =
        hasAssignmentWithStatus("DRIVER", AssignmentsStatusType.waiting);
    final isDriverAssigned =
        hasAssignmentWithStatus("DRIVER", AssignmentsStatusType.assigned);
    final isDriverIncoming =
        hasAssignmentWithStatus("DRIVER", AssignmentsStatusType.incoming);
    final isDriverArrived =
        hasAssignmentWithStatus("DRIVER", AssignmentsStatusType.arrived);
    final isDriverInProgress =
        hasAssignmentWithStatus("DRIVER", AssignmentsStatusType.inProgress);
    final isDriverCompleted =
        hasAssignmentWithStatus("DRIVER", AssignmentsStatusType.completed);

    // Porter states
    final isPorterWaiting =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.waiting);
    final isPorterAssigned =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.assigned);
    final isPorterIncoming =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.incoming);
    final isPorterArrived =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.arrived);
    final isPorterInProgress =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.inProgress);
    final isPorterPacking =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.inPacking);
    final isPorterOngoing =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.ongoing);
    final isPorterDelivered =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.delivered);
    final isPorterUnloaded =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.unloaded);
    final isPorterCompleted =
        hasAssignmentWithStatus("PORTER", AssignmentsStatusType.completed);

    // Driver action flags
    bool canDriverConfirmIncoming = false;
    bool canDriverConfirmArrived = false;
    bool canDriverStartMoving = false;
    bool canDriverCompleteDelivery = false;
    bool isDriverStartPoint = false;
    bool isDriverAtDeliveryPoint = false;
    bool isDriverEndDeliveryPoint = false;

    switch (status) {
      case BookingStatusType.coming:
        if (isDriverAssigned &&
            isValidDate &&
            !isDriverWaiting &&
            !isDriverIncoming) {
          canDriverConfirmIncoming = true;
        } else if (!isDriverWaiting &&
            !isDriverAssigned &&
            !isDriverInProgress &&
            !isDriverCompleted &&
            !isDriverArrived &&
            isDriverIncoming) {
          canDriverConfirmArrived = true;
        } else if (isDriverInProgress &&
            !isDriverWaiting &&
            !isDriverIncoming &&
            !isDriverAssigned &&
            !isDriverCompleted &&
            !isDriverArrived) {
          canDriverCompleteDelivery = true;
        }
        isDriverStartPoint = isDriverWaiting ||
            isDriverAssigned ||
            isDriverIncoming ||
            (!isDriverInProgress && !isDriverCompleted);

        break;

      case BookingStatusType.inProgress:
        if (isDriverAssigned &&
            !isDriverWaiting &&
            !isDriverIncoming &&
            !isDriverArrived &&
            !isDriverInProgress &&
            !isDriverCompleted) {
          canDriverConfirmIncoming = true;
        } else if (!isDriverWaiting &&
            !isDriverAssigned &&
            !isDriverInProgress &&
            !isDriverCompleted &&
            !isDriverArrived &&
            isDriverIncoming) {
          canDriverConfirmArrived = true;
        } else if (isDriverArrived &&
            !isDriverWaiting &&
            !isDriverInProgress &&
            !isDriverIncoming &&
            !isDriverAssigned &&
            !isDriverCompleted) {
          canDriverStartMoving = true;
        } else if (isDriverInProgress &&
            !isDriverWaiting &&
            !isDriverIncoming &&
            !isDriverAssigned &&
            !isDriverCompleted &&
            !isDriverArrived) {
          canDriverCompleteDelivery = true;
        }
        isDriverAtDeliveryPoint =
            (isDriverArrived || isDriverInProgress) && !isDriverCompleted;
        isDriverEndDeliveryPoint = isDriverCompleted;
        break;

      case BookingStatusType.completed:
        isDriverEndDeliveryPoint = isDriverCompleted;
        break;
      default:
        break;
    }
    // Porter action flags
    bool canPorterConfirmIncoming = false;
    bool canPorterConfirmArrived = false;
    bool canPorterConfirmInprogress = false;
    bool canPorterConfirmPacking = false;
    bool canPorterConfirmOngoing = false;
    bool canPorterConfirmDelivered = false;
    bool canPorterCompleteUnloading = false;
    bool canPorterComplete = false;
    bool isPorterStartPoint = false;
    bool isPorterAtDeliveryPoint = false;
    bool isPorterEndDeliveryPoint = false;

    switch (status) {
      case BookingStatusType.coming:
        if (!isPorterIncoming &&
            !isPorterArrived &&
            !isPorterInProgress &&
            !isPorterCompleted &&
            isPorterAssigned &&
            !isPorterWaiting &&
            !isPorterOngoing &&
            !isPorterDelivered &&
            !isPorterUnloaded) {
          canPorterConfirmIncoming = true;
        } else if (isPorterIncoming &&
            !isPorterArrived &&
            !isPorterInProgress &&
            !isPorterCompleted &&
            !isPorterAssigned &&
            !isPorterWaiting &&
            !isPorterOngoing &&
            !isPorterDelivered &&
            !isPorterUnloaded) {
          canPorterConfirmArrived = true;
        }

        isPorterStartPoint = isPorterWaiting ||
            isPorterAssigned ||
            isPorterIncoming ||
            (!isPorterInProgress && !isPorterCompleted);
        break;

      case BookingStatusType.inProgress:
        if (!isPorterIncoming &&
            !isPorterArrived &&
            !isPorterInProgress &&
            !isPorterCompleted &&
            isPorterAssigned &&
            !isPorterWaiting &&
            !isPorterOngoing &&
            !isPorterDelivered &&
            !isPorterUnloaded) {
          canPorterConfirmIncoming = true;
        } else if (isPorterIncoming &&
            !isPorterArrived &&
            !isPorterInProgress &&
            !isPorterCompleted &&
            !isPorterAssigned &&
            !isPorterWaiting &&
            !isPorterOngoing &&
            !isPorterDelivered &&
            !isPorterUnloaded) {
          canPorterConfirmArrived = true;
        } else if (!isPorterIncoming &&
            isPorterArrived &&
            !isPorterInProgress &&
            !isPorterCompleted &&
            !isPorterAssigned &&
            !isPorterWaiting &&
            !isPorterOngoing &&
            !isPorterDelivered &&
            !isPorterUnloaded) {
          canPorterConfirmInprogress = true;
        } else if (!isPorterIncoming &&
            !isPorterArrived &&
            isPorterInProgress &&
            !isPorterCompleted &&
            !isPorterAssigned &&
            !isPorterWaiting &&
            !isPorterOngoing &&
            !isPorterDelivered &&
            !isPorterUnloaded) {
          canPorterConfirmPacking = true;
        } else if (!isPorterIncoming &&
            !isPorterArrived &&
            !isPorterInProgress &&
            !isPorterCompleted &&
            !isPorterAssigned &&
            !isPorterWaiting &&
            !isPorterOngoing &&
            !isPorterDelivered &&
            isPorterPacking &&
            !isPorterUnloaded) {
          canPorterConfirmOngoing = true;
        } else if (!isPorterIncoming &&
            !isPorterArrived &&
            !isPorterInProgress &&
            !isPorterCompleted &&
            !isPorterAssigned &&
            !isPorterWaiting &&
            isPorterOngoing &&
            !isPorterDelivered &&
            !isPorterUnloaded) {
          canPorterConfirmDelivered = true;
        } else if (!isPorterIncoming &&
            !isPorterArrived &&
            !isPorterInProgress &&
            !isPorterCompleted &&
            !isPorterAssigned &&
            !isPorterWaiting &&
            !isPorterOngoing &&
            isPorterDelivered &&
            !isPorterUnloaded) {
          canPorterCompleteUnloading = true;
        } else if (!isPorterIncoming &&
            !isPorterArrived &&
            !isPorterInProgress &&
            !isPorterCompleted &&
            !isPorterAssigned &&
            !isPorterWaiting &&
            !isPorterOngoing &&
            !isPorterDelivered &&
            isPorterUnloaded) {
          canPorterComplete = true;
        }
        isPorterAtDeliveryPoint = (isPorterArrived ||
                isPorterInProgress ||
                isPorterPacking ||
                isPorterOngoing) &&
            (!isPorterCompleted || !isPorterUnloaded && !isPorterDelivered);

        isPorterEndDeliveryPoint =
            isPorterCompleted || isPorterDelivered || isPorterUnloaded;

        break;
      case BookingStatusType.completed:
        isPorterEndDeliveryPoint =
            isPorterCompleted || isPorterDelivered || isPorterUnloaded;
        break;
      default:
        break;
    }

    // Logic cho Reviewer Offline
    bool canReviewOffline = false;
    bool canCreateSchedule = false;
    bool canConfirmMoving = false;
    bool canConfirmArrival = false;
    bool canUpdateServices = false;
    bool canConfirmSuggestion = false;
    bool canExpandStatus = false;

    if (!isReviewOnline) {
      switch (status) {
        case BookingStatusType.assigned:
          canCreateSchedule = true;
          break;
        case BookingStatusType.reviewing:
          if (!isStaffEnroute && !isStaffArrived && !isSuggested) {
            canConfirmMoving = true;
          } else if (isStaffEnroute && !isStaffArrived && !isSuggested) {
            canConfirmArrival = true;
          } else if (isStaffArrived && !isSuggested) {
            canUpdateServices = true;
          } else if (isSuggested) {
            canConfirmSuggestion = true;
          }
          break;
        case BookingStatusType.coming:
          if (isDriverAssigned && isPorterAssigned) {
            canExpandStatus = true;
          }
        default:
          break;
      }
    }

    // Logic cho Reviewer Online
    bool canReviewOnline = false;
    bool canConfirmReview = false;

    if (isReviewOnline) {
      switch (status) {
        case BookingStatusType.assigned:
          if (hasReviewerAssignment) {
            canConfirmReview = true;
          }
          break;
        case BookingStatusType.reviewing:
          if (!isSuggested) {
            canUpdateServices = true;
          } else if (isSuggested) {
            canConfirmSuggestion = true;
          }
          break;
        case BookingStatusType.coming:
          if (isDriverAssigned && isPorterAssigned) {
            canExpandStatus = true;
          }
        default:
          break;
      }
    }

    return BookingStatusResult(
      statusMessage: determineStatusMessage(
          status,
          isReviewOnline,
          isStaffEnroute,
          isStaffArrived,
          canCreateSchedule,
          isDriverAssigned,
          isPorterAssigned),
      driverStatusMessage: determineDriverStatusMessage(
        status,
        isDriverWaiting,
        isDriverAssigned,
        isDriverIncoming,
        isDriverArrived,
        isDriverInProgress,
        isDriverCompleted,
      ),
      porterStatusMessage: determinePorterStatusMessage(
        status,
        isPorterWaiting,
        isPorterAssigned,
        isPorterIncoming,
        isPorterArrived,
        isPorterInProgress,
        isPorterPacking,
        isPorterOngoing,
        isPorterDelivered,
        isPorterCompleted,
      ),
      canReviewOffline: canReviewOffline,
      canReviewOnline: canReviewOnline,
      canCreateSchedule: canCreateSchedule,
      canConfirmReview: canConfirmReview,
      canUpdateServices: canUpdateServices,
      canConfirmArrival: canConfirmArrival,
      canConfirmMoving: canConfirmMoving,
      canConfirmSuggestion: canConfirmSuggestion,
      isWaitingCustomer: status == BookingStatusType.waiting,
      isWaitingPayment: status == BookingStatusType.depositing,
      isStaffEnroute: isStaffEnroute,
      isStaffArrived: isStaffArrived,
      isSuggested: isSuggested,
      isReviewed: status == BookingStatusType.reviewed,
      isBookingComing: status == BookingStatusType.coming,
      isInProgress: status == BookingStatusType.inProgress,
      isConfirmed: status == BookingStatusType.confirmed,
      isCompleted: status == BookingStatusType.completed,
      canDriverConfirmIncoming: canDriverConfirmIncoming,
      canDriverConfirmArrived: canDriverConfirmArrived,
      canDriverStartMoving: canDriverStartMoving,
      canDriverCompleteDelivery: canDriverCompleteDelivery,
      isDriverAssigned: isDriverAssigned,
      isDriverWaiting: isDriverWaiting,
      isDriverMoving: isDriverInProgress,
      isDriverStartPoint: isDriverStartPoint,
      isDriverAtDeliveryPoint: isDriverAtDeliveryPoint,
      isDriverEndDeliveryPoint: isDriverEndDeliveryPoint,
      canPorterConfirmIncoming: canPorterConfirmIncoming,
      canPorterConfirmArrived: canPorterConfirmArrived,
      canPorterConfirmInprogress: canPorterConfirmInprogress,
      canPorterConfirmPacking: canPorterConfirmPacking,
      canPorterConfirmOngoing: canPorterConfirmOngoing,
      canPorterConfirmDelivered: canPorterConfirmDelivered,
      canPorterCompleteUnloading: canPorterCompleteUnloading,
      canPorterComplete: canPorterComplete,
      isPorterAssigned: isPorterAssigned,
      isPorterWaiting: isPorterWaiting,
      isPorterMoving: isPorterInProgress,
      isPorterConfirm: isPorterPacking,
      isPorterStartPoint: isPorterStartPoint,
      isPorterAtDeliveryPoint: isPorterAtDeliveryPoint,
      isPorterEndDeliveryPoint: isPorterEndDeliveryPoint,
    );
  }, [booking, isReviewOnline]);
}

String determineStatusMessage(
  BookingStatusType status,
  bool isReviewOnline,
  bool isStaffEnroute,
  bool isStaffArrived,
  bool canCreateSchedule,
  bool isDriverAssigned,
  bool isPorterAssigned,
) {
  if (isReviewOnline) {
    switch (status) {
      case BookingStatusType.assigned:
        return "Đã được phân công";
      case BookingStatusType.reviewing:
        if (isStaffArrived) return "Đang đánh giá";
        return "Đang đợi đánh giá";
      case BookingStatusType.reviewed:
        return "Đã đánh giá";
      case BookingStatusType.depositing:
        return "Chờ khách hàng thanh toán";
      case BookingStatusType.coming:
        if (!isDriverAssigned && !isPorterAssigned) {
          return "Chờ phân công nhân viên";
        }
        if (isDriverAssigned && !isPorterAssigned) {
          return "Đã phân công tài xế - Chờ phân công nhân viên bốc xếp";
        }
        if (!isDriverAssigned && isPorterAssigned) {
          return "Đã phân công nhân viên bốc xếp - Chờ phân công tài xế";
        }
        return "Đã phân công";

      case BookingStatusType.inProgress:
        return "Đang vận chuyển";

      case BookingStatusType.confirmed:
        return "Đang thảo luận với khách";

      case BookingStatusType.completed:
        return "Đã hoàn thành";

      case BookingStatusType.cancelled:
        return "Đã hủy";
      case BookingStatusType.refunded:
        return "Đã hoàn tiền";
      case BookingStatusType.pending:
        return "Chờ xác nhận";
      default:
        return "Không xác định";
    }
  } else {
    switch (status) {
      case BookingStatusType.assigned:
        return canCreateSchedule ? "Chờ xếp lịch" : "Đã phân công";
      case BookingStatusType.waiting:
        return "Chờ khách hàng chấp nhận";
      case BookingStatusType.depositing:
        return "Chờ thanh toán";
      case BookingStatusType.reviewing:
        if (isStaffEnroute) return "Xác nhận để di chuyển";
        if (isStaffArrived) {
          return "Đã đến vui lòng đánh giá tình trạng";
        }
        return "Đang đợi đánh giá";
      case BookingStatusType.reviewed:
        return "Đã đánh giá xong";
      case BookingStatusType.coming:
        if (!isDriverAssigned && !isPorterAssigned) {
          return "Chờ phân công";
        }
        if (isDriverAssigned && !isPorterAssigned) {
          return "Đã phân công tài xế - Chờ phân công nhân viên bốc xếp";
        }
        if (!isDriverAssigned && isPorterAssigned) {
          return "Đã phân công nhân viên bốc xếp - Chờ phân công tài xế";
        }
        return "Đã phân công";

      case BookingStatusType.inProgress:
        return "Đang vận chuyển";

      case BookingStatusType.confirmed:
        return "Đang thảo luận với khách";

      case BookingStatusType.completed:
        return "Đã hoàn thành";
      case BookingStatusType.cancelled:
        return "Đã hủy";
      case BookingStatusType.refunded:
        return "Đã hoàn tiền";
      case BookingStatusType.pending:
        return "Chờ xác nhận";
      default:
        return "Không xác định";
    }
  }
}

String? determinePorterStatusMessage(
  BookingStatusType status,
  bool isWaiting,
  bool isAssigned,
  bool isIncoming,
  bool isArrived,
  bool isInProgress,
  bool isPorterPacking,
  bool isOngoing,
  bool isDelivered,
  bool isCompleted,
) {
  if (status != BookingStatusType.coming &&
      status != BookingStatusType.inProgress) {
    return null;
  }

  if (isWaiting) return "Đang chờ phân công";
  if (isAssigned && !isIncoming)
    return "Đã được phân công - Chờ xác nhận di chuyển";
  if (isIncoming && !isArrived) return "Đang trên đường đến";
  if (isArrived && !isInProgress) return "Đã đến - Chờ xác nhận bắt đầu dọn";
  if (isInProgress && !isPorterPacking) return "Đang dọn hàng lên xe";
  if (isPorterPacking && !isOngoing) return "Xác nhận trên xe";
  if (isOngoing && !isDelivered) return "Đang di chuyển đến điểm trả hàng";
  if (isDelivered && !isCompleted) return "Đã đến điểm trả - Chờ dỡ hàng";
  if (isCompleted) return "Đã hoàn thành dỡ hàng";

  return "Trạng thái không xác định";
}

String? determineDriverStatusMessage(
  BookingStatusType status,
  bool isWaiting,
  bool isAssigned,
  bool isIncoming,
  bool isArrived,
  bool isInProgress,
  bool isCompleted,
) {
  if (status != BookingStatusType.coming &&
      status != BookingStatusType.inProgress) {
    return null;
  }

  if (isWaiting) return "Đang chờ phân công";
  if (isAssigned && !isIncoming)
    return "Đã được phân công - Chờ xác nhận di chuyển tới nhà khách hàng";
  if (isIncoming && !isArrived) return "Đang trên đường đến nhà khách hàng";
  if (isArrived && !isInProgress)
    return "Đã đến - Chờ xác nhận di chuyển tới điểm giao hàng cho khách";
  if (isInProgress && !isCompleted) return "Đang vận chuyển hàng";
  if (isCompleted) return "Đã hoàn thành vận chuyển";

  return "Trạng thái không xác định";
}
