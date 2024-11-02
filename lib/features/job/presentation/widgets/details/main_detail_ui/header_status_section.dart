import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/widgets/dialog_schedule/schedule_dialog.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/utils/commons/functions/string_utils.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/enums/booking_status_type.dart';

class BookingHeaderStatusSection extends HookConsumerWidget {
  final AsyncValue<BookingStatusType> statusAsync;
  final AsyncValue<AssignmentsStatusType> statusAsyncAssignment;
  final Object statusOrders;
  final bool isReviewOnline;
  final BookingResponseEntity job;
  final FetchResult<BookingResponseEntity> fetchResult;
  final BookingStatusType statusBooking;

  const BookingHeaderStatusSection({
    Key? key,
    required this.statusAsync,
    required this.statusAsyncAssignment,
    required this.statusOrders,
    required this.isReviewOnline,
    required this.job,
    required this.fetchResult,
    required this.statusBooking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: statusAsync.when(
                    data: (status) => Text(
                      getBookingStatusText(status).statusText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: statusAsyncAssignment.when(
                    data: (status) => Text(
                      status.type.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                ),
              ],
            ),
          ),
          if (statusAsync.when(
                data: (status) => status,
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error: $err'),
              ) == BookingStatusType.pending &&
              !isReviewOnline)
            buildScheduleButton(context, ref),
          if (statusOrders == BookingStatusType.pending && isReviewOnline)
            buildConfirmButton(context, ref),
        ],
      ),
    );
  }

  Widget buildScheduleButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 18.0, left: 10.0),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () {
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
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AssetsConstants.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const LabelText(
            content: "Tạo lịch hẹn",
            size: 16,
            fontWeight: FontWeight.bold,
            color: AssetsConstants.whiteColor,
          ),
        ),
      ),
    );
  }

  Widget buildConfirmButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 18.0, left: 10.0),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text(
                  'Xác nhận đánh giá',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'Bạn có chắc chắn muốn xác nhận đánh giá trực tuyến?',
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
                        await ref
                            .read(reviewerUpdateControllerProvider.notifier)
                            .updateReviewerStatus(
                              id: job.id,
                              context: context,
                              request: ReviewerStatusRequest(
                                status: statusBooking,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã đến thành công')),
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
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AssetsConstants.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const LabelText(
            content: "Xác nhận đánh giá",
            size: 16,
            fontWeight: FontWeight.bold,
            color: AssetsConstants.whiteColor,
          ),
        ),
      ),
    );
  }
}
