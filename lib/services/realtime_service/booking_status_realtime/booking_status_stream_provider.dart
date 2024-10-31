import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/utils/enums/booking_status_type.dart';

final orderStatusStreamProvider =
    StreamProvider.family<BookingStatusType, String>((ref, bookingId) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .doc(bookingId)
      .snapshots()
      .map((snapshot) {
    final statusString = snapshot.data()?['Status'] as String? ?? 'PENDING';
    return statusString.toBookingTypeEnum();
  });
});
final orderStatusAssignmentStreamProvider =
    StreamProvider.family<List<AssignmentsStatusType>, String>(
        (ref, bookingId) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .doc(bookingId)
      .snapshots()
      .map((snapshot) {
    final assignments = snapshot.data()?['Assignments'] as List<dynamic>? ?? [];
    final statusList = assignments.map((assignment) {
      final statusString = assignment['Status'] as String? ?? 'ASSIGNED';
      return statusString.toAssignmentsTypeEnum();
    }).toList();
    return statusList;
  });
});
