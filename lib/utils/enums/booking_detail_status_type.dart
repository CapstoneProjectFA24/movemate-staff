enum BookingDetailStatusType {
  waiting('WAITING'),
  assigned('ASSIGNED'),
  enroute('ENROUTE'),
  arrived('ARRIVED'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  failed('FAILED'),
  roundTrip('ROUND_TRIP'),
  confirm('CONFIRM'),
  suggested('SUGGESTED'),
  cancelled('CANCELLED'),
  refunded('REFUNDED'),
  reviewing('REVIEWING'),
  inTransit('IN_TRANSIT'),
  delivered('DELIVERED'),
  unload('UNLOAD');

  final String type;
  const BookingDetailStatusType(this.type);
}

extension ConvertBookingDetailStatus on String {
  BookingDetailStatusType toBookingDetailTypeEnum() {
    switch (this.toUpperCase()) {
      case 'WAITING':
        return BookingDetailStatusType.waiting;
      case 'ASSIGNED':
        return BookingDetailStatusType.assigned;
      case 'ENROUTE':
        return BookingDetailStatusType.enroute;
      case 'ARRIVED':
        return BookingDetailStatusType.arrived;
      case 'IN_PROGRESS':
        return BookingDetailStatusType.inProgress;
      case 'COMPLETED':
        return BookingDetailStatusType.completed;
      case 'FAILED':
        return BookingDetailStatusType.failed;
      case 'ROUND_TRIP':
        return BookingDetailStatusType.roundTrip;
      case 'CONFIRM':
        return BookingDetailStatusType.confirm;
      case 'SUGGESTED':
        return BookingDetailStatusType.suggested;
      case 'CANCELLED':
        return BookingDetailStatusType.cancelled;
      case 'REFUNDED':
        return BookingDetailStatusType.refunded;
      case 'REVIEWING':
        return BookingDetailStatusType.reviewing;
      case 'IN_TRANSIT':
        return BookingDetailStatusType.inTransit;
      case 'DELIVERED':
        return BookingDetailStatusType.delivered;
      case 'UNLOAD':
        return BookingDetailStatusType.unload;
      default:
        return BookingDetailStatusType.waiting;
    }
  }
}
