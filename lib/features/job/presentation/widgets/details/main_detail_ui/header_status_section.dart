import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/widgets/dialog_schedule/schedule_dialog.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';

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
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Message Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookingStatus.statusMessage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (bookingStatus.isWaitingCustomer ||
                    bookingStatus.isWaitingPayment)
                  const SizedBox(height: 8),
                if (bookingStatus.isWaitingCustomer)
                  _buildStatusChip(
                    "Đang chờ khách hàng phản hồi",
                    Colors.orange,
                  ),
                if (bookingStatus.isWaitingPayment)
                  _buildStatusChip(
                    "Đang chờ thanh toán",
                    Colors.blue,
                  ),
              ],
            ),
          ),

          // Action Buttons Section
          if (_shouldShowActions(bookingStatus))
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  // Reviewer Offline Actions
                  if (!isReviewOnline) ...[
                    if (bookingStatus.canCreateSchedule)
                      _buildActionButton(
                        context: context,
                        icon: Icons.schedule,
                        label: "Tạo lịch hẹn",
                        onPressed: () => _showScheduleDialog(context, ref),
                      ),
                    if (bookingStatus.canConfirmMoving)
                      _buildActionButton(
                        context: context,
                        icon: Icons.directions_car,
                        label: "Xác nhận di chuyển",
                        onPressed: () => _handleConfirmAction(
                          context,
                          ref,
                          AssignmentsStatusType.enroute,
                          "Bạn có chắc chắn muốn xác nhận bắt đầu di chuyển?",
                          "Đã bắt đầu di chuyển",
                        ),
                      ),
                    if (bookingStatus.canConfirmArrival)
                      _buildActionButton(
                        context: context,
                        icon: Icons.location_on,
                        label: "Xác nhận đã đến",
                        onPressed: () => _handleConfirmAction(
                          context,
                          ref,
                          AssignmentsStatusType.arrived,
                          "Bạn có chắc chắn muốn xác nhận đã đến nơi?",
                          "Đã xác nhận đến nơi",
                        ),
                      ),
                  ],

                  // Common Actions for both Online and Offline
                  if (bookingStatus.canUpdateServices)
                    _buildActionButton(
                      context: context,
                      icon: Icons.edit,
                      label: "Cập nhật dịch vụ",
                      onPressed: () => _navigateToServices(context),
                    ),
                  if (bookingStatus.canConfirmSuggestion)
                    _buildActionButton(
                      context: context,
                      icon: Icons.check_circle,
                      label: "Hoàn thành đề xuất",
                      onPressed: () => _handleConfirmAction(
                        context,
                        ref,
                        AssignmentsStatusType.suggested,
                        "Bạn có chắc chắn muốn hoàn thành đề xuất?",
                        "Đã hoàn thành đề xuất",
                      ),
                    ),

                  // Reviewer Online Actions
                  if (isReviewOnline && bookingStatus.canConfirmReview)
                    _buildActionButton(
                      context: context,
                      icon: Icons.rate_review,
                      label: "Xác nhận đánh giá",
                      onPressed: () => _handleConfirmAction(
                        context,
                        ref,
                        AssignmentsStatusType.suggested,
                        "Bạn có chắc chắn muốn xác nhận đánh giá trực tuyến?",
                        "Đã xác nhận đánh giá",
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AssetsConstants.primaryDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  bool _shouldShowActions(BookingStatusResult status) {
    return status.canCreateSchedule ||
        status.canConfirmMoving ||
        status.canConfirmArrival ||
        status.canUpdateServices ||
        status.canConfirmSuggestion ||
        status.canConfirmReview;
  }

  void _showScheduleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        orderId: job.id.toString(),
        onDateTimeSelected: (DateTime selectedDateTime) async {
          final reviewerUpdateController = ref.read(
            reviewerUpdateControllerProvider.notifier,
          );
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

  void _handleConfirmAction(
    BuildContext context,
    WidgetRef ref,
    AssignmentsStatusType status,
    String confirmMessage,
    String successMessage,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          successMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          confirmMessage,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final reviewerUpdateController = ref.read(
                  reviewerUpdateControllerProvider.notifier,
                );
                await reviewerUpdateController.updateReviewerStatus(
                  id: job.id,
                  context: context,
                  request: ReviewerStatusRequest(
                    status: status as BookingStatusType,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(successMessage)),
                );
                fetchResult.refresh();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cập nhật thất bại: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AssetsConstants.primaryDark,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _navigateToServices(BuildContext context) {
    // Implement navigation to services page
    // Example:
    // Navigator.pushNamed(context, '/services', arguments: job);
  }
}
