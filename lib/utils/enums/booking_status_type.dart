enum BookingStatusType {
  pending('PENDING'),
  depositing('DEPOSITING'),
  assigned('ASSIGNED'),
  approved('APPROVED'),
  reviewing('REVIEWING'),
  coming('COMMING'),
  waiting('WAITING'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCEL'),
  refunded('REFUNDED');
  final String type;
  const BookingStatusType(this.type);
}
enum AssignmentsStatusType {
  enroute('ENROUTE'),
  arrived('ARRIVED'),
  reviewing('REVIEWING'),
  suggested('SUGGESTED'),
  reviewed('REVIEWED');
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
      case 'APPROVED':
        return BookingStatusType.approved;
      case 'REVIEWING':
        return BookingStatusType.reviewing;
      case 'COMMING':
        return BookingStatusType.coming;
      case 'WAITING':
        return BookingStatusType.waiting;
      case 'IN_PROGRESS':
        return BookingStatusType.inProgress;
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
}
