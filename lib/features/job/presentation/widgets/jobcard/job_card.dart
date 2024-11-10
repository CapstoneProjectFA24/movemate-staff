import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/screen/job_details_screen/job_details_screen.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';

class JobCard extends HookConsumerWidget {
  final BookingResponseEntity job;
  final VoidCallback onCallback;
  final bool isReviewOnline;
  final String currentTab;

  const JobCard({
    super.key,
    required this.onCallback,
    required this.job,
    required this.isReviewOnline,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final bookingStatus = useBookingStatus(bookingAsync.value, isReviewOnline);
    print(bookingStatus.statusMessage);
    return FadeInUp(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusIndicator(),
          const SizedBox(width: 10),
          Expanded(
            child: _buildCardContent(context, bookingStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Column(
      children: [
        Icon(
          _getStatusIcon(job.status),
          color: _getStatusColor(job.status),
          size: 24,
        ),
        Container(
          height: 60,
          width: 2,
          color: _getStatusColor(job.status).withOpacity(0.4),
        ),
      ],
    );
  }

  Widget _buildCardContent(BuildContext context, BookingStatusResult status) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getCardGradientColors(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(status),
              const SizedBox(height: 10),
              _buildStatusMessage(status),
              const SizedBox(height: 10),
              _buildAddressInfo(),
              const SizedBox(height: 10),
              _buildPaymentInfo(),
              if (_shouldShowActionButton(status)) ...[
                const SizedBox(height: 10),
                _buildActionButton(status),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BookingStatusResult status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Text(
            "Mã đơn dọn nhà: ${job.id}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildStatusBadge(status),
      ],
    );
  }

  Widget _buildStatusBadge(BookingStatusResult bookingStatus) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(job.status),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${bookingStatus.statusMessage}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatusMessage(BookingStatusResult status) {
    return Text(
      status.statusMessage,
      style: const TextStyle(color: Colors.white70, fontSize: 14),
      // textAlign: TextAlign.end,
      overflow: TextOverflow.visible,
      maxLines: 1,
    );
  }

  Widget _buildAddressInfo() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white70, size: 18),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                job.pickupAddress,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.flag, color: Colors.white70, size: 18),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                job.deliveryAddress,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Đặt cọc: ${NumberFormat('#,###').format(job.deposit)}đ',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Text(
          'Tổng đơn: ${NumberFormat('#,###').format(job.total)}đ',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  bool _shouldShowActionButton(BookingStatusResult status) {
    if (isReviewOnline) {
      return status.canConfirmReview ||
          status.canUpdateServices ||
          status.canConfirmSuggestion;
    } else {
      return status.canCreateSchedule ||
          status.canConfirmMoving ||
          status.canConfirmArrival ||
          status.canUpdateServices ||
          status.canConfirmSuggestion;
    }
  }

  Widget _buildActionButton(BookingStatusResult status) {
    String buttonText = _getActionButtonText(status);
    if (buttonText.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onCallback,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _getStatusColor(job.status),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(buttonText),
      ),
    );
  }

  String _getActionButtonText(BookingStatusResult status) {
    if (isReviewOnline) {
      if (status.canConfirmReview) return 'Xác nhận đánh giá';
      if (status.canUpdateServices) return 'Cập nhật dịch vụ';
      if (status.canConfirmSuggestion) return 'Hoàn thành đề xuất';
    } else {
      if (status.canCreateSchedule) return 'Xếp lịch';
      if (status.canConfirmMoving) return 'Xác nhận di chuyển';
      if (status.canConfirmArrival) return 'Xác nhận đã đến';
      if (status.canUpdateServices) return 'Cập nhật dịch vụ';
      if (status.canConfirmSuggestion) return 'Hoàn thành đề xuất';
    }
    return '';
  }

  List<Color> _getCardGradientColors() {
    switch (job.status) {
      case 'PENDING':
        return [
          Colors.yellow.shade700,
          Colors.yellow.shade400
        ]; // Yellow for pending
      case 'ASSIGNED':
        return [
          Colors.orange.shade700,
          Colors.orange.shade400
        ]; // Orange for assigned/in progress
      case 'REVIEWING':
        return [
          Colors.orange.shade700,
          Colors.orange.shade400
        ]; // Orange for reviewing/in progress
      case 'REVIEWED':
        return [
          Colors.green.shade700,
          Colors.green.shade400
        ]; // Green for reviewed/completed
      case 'COMING':
        return [
          Colors.orange.shade700,
          Colors.orange.shade400
        ]; // Orange for coming/on the way
      case 'IN_PROGRESS':
        return [
          Colors.orange.shade700,
          Colors.orange.shade400
        ]; // Orange for in progress
      case 'COMPLETED':
        return [
          Colors.green.shade900,
          Colors.green.shade600
        ]; // Green for completed
      case 'DEPOSITING':
        return [
          Colors.blue.shade800,
          Colors.blue.shade600
        ]; // Green for completed
      case 'CANCELLED':
        return [
          Colors.redAccent.shade100,
          Colors.red.shade400
        ]; // Light red for canceled
      default:
        return [Colors.grey.shade700, Colors.grey.shade400];
    }
  }

  Color _getStatusColor(String status) {
    switch (job.status) {
      case 'PENDING':
        return Colors.yellow;
      case 'ASSIGNED':
        return Colors.orange.shade900;
      case 'REVIEWING':
        return Colors.orange.shade900;
      case 'REVIEWED':
        return Colors.green.shade700;
      case 'COMING':
        return Colors.orange.shade900;
      case 'IN_PROGRESS':
        return Colors.orange.shade900;
      case 'DEPOSITING':
        return Colors.blue.shade800;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.redAccent.shade100;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'ASSIGNED':
        return Icons.assignment_ind;
      case 'REVIEWING':
        return Icons.rate_review;
      case 'REVIEWED':
        return Icons.thumb_up;
      case 'COMING':
        return Icons.directions_car;
      case 'IN_PROGRESS':
        return Icons.local_shipping;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getDisplayStatus(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ xử lý';
      case 'ASSIGNED':
        return 'Đã phân công';
      case 'REVIEWING':
        return 'Đang đánh giá';
      case 'REVIEWED':
        return 'Đã đánh giá';
      case 'COMING':
        return 'Đang đến';
      case 'IN_PROGRESS':
        return 'Đang thực hiện';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
}
