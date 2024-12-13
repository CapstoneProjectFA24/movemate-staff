// Flutter and external packages
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// Routing
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/data/model/request/resource.dart';

// Data models and entities
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/image_data.dart';

// Controllers
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/custom_tab_container.dart';

// Widgets
import 'package:movemate_staff/features/job/presentation/widgets/dialog_schedule/schedule_dialog.dart';
import 'package:movemate_staff/features/job/presentation/widgets/image_button/room_media_section.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';

// Hooks
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';

// Services
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';

// Constants
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class BookingHeaderStatusSection extends HookConsumerWidget {
  final bool isReviewOnline;
  final BookingResponseEntity job;
  final FetchResult<BookingResponseEntity> fetchResult;

  const BookingHeaderStatusSection({
    super.key,
    required this.isReviewOnline,
    required this.job,
    required this.fetchResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final bookingStatus = useBookingStatus(bookingAsync.value, isReviewOnline);

    final isExpanded = useState(false);

    final porters =
        job.assignments.where((e) => e.staffType == "PORTER").toList();
    final drivers =
        job.assignments.where((e) => e.staffType == "DRIVER").toList();

    ref.listen<bool>(refreshDriverList, (_, __) => fetchResult.refresh());
    ref.listen<bool>(refreshPorterList, (_, __) => fetchResult.refresh());
    ref.listen<bool>(refreshJobList, (_, __) => fetchResult.refresh());

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(right: 16.0, left: 16, bottom: 16),
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
              const SizedBox(height: 8),
              _buildTimeline(context, bookingStatus, ref, isExpanded),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: CustomTabContainer(
              bookingId: job.id,
              porterItems: porters,
              driverItems: drivers,
            ),
          ),
          crossFadeState: isExpanded.value
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(String statusMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        statusMessage,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, BookingStatusResult bookingStatus,
      WidgetRef ref, ValueNotifier<bool> isExpanded) {
    final steps = isReviewOnline
        ? _buildOnlineReviewerSteps(bookingStatus, context, ref, isExpanded)
        : _buildOfflineReviewerSteps(bookingStatus, context, ref, isExpanded);

    // Chia steps thành 2 hàng, mỗi hàng tối đa 4 items
    final firstRow = steps.take(4).toList();
    final secondRow = steps.skip(4).toList();

    return Column(
      children: [
        // First row
        _buildTimelineRow(firstRow, true),

        if (secondRow.isNotEmpty) ...[
          const SizedBox(height: 32), // Space between rows
          _buildTimelineRow(secondRow, false),
        ],
      ],
    );
  }

  Widget _buildTimelineRow(List<_TimelineStep> steps, bool isFirstRow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;

        return Expanded(
          child: Row(
            children: [
              // Step indicator
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step.isCompleted
                            ? Colors.orange.withOpacity(0.1)
                            : step.isActive
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.grey.shade100,
                      ),
                      child: Icon(
                        step.isCompleted ? Icons.check : step.icon,
                        size: 16,
                        color: step.isCompleted
                            ? Colors.orange
                            : step.isActive
                                ? Colors.orange
                                : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title and Action button in a row
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4, // horizontal space between items
                          runSpacing: 4, // vertical space between lines
                          children: [
                            // Title
                            Text(
                              step.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: step.isCompleted
                                    ? Colors.orange
                                    : step.isActive
                                        ? Colors.orangeAccent
                                        : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // Action button
                            if (step.action != null)
                              SizedBox(
                                height: 26,
                                width: step.action!.length * 9.0,
                                child: TextButton(
                                  onPressed: step.onPressed,
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor:
                                        Colors.orange.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    step.action!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (index < steps.length - 1)
                SizedBox(
                  width: 20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 2,
                        color: step.isCompleted
                            ? Colors.orange
                            : Colors.grey.shade300,
                      ),
                      if (!isFirstRow)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: step.isCompleted
                                ? Colors.orange
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<_TimelineStep> _buildOnlineReviewerSteps(BookingStatusResult status,
      BuildContext context, WidgetRef ref, ValueNotifier<bool> isExpanded) {
    bool isStepCompleted(int currentStep, List<bool> conditions) {
      for (int i = currentStep; i < conditions.length; i++) {
        if (conditions[i]) return true;
      }
      return false;
    }

    final progressionStates = [
      status.canConfirmReview,
      status.canUpdateServices,
      status.canConfirmSuggestion,
      status.isReviewed,
      status.isWaitingPayment,
      status.isReviewed,
      status.isBookingComing || status.isInProgress || status.isConfirmed,
      status.isCompleted,
    ];

    return [
      _TimelineStep(
        title: 'Phân công',
        icon: Icons.assignment_ind,
        isActive: status.canConfirmReview,
        isCompleted: isStepCompleted(1, progressionStates),
        action: status.canConfirmReview ? 'Xác nhận' : null,
        onPressed: status.canConfirmReview
            ? () => _confirmReviewAssignment(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Cập nhật',
        icon: Icons.edit,
        isActive: status.canUpdateServices,
        isCompleted: isStepCompleted(2, progressionStates),
        action: status.canUpdateServices ? 'Cập nhật' : null,
        onPressed: status.canUpdateServices
            ? () => _confirmUpdate(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Đề xuất',
        icon: Icons.description,
        isActive: status.canConfirmSuggestion,
        isCompleted: isStepCompleted(3, progressionStates),
        action: status.canConfirmSuggestion ? 'Hoàn thành' : null,
        onPressed: status.canConfirmSuggestion
            ? () => _completeProposal(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Đã đánh giá ',
        icon: Icons.rate_review,
        isActive: status.isReviewed,
        isCompleted: isStepCompleted(4, progressionStates),
      ),
      _TimelineStep(
        title: 'Chờ khách',
        icon: Icons.payment,
        isActive: status.isWaitingPayment,
        isCompleted: isStepCompleted(5, progressionStates),
      ),
      _TimelineStep(
        title: 'Tiến trình',
        icon: Icons.cleaning_services,
        isActive: status.isBookingComing ||
            status.isInProgress ||
            status.isConfirmed && !status.isCompleted,
        isCompleted: isStepCompleted(6, progressionStates),
        action:
            status.isBookingComing || status.isInProgress || status.isConfirmed
                ? (isExpanded.value ? 'Thu gọn' : 'Mở rộng')
                : null,
        onPressed:
            status.isBookingComing || status.isInProgress || status.isConfirmed
                ? () => isExpanded.value = !isExpanded.value
                : null,
      ),
      _TimelineStep(
        title: 'Hoàn tất',
        icon: Icons.check_circle,
        isActive: status.isCompleted,
        isCompleted: false,
      ),
    ];
  }

  List<_TimelineStep> _buildOfflineReviewerSteps(BookingStatusResult status,
      BuildContext context, WidgetRef ref, ValueNotifier<bool> isExpanded) {
    bool isStepCompleted(int currentStep, List<bool> conditions) {
      for (int i = currentStep; i < conditions.length; i++) {
        if (conditions[i]) return true;
      }
      return false;
    }

    final progressionStates = [
      status.canCreateSchedule,
      status.isWaitingCustomer || status.isWaitingPayment,
      status.canConfirmMoving,
      status.isStaffEnroute,
      status.canUpdateServices,
      status.canConfirmSuggestion,
      status.isReviewed,
      status.isBookingComing,
      status.isBookingComing || status.isInProgress || status.isConfirmed,
      status.isCompleted,
    ];

    return [
      _TimelineStep(
        title: 'Xếp lịch',
        icon: Icons.calendar_today,
        isActive: status.canCreateSchedule,
        isCompleted: isStepCompleted(1, progressionStates),
        action: status.canCreateSchedule ? 'Hẹn khách' : null,
        onPressed: status.canCreateSchedule
            ? () => _showScheduleDialog(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Chờ khách',
        icon: Icons.people,
        isActive: status.isWaitingCustomer || status.isWaitingPayment,
        isCompleted: isStepCompleted(2, progressionStates),
      ),
      _TimelineStep(
        title: 'Di chuyển',
        icon: Icons.directions_car,
        isActive: status.canConfirmMoving,
        isCompleted: isStepCompleted(3, progressionStates),
        action: status.canConfirmMoving ? 'Bắt đầu' : null,
        onPressed: status.canConfirmMoving
            ? () => _confirmMoving(context, ref, status)
            : null,
      ),
      _TimelineStep(
        title: 'Đang đến',
        icon: Icons.near_me,
        isActive: status.isStaffEnroute,
        isCompleted: isStepCompleted(4, progressionStates),
        action: status.canConfirmArrival ? 'Đã tới' : null,
        onPressed: status.canConfirmArrival
            ? () => _confirmArrival(context, ref, status)
            : null,
      ),
      _TimelineStep(
        title: 'Cập nhật dịch vụ',
        icon: Icons.edit,
        isActive: status.canUpdateServices,
        isCompleted: isStepCompleted(5, progressionStates),
        action: status.canUpdateServices ? 'Cập nhật' : null,
        onPressed: status.canUpdateServices
            ? () => _confirmUpdate(context, ref)
            // ? () => _navigateToServiceUpdate(context, ref)
            : null,
      ),
      _TimelineStep(
        title: 'Đề xuất',
        icon: Icons.description,
        isActive: status.canConfirmSuggestion,
        isCompleted: isStepCompleted(6, progressionStates),
        action: status.canConfirmSuggestion ? 'Hoàn thành' : null,
        onPressed: status.canConfirmSuggestion
            ? () => _completeProposal(context, ref)
            : null,
      ),
      // _TimelineStep(
      //   title: 'Tiến trình',
      //   icon: Icons.cleaning_services,
      //   isActive: status.isInProgress,
      //   isCompleted: isStepCompleted(7, progressionStates),
      //   action: status.isBookingComing ? 'Đang đợi' : null,
      //   onPressed: status.canConfirmSuggestion ? () => {} : null,
      // ),

      _TimelineStep(
        title: 'Tiến trình',
        icon: Icons.cleaning_services,
        isActive: status.isBookingComing ||
            status.isInProgress ||
            status.isConfirmed && !status.isCompleted,
        isCompleted: isStepCompleted(7, progressionStates),
        action:
            status.isBookingComing || status.isInProgress || status.isConfirmed
                ? (isExpanded.value ? 'Thu gọn' : 'Mở rộng')
                : null,
        onPressed:
            status.isBookingComing || status.isInProgress || status.isConfirmed
                ? () => isExpanded.value = !isExpanded.value
                : null,
      ),
      _TimelineStep(
        title: 'Hoàn tất',
        icon: Icons.check_circle,
        isActive: status.isCompleted,
        isCompleted: false,
      ),
    ];
  }

  void _showScheduleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        orderId: job.id.toString(),
        bookingAt: job.bookingAt,
        onDateTimeSelected: (DateTime selectedDateTime) async {
          await ref
              .read(reviewerUpdateControllerProvider.notifier)
              .updateCreateScheduleReview(
                request: ReviewerTimeRequest(
                  reviewAt: selectedDateTime,
                ),
                id: job.id,
                context: context,
              );
          fetchResult.refresh();
        },
      ),
    );
  }

  void _confirmReviewAssignment(BuildContext context, WidgetRef ref) =>
      _confirmAction(
          context, ref, "Xác nhận đánh giá", "Xác nhận", job.id.toString());
  void _confirmMoving(
          BuildContext context, WidgetRef ref, BookingStatusResult status) =>
      _confirmOpenMap(context, ref, "Bắt đầu di chuyển", "Mở bản đồ",
          job.id.toString(), status, job);
  void _confirmArrival(
          BuildContext context, WidgetRef ref, BookingStatusResult status) =>
      _confirmOpenMap(context, ref, "Xác nhận đã tới", "Đã tới",
          job.id.toString(), status, job);
  void _confirmUpdate(BuildContext context, WidgetRef ref) =>
      _confirmActionUpdate(
          context, ref, "Xác nhận cập nhật", "Cập nhật mới", job.id.toString());

  void _confirmOpenMap(
      BuildContext context,
      WidgetRef ref,
      String title,
      String action,
      String jobId,
      BookingStatusResult status,
      BookingResponseEntity job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        backgroundColor: AssetsConstants.whiteColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const LabelText(
                content: "Đóng",
                size: 16,
                fontWeight: FontWeight.bold,
                color: AssetsConstants.blackColor),
          ),
          TextButton(
            onPressed: () {
              context.router.push(ReviewerMovingScreenRoute(
                  job: job, bookingStatus: status, ref: ref));
              Navigator.pop(context);
              // await ref
              //     .read(reviewerUpdateControllerProvider.notifier)
              //     .updateReviewerStatus(id: job.id, context: context);
              // fetchResult.refresh();
              // Navigator.pop(context);
            },
            child: LabelText(
                content: action,
                size: 16,
                fontWeight: FontWeight.bold,
                color: AssetsConstants.primaryLight),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, WidgetRef ref, String title,
      String action, String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        backgroundColor: AssetsConstants.whiteColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const LabelText(
                content: "Đóng",
                size: 16,
                fontWeight: FontWeight.bold,
                color: AssetsConstants.blackColor),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              print("log here go");
              await ref
                  .read(reviewerUpdateControllerProvider.notifier)
                  .updateReviewerStatus(id: job.id, context: context);
              fetchResult.refresh();
              // Navigator.pop(context);
            },
            child: LabelText(
                content: action,
                size: 16,
                fontWeight: FontWeight.bold,
                color: AssetsConstants.primaryLight),
          ),
        ],
      ),
    );
  }

  void _confirmActionUpdate(BuildContext context, WidgetRef ref, String title,
      String action, String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        backgroundColor: AssetsConstants.whiteColor,
        actions: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => {
                    Navigator.pop(context),
                    _completeProposal(context, ref),
                  },
                  child: const LabelText(
                      content: "Đề xuất",
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: AssetsConstants.blackColor),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    context.router.push(GenerateNewJobScreenRoute(job: job));
                  },
                  child: LabelText(
                      content: action,
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: AssetsConstants.primaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToServiceUpdate(BuildContext context, WidgetRef ref) {
    context.router.push(GenerateNewJobScreenRoute(job: job));
  }

  void _completeProposal(BuildContext context, WidgetRef ref) {
    final timeController = TextEditingController();
    final timeTypeNotifier = ValueNotifier<String>('hour');

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.orange,
        elevation: 0,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width *
                0.95, // Chiều rộng 95% màn hình
            maxHeight: MediaQuery.of(context).size.height *
                0.9, // Chiều cao 90% màn hình
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Type Selection
                      ValueListenableBuilder(
                        valueListenable: timeTypeNotifier,
                        builder: (context, timeType, child) => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: ['hour', 'minute'].map((type) {
                              final selected = timeType == type;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    timeTypeNotifier.value = type;
                                    timeController.clear();
                                  },
                                  child: Container(
                                    height: 40,
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AssetsConstants.primaryLighter
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        type == 'hour' ? 'Giờ' : 'Phút',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selected
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Time Input Field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: timeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Thời gian dự kiến',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: timeTypeNotifier.value == 'hour'
                                ? 'Giờ'
                                : 'Phút',
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.schedule_rounded,
                                color: AssetsConstants.primaryLighter,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      if (!isReviewOnline)
                        // Room Media Section
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AssetsConstants.primaryLighter
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.add_photo_alternate_rounded,
                                      color: AssetsConstants.primaryLighter,
                                    ),
                                  ),
                                  const Text(
                                    'Tải ảnh lên',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const RoomMediaSection(
                                roomTitle: '',
                                roomType: RoomType.livingRoom,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                "Đóng",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                final inputTime =
                                    double.tryParse(timeController.text);
                                if (inputTime == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Vui lòng nhập thời gian hợp lệ'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final estimatedTime =
                                    timeTypeNotifier.value == 'minute'
                                        ? inputTime / 60
                                        : inputTime;

                                final images =
                                    ref.read(bookingProvider).livingRoomImages;

                                List<Resource> convertImage(
                                    List<ImageData>? images) {
                                  return images!
                                      .map((image) => Resource(
                                            type: 'IMG',
                                            resourceUrl: image.url,
                                            resourceCode: 'LIVING_ROOM',
                                          ))
                                      .toList();
                                }

                                final resourceListReq = convertImage(images);
                                await ref
                                    .read(reviewerUpdateControllerProvider
                                        .notifier)
                                    .updateReviewerStatus(
                                      id: job.id,
                                      context: context,
                                      request: ReviewerStatusRequest(
                                        estimatedDeliveryTime: estimatedTime,
                                        resourceList: resourceListReq,
                                      ),
                                    );
                                fetchResult.refresh();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AssetsConstants.primaryLighter,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Xác nhận",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

//
//
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
