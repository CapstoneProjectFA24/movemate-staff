import 'package:flutter/material.dart';
import 'package:movemate_staff/utils/enums/booking_status_type.dart';

class ButtonStateManager {
  static ButtonState getButtonState(
      BookingStatusType statusBooking, AssignmentsStatusType statusAssignment) {
    // Only process if booking status is reviewing and not assigned
    if (statusBooking != BookingStatusType.reviewing ||
        statusBooking == BookingStatusType.assigned) {
      return ButtonState(isVisible: false);
    }

    // Map different assignment statuses to corresponding button states
    switch (statusAssignment) {
      case AssignmentsStatusType.assigned:
        return ButtonState(
          isVisible: true,
          buttonText: "Bắt đầu",
          onPressedAction: ButtonAction.updateReviewerStatus,
        );

      case AssignmentsStatusType.coming:
        return ButtonState(
          isVisible: true,
          buttonText: "Đã đến",
          onPressedAction: ButtonAction.updateReviewerStatus,
        );

      case AssignmentsStatusType.suggested:
        return ButtonState(
          isVisible: true,
          buttonText: "Kết thúc review",
          onPressedAction: ButtonAction.updateReviewerStatus,
        );

      case AssignmentsStatusType.arrived:
        return ButtonState(
          isVisible: true,
          buttonText: "Cập nhật trạng thái",
          onPressedAction: ButtonAction.navigateToGenerateJob,
        );

      default:
        return ButtonState(isVisible: false);
    }
  }
}

// Enum to define possible button actions
enum ButtonAction {
  updateReviewerStatus,
  navigateToGenerateJob,
}

// Class to hold button state information
class ButtonState {
  final bool isVisible;
  final String buttonText;
  final ButtonAction onPressedAction;

  ButtonState({
    this.isVisible = false,
    this.buttonText = "",
    this.onPressedAction = ButtonAction.updateReviewerStatus,
  });
}
