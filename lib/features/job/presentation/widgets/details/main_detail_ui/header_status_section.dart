import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/widgets/dialog_schedule/schedule_dialog.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';

class BookingHeaderStatusSection extends HookConsumerWidget {
  final bool isReviewOnline;
  final BookingResponseEntity job;
  final FetchResult<BookingResponseEntity> fetchResult;

  const BookingHeaderStatusSection({
    Key? key,
    required this.isReviewOnline,
    required this.job,
    required this.fetchResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final bookingStatus = useBookingStatus(bookingAsync.value, isReviewOnline);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusMessage(bookingStatus.statusMessage),
          const SizedBox(height: 12),
          _buildTimeline(context, bookingStatus, ref),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(String statusMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusMessage,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTimeline(
      BuildContext context, BookingStatusResult bookingStatus, WidgetRef ref) {
    final List<_TimelineStep> timelineSteps = isReviewOnline
        ? _buildOnlineReviewerSteps(bookingStatus, context, ref)
        : _buildOfflineReviewerSteps(bookingStatus, context, ref);

    return Wrap(
      spacing: 8,
      runSpacing: 16,
      children: _buildTimelineRows(timelineSteps),
    );
  }

  List<_TimelineStep> _buildOnlineReviewerSteps(
      BookingStatusResult status, BuildContext context, WidgetRef ref) {
    return [
      _TimelineStep(
        title: 'Phân công',
        icon: Icons.assignment_ind,
        isActive: status.canConfirmReview,
        isCompleted: !status.canConfirmReview && status.isReviewed,
        action: status.canConfirmReview ? 'Xác nhận' : null,
        onPressed: status.canConfirmReview
            ? () => _confirmReviewAssignment(context)
            : null,
      ),
      _TimelineStep(
        title: 'Cập nhật dịch vụ',
        icon: Icons.edit,
        isActive: status.canUpdateServices,
        isCompleted: !status.canUpdateServices && status.isSuggested,
        action: status.canUpdateServices ? 'Cập nhật' : null,
        onPressed: status.canUpdateServices
            ? () => _navigateToServiceUpdate(context)
            : null,
      ),
      _TimelineStep(
        title: 'Đề xuất',
        icon: Icons.description,
        isActive: status.canConfirmSuggestion,
        isCompleted: !status.canConfirmSuggestion && status.isReviewed,
        action: status.canConfirmSuggestion ? 'Hoàn thành' : null,
        onPressed: status.canConfirmSuggestion
            ? () => _completeProposal(context)
            : null,
      ),
      _TimelineStep(
        title: 'Hoàn thành',
        icon: Icons.check_circle,
        isActive: status.isReviewed,
        isCompleted: false,
      ),
    ];
  }

  List<_TimelineStep> _buildOfflineReviewerSteps(
      BookingStatusResult status, BuildContext context, WidgetRef ref) {
    return [
      _TimelineStep(
        title: 'Xếp lịch',
        icon: Icons.calendar_today,
        isActive: status.canCreateSchedule,
        isCompleted: !status.canCreateSchedule,
        action: status.canCreateSchedule ? 'Hẹn' : null,
        onPressed: status.canCreateSchedule
            ? () => _showScheduleDialog(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Chờ khách',
        icon: Icons.people,
        isActive: status.isWaitingCustomer || status.isWaitingPayment,
        isCompleted: !status.isWaitingCustomer &&
            !status.isWaitingPayment &&
            status.isReviewed,
      ),
      _TimelineStep(
        title: 'Di chuyển',
        icon: Icons.directions_car,
        isActive: status.canConfirmMoving,
        isCompleted: !status.canConfirmMoving && status.isStaffEnroute,
        action: status.canConfirmMoving ? 'Bắt đầu' : null,
        onPressed:
            status.canConfirmMoving ? () => _confirmMoving(context) : null,
      ),
      _TimelineStep(
        title: 'Đang đến',
        icon: Icons.near_me,
        isActive: status.isStaffEnroute,
        isCompleted: !status.isStaffEnroute && status.isStaffArrived,
        action: status.canConfirmArrival ? 'Đã tới' : null,
        onPressed:
            status.canConfirmArrival ? () => _confirmArrival(context) : null,
      ),
      _TimelineStep(
        title: 'Cập nhật dịch vụ',
        icon: Icons.edit,
        isActive: status.canUpdateServices,
        isCompleted: !status.canUpdateServices && status.isSuggested,
        action: status.canUpdateServices ? 'Cập nhật' : null,
        onPressed: status.canUpdateServices
            ? () => _navigateToServiceUpdate(context)
            : null,
      ),
      _TimelineStep(
        title: 'Đề xuất',
        icon: Icons.description,
        isActive: status.canConfirmSuggestion,
        isCompleted: !status.canConfirmSuggestion && status.isReviewed,
        action: status.canConfirmSuggestion ? 'Hoàn thành' : null,
        onPressed: status.canConfirmSuggestion
            ? () => _completeProposal(context)
            : null,
      ),
      _TimelineStep(
        title: 'Hoàn thành',
        icon: Icons.check_circle,
        isActive: status.isReviewed,
        isCompleted: false,
      ),
    ];
  }

  List<Widget> _buildTimelineRows(List<_TimelineStep> steps) {
    final List<Widget> rows = [];
    final itemsPerRow = 4;

    for (var i = 0; i < steps.length; i += itemsPerRow) {
      final rowItems = steps.skip(i).take(itemsPerRow).toList();
      final isEvenRow = (i ~/ itemsPerRow) % 2 == 0;

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...rowItems.map((step) => Expanded(
                  child: _buildTimelineItem(
                    step.title,
                    step.icon,
                    step.isActive,
                    step.isCompleted,
                    step.action,
                    step.onPressed,
                  ),
                )),
            if (rowItems.length < itemsPerRow)
              ...List.generate(
                itemsPerRow - rowItems.length,
                (_) => const Spacer(),
              ),
          ],
        ),
      );

      if (i + itemsPerRow < steps.length) {
        rows.add(
          SizedBox(
            height: 20,
            child: CustomPaint(
              size: const Size(double.infinity, 20),
              painter: ZigzagConnectorPainter(isEvenRow: isEvenRow),
            ),
          ),
        );
      }
    }

    return rows;
  }

  Widget _buildTimelineItem(
    String title,
    IconData icon,
    bool isActive,
    bool isCompleted,
    String? action,
    VoidCallback? onPressed,
  ) {
    final Color color = isActive
        ? Colors.blue
        : isCompleted
            ? Colors.green
            : Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: color.withOpacity(0.1),
            ),
            child: Text(
              action,
              style: TextStyle(
                color: color,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Dialog and navigation methods
  void _showScheduleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        orderId: job.id.toString(),
        onDateTimeSelected: (DateTime selectedDateTime) async {
          final reviewerUpdateController =
              ref.read(reviewerUpdateControllerProvider.notifier);
          await reviewerUpdateController.updateCreateScheduleReview(
            request: ReviewerTimeRequest(reviewAt: selectedDateTime),
            id: job.id,
            context: context,
          );
          fetchResult.refresh();
        },
      ),
    );
  }

  void _confirmReviewAssignment(BuildContext context) {
    // Implementation for confirming review assignment
  }

  void _confirmMoving(BuildContext context) {
    // Implementation for confirming moving
  }

  void _confirmArrival(BuildContext context) {
    // Implementation for confirming arrival
  }

  void _navigateToServiceUpdate(BuildContext context) {
    // Implementation for navigating to service update
  }

  void _completeProposal(BuildContext context) {
    // Implementation for completing proposal
  }
}

class _TimelineStep {
  final String title;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final String? action;
  final VoidCallback? onPressed;

  _TimelineStep({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    this.action,
    this.onPressed,
  });
}

class ZigzagConnectorPainter extends CustomPainter {
  final bool isEvenRow;
  final Paint _paint;

  ZigzagConnectorPainter({required this.isEvenRow})
      : _paint = Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final segmentWidth = size.width / 4;

    if (isEvenRow) {
      path.moveTo(segmentWidth / 2, 0);
      path.lineTo(size.width - segmentWidth / 2, size.height);
    } else {
      path.moveTo(size.width - segmentWidth / 2, 0);
      path.lineTo(segmentWidth / 2, size.height);
    }

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
