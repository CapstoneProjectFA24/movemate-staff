// lib/features/job/presentation/widgets/update_status_button.dart

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/screen/generate_new_job_screen/generate_new_job_screen.dart';
import 'package:movemate_staff/features/job/presentation/widgets/button_next/confirmation_button_sheet.dart'
    as confirm_button_sheet;
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';

class UpdateStatusButton extends ConsumerWidget {
  final BookingResponseEntity job;

  const UpdateStatusButton({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Convert booking status to enum
    final statusbookings = job.status.toString().toBookingTypeEnum();
    final statusAsync = ref.watch(orderStatusStreamProvider(job.id.toString()));

    final statusAsyncAssignment = ref
        .watch(orderStatusAssignmentStreamProvider(job.id.toString()))
        .when<AsyncValue<AssignmentsStatusType>>(
          data: (statusList) {
            if (statusList.isEmpty || statusList.first == null) {
              return AsyncValue.data(AssignmentsStatusType
                  .arrived); // Giá trị mặc định nếu list rỗng
            }
            return AsyncValue.data(statusList.first);
          },
          loading: () => const AsyncValue.loading(),
          error: (err, stack) => AsyncValue.error(err, stack),
        );

    // Safely retrieve the first assignment's status as enum
    final assignment =
        job.assignments.isNotEmpty ? job.assignments.first : null;

    final AssignmentsStatusType? assignmentStatus =
        statusAsyncAssignment.value?.type.toAssignmentsTypeEnum();

    // Determine button text and action based on conditions
    String? buttonText;
    VoidCallback? onConfirm;

    if (statusAsync.value == BookingStatusType.reviewing &&
        statusAsync.value != BookingStatusType.assigned &&
        statusAsyncAssignment.value != null &&
        job.isReviewOnline == false) {
      switch (assignmentStatus) {
        case AssignmentsStatusType.assigned:
          buttonText = "bắt đầu";
          onConfirm = () async {
            try {
              await ref
                  .read(reviewerUpdateControllerProvider.notifier)
                  .updateReviewerStatus(
                    id: job.id,
                    context: context, // Ensure this enum exists
                    request: ReviewerStatusRequest(
                      status: BookingStatusType.reviewing,
                    ),
                  );
              // Optionally, show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bắt đầu thành công')),
              );
            } catch (e) {
              // Handle the error, e.g., show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cập nhật thất bại: $e')),
              );
            }
          };
          break;

        case AssignmentsStatusType.enroute:
          buttonText = "đã đến";
          onConfirm = () async {
            try {
              await ref
                  .read(reviewerUpdateControllerProvider.notifier)
                  .updateReviewerStatus(
                    id: job.id,
                    context: context, // Ensure this enum exists
                    request: ReviewerStatusRequest(
                      status: BookingStatusType.reviewing,
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đến thành công')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cập nhật thất bại: $e')),
              );
            }
          };
          break;

        case AssignmentsStatusType.suggested:
          buttonText = "kết thúc review";
          onConfirm = () async {
            try {
              await ref
                  .read(reviewerUpdateControllerProvider.notifier)
                  .updateReviewerStatus(
                    id: job.id,
                    context: context, // Ensure this enum exists
                    request: ReviewerStatusRequest(
                      status: BookingStatusType.completed,
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kết thúc review thành công')),
              );
              // chuyển hướng về trang chủ
              context.router.popUntilRoot();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cập nhật thất bại: $e')),
              );
            }
          };
          // onConfirm = () {
          //   context.router.push(
          //     GenerateNewJobScreenRoute(job: job),
          //   );
          // };
          break;

        case AssignmentsStatusType.arrived:
          buttonText = "Cập nhật trạng thái";
          onConfirm = () {
            context.router.push(
              GenerateNewJobScreenRoute(job: job),
            );
          };
          break;

        default:
          // No action for other statuses
          break;
      }
    }
    //
    if (statusAsync.value == BookingStatusType.reviewing &&
        statusAsync.value != BookingStatusType.assigned &&
        statusAsyncAssignment.value?.type != null &&
        job.isReviewOnline == true) {
      switch (assignmentStatus) {
        case AssignmentsStatusType.assigned:
          buttonText = "Đánh giá trực tuyến";
          onConfirm = () {
            context.router.push(
              GenerateNewJobScreenRoute(job: job),
            );
          };
          break;
        case AssignmentsStatusType.suggested:
          buttonText = "Kết thúc review";
          onConfirm = () {
            context.router.push(
              GenerateNewJobScreenRoute(job: job),
            );
          };
          // onConfirm = () async {
          //   try {
          //     await ref
          //         .read(reviewerUpdateControllerProvider.notifier)
          //         .updateReviewerStatus(
          //           id: job.id,
          //           context: context, // Ensure this enum exists
          //           request: ReviewerStatusRequest(
          //             status: BookingStatusType.completed,
          //           ),
          //         );
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Kết thúc review thành công')),
          //     );
          //     // chuyển hướng về trang chủ
          //     context.router.popUntilRoot();
          //   } catch (e) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(content: Text('Cập nhật thất bại: $e')),
          //     );
          //   }
          // };
          break;
        default:
          break;
      }
    }

    if (buttonText != null && onConfirm != null) {
      return ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return confirm_button_sheet.ConfirmationBottomSheet(
                job: job,
                onConfirm: onConfirm,
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9900),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          fixedSize: const Size(400, 50),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return const SizedBox
          .shrink(); // Return empty widget if conditions not met
    }
  }
}
