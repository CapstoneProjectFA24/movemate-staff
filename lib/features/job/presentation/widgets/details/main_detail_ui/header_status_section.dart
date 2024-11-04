import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_route/auto_route.dart';
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
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

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
        isCompleted: !status.canConfirmReview &&
            (status.canUpdateServices ||
                status.canConfirmSuggestion ||
                status.isReviewed),
        action: status.canConfirmReview ? 'Xác nhận' : null,
        onPressed: status.canConfirmReview
            ? () => _confirmReviewAssignment(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Cập nhật dịch vụ',
        icon: Icons.edit,
        isActive: status.canUpdateServices,
        isCompleted: !status.canUpdateServices &&
            (status.canConfirmSuggestion || status.isReviewed),
        action: status.canUpdateServices ? 'Cập nhật' : null,
        onPressed: status.canUpdateServices
            ? () => _navigateToServiceUpdate(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Đề xuất',
        icon: Icons.description,
        isActive: status.canConfirmSuggestion,
        isCompleted: !status.canConfirmSuggestion && status.isReviewed,
        action: status.canConfirmSuggestion ? 'Hoàn thành' : null,
        onPressed: status.canConfirmSuggestion
            ? () => _completeProposal(context, ref)
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
            !status.canCreateSchedule,
      ),
      _TimelineStep(
        title: 'Di chuyển',
        icon: Icons.directions_car,
        isActive: status.canConfirmMoving,
        isCompleted: status.isStaffEnroute ||
            status.isStaffArrived ||
            status.isSuggested ||
            status.isReviewed,
        action: status.canConfirmMoving ? 'Bắt đầu' : null,
        onPressed:
            status.canConfirmMoving ? () => _confirmMoving(context, ref) : null,
      ),
      _TimelineStep(
        title: 'Đang đến',
        icon: Icons.near_me,
        isActive: status.isStaffEnroute,
        isCompleted:
            status.isStaffArrived || status.isSuggested || status.isReviewed,
        action: status.canConfirmArrival ? 'Đã tới' : null,
        onPressed: status.canConfirmArrival
            ? () => _confirmArrival(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Cập nhật dịch vụ',
        icon: Icons.edit,
        isActive: status.canUpdateServices,
        isCompleted: status.isSuggested || status.isReviewed,
        action: status.canUpdateServices ? 'Cập nhật' : null,
        onPressed: status.canUpdateServices
            ? () => _navigateToServiceUpdate(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Đề xuất',
        icon: Icons.description,
        isActive: status.canConfirmSuggestion,
        isCompleted: !status.canConfirmSuggestion && status.isReviewed,
        action: status.canConfirmSuggestion ? 'Hoàn thành' : null,
        onPressed: status.canConfirmSuggestion
            ? () => _completeProposal(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Hoàn tất',
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

  // Dialog and navigation methods -- done
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

  void _confirmReviewAssignment(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đánh giá'),
        content: const Text('Vui lòng bấm xác nhận '),
        backgroundColor: AssetsConstants.whiteColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const LabelText(
              content: "Đóng",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.blackColor,
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(reviewerUpdateControllerProvider.notifier)
                    .updateReviewerStatus(id: job.id, context: context);
                fetchResult.refresh();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (error) {
                print("Error updating reviewer status: $error");
              }
            },
            child: const LabelText(
              content: "Xác nhận",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // done
  void _confirmMoving(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bắt đầu di chuyển'),
        content: const Text('Bạn có chắc là bắt đầu chưa'),
        backgroundColor: AssetsConstants.whiteColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const LabelText(
              content: "Đóng",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.blackColor,
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(reviewerUpdateControllerProvider.notifier)
                    .updateReviewerStatus(id: job.id, context: context);
                fetchResult.refresh();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (error) {
                print("Error updating reviewer status: $error");
              }
            },
            child: const LabelText(
              content: "Xác nhận",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // done
  void _confirmArrival(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đã tới'),
        content: const Text('Bạn có chắc là tới nơi chưa'),
        backgroundColor: AssetsConstants.whiteColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const LabelText(
              content: "Đóng",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.blackColor,
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(reviewerUpdateControllerProvider.notifier)
                    .updateReviewerStatus(id: job.id, context: context);
                fetchResult.refresh();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (error) {
                print("Error updating reviewer status: $error");
              }
            },
            child: const LabelText(
              content: "Xác nhận",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToServiceUpdate(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bạn có muốn cập nhật dịch không'),
        content:
            const Text('Vui lòng qua trang cập nhật danh sách dịch vụ nếu cần'),
        backgroundColor: AssetsConstants.whiteColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const LabelText(
              content: "Đóng",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.blackColor,
            ),
          ),
          TextButton(
            onPressed: () {
              context.router.push(
                GenerateNewJobScreenRoute(job: job),
              );
            },
            child: const LabelText(
              content: "Cập nhật dịch vụ",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // need fix the resourses list image to complete
  void _completeProposal(BuildContext context, WidgetRef ref) {
    final TextEditingController timeController = TextEditingController();
    final timeTypeNotifier = ValueNotifier<String>('hour');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Xác nhận đề suất cho khách hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Xác nhận để hoàn thành tiến trình đánh giá',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Radio buttons for selecting hour or minute
            ValueListenableBuilder(
              valueListenable: timeTypeNotifier,
              builder: (context, timeType, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Giờ" Button
                  Expanded(
                    child: Container(
                      height: 40, // Compact height
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: timeType == 'hour'
                            ? AssetsConstants.primaryLighter.withOpacity(0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: timeType == 'hour'
                              ? AssetsConstants.primaryLighter
                              : Colors.grey,
                          width: 1.2,
                        ),
                      ),
                      child: RadioListTile<String>(
                        title: Text(
                          'Giờ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: timeType == 'hour'
                                ? AssetsConstants.primaryLighter
                                : Colors.grey,
                          ),
                        ),
                        value: 'hour',
                        groupValue: timeType,
                        onChanged: (value) {
                          timeTypeNotifier.value = value!;
                          timeController.clear();
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: AssetsConstants.primaryLighter,
                      ),
                    ),
                  ),
                  // "Phút" Button
                  Expanded(
                    child: Container(
                      height: 40, // Compact height
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: timeType == 'minute'
                            ? AssetsConstants.primaryLighter.withOpacity(0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: timeType == 'minute'
                              ? AssetsConstants.primaryLighter
                              : Colors.grey,
                          width: 1.2,
                        ),
                      ),
                      child: RadioListTile<String>(
                        title: Text(
                          'Phút',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: timeType == 'minute'
                                ? AssetsConstants.primaryLighter
                                : Colors.grey,
                          ),
                        ),
                        value: 'minute',
                        groupValue: timeType,
                        onChanged: (value) {
                          timeTypeNotifier.value = value!;
                          timeController.clear();
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: AssetsConstants.primaryLighter,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Input field with dynamic label
            ValueListenableBuilder(
              valueListenable: timeTypeNotifier,
              builder: (context, timeType, child) => TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'Thời gian dự kiến (${timeType == 'hour' ? 'giờ' : 'phút'})',
                  hintText: 'Nhập thời gian dự kiến',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AssetsConstants.primaryLighter,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelStyle: TextStyle(
                    color: timeController.text.isNotEmpty
                        ? AssetsConstants.primaryLighter
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AssetsConstants.whiteColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const LabelText(
              content: "Đóng",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.blackColor,
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final double? inputTime = double.tryParse(timeController.text);

                if (inputTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập thời gian hợp lệ'),
                    ),
                  );
                  return;
                }

                final double estimatedTime = timeTypeNotifier.value == 'minute'
                    ? inputTime / 60
                    : inputTime;

                final request = ReviewerStatusRequest(
                  estimatedDeliveryTime: estimatedTime,
                );

                await ref
                    .read(reviewerUpdateControllerProvider.notifier)
                    .updateReviewerStatus(
                      id: job.id,
                      context: context,
                      request: request,
                    );
                fetchResult.refresh();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (error) {
                print("Error updating reviewer status: $error");
              }
            },
            child: const LabelText(
              content: "Xác nhận",
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryLight,
            ),
          ),
        ],
      ),
    );
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
