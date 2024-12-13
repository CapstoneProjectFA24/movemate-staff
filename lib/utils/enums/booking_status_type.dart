enum BookingStatusType {
  pending('PENDING'),
  depositing('DEPOSITING'),
  assigned('ASSIGNED'),
  reviewed('REVIEWED'),
  approved('APPROVED'),
  reviewing('REVIEWING'),
  coming('COMING'),
  waiting('WAITING'),
  inProgress('IN_PROGRESS'),
  confirmed('CONFIRMED'),
  completed('COMPLETED'),
  cancelled('CANCEL'),
  refunded('REFUNDED'),
  paused('PAUSED');

  final String type;
  const BookingStatusType(this.type);
}

enum AssignmentsStatusType {
  assigned('ASSIGNED'),
  incoming('INCOMING'),
  arrived('ARRIVED'),
  reviewing('REVIEWING'),
  suggested('SUGGESTED'),
  reviewed('REVIEWED'),
  inProgress('IN_PROGRESS'),
  inPacking('PACKING'),
  inTransit('IN_TRANSIT'),
  ongoing('ONGOING'),
  waiting('WAITING'),
  unloaded('UNLOADED'),
  delivered('DELIVERED'),
  completed('COMPLETED');

  final String type;
  const AssignmentsStatusType(this.type);
}

extension ConvertOrderPartnerStatus on String {
  BookingStatusType toBookingTypeEnum() {
    switch (toUpperCase()) {
      case 'PENDING':
        return BookingStatusType.pending;
      case 'DEPOSITING':
        return BookingStatusType.depositing;
      case 'ASSIGNED':
        return BookingStatusType.assigned;
      case 'REVIEWED':
        return BookingStatusType.reviewed;
      case 'APPROVED':
        return BookingStatusType.approved;
      case 'REVIEWING':
        return BookingStatusType.reviewing;
      case 'COMING':
        return BookingStatusType.coming;
      case 'WAITING':
        return BookingStatusType.waiting;
      case 'IN_PROGRESS':
        return BookingStatusType.inProgress;
      case 'CONFIRMED':
        return BookingStatusType.confirmed;
      case 'PAUSED':
        return BookingStatusType.paused;
      case 'COMPLETED':
        return BookingStatusType.completed;
      case 'CANCEL':
        return BookingStatusType.cancelled;
      case 'REFUNDED':
        return BookingStatusType.refunded;
      default:
        return BookingStatusType.pending;
    }
  }

  AssignmentsStatusType toAssignmentsTypeEnum() {
    switch (toUpperCase()) {
      case 'ASSIGNED':
        return AssignmentsStatusType.assigned;
      case 'INCOMING':
        return AssignmentsStatusType.incoming;
      case 'ARRIVED':
        return AssignmentsStatusType.arrived;
      case 'REVIEWING':
        return AssignmentsStatusType.reviewing;
      case 'SUGGESTED':
        return AssignmentsStatusType.suggested;
      case 'REVIEWED':
        return AssignmentsStatusType.reviewed;
      case 'IN_PROGRESS':
        return AssignmentsStatusType.inProgress;
      case 'PACKING':
        return AssignmentsStatusType.inPacking;
      case 'ONGOING':
        return AssignmentsStatusType.ongoing;
      case 'UNLOADED':
        return AssignmentsStatusType.unloaded;
      case 'WAITING':
        return AssignmentsStatusType.waiting;
      case 'IN_TRANSIT':
        return AssignmentsStatusType.inTransit;
      case 'DELIVERED':
        return AssignmentsStatusType.delivered;
      case 'COMPLETED':
        return AssignmentsStatusType.completed;
      default:
        return AssignmentsStatusType.incoming;
    }
  }
}
