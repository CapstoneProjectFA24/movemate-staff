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
    // Sử dụng hook `useBookingStatus` để lấy thông tin trạng thái booking
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final bookingStatus = useBookingStatus(bookingAsync.value, isReviewOnline);
  
    // final statusBooking = job.status.;
    
    return Padding(
      padding: const EdgeInsets.only(left: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị trạng thái booking từ hook
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    bookingStatus.statusMessage,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Trạng thái chi tiết (nếu cần thiết)
                if (bookingStatus.isWaitingForPayment)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Đang chờ khách hàng thanh toán',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
          if (bookingStatus.canCreateSchedule) buildScheduleButton(context, ref),
          if (bookingStatus.isCompleted) buildConfirmButton(context, ref),
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
                        // await ref
                        //     .read(reviewerUpdateControllerProvider.notifier)
                        //     .updateReviewerStatus(
                        //       id: job.id,
                        //       context: context,
                        //       request: ReviewerStatusRequest(
                        //         status: job.status as BookingStatusType,
                        //       ),
                        //     );
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
