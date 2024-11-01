import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Routes
import 'package:movemate_staff/configs/routes/app_router.dart';

// Models & Entities
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_time_request.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/models/request/paging_model.dart';

// Controllers & Providers
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/controllers/house_type_controller/house_type_controller.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';

// Widgets
import 'package:movemate_staff/features/job/presentation/widgets/details/action_button.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/address.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/booking_code.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/column.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/infoItem.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/job_details_utils.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/policies.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/priceItem.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/summary.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/update_status_button.dart';
import 'package:movemate_staff/features/job/presentation/widgets/dialog_schedule/schedule_dialog.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/commons/widgets/loading_overlay.dart';

// Hooks & Utils
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/commons/functions/string_utils.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';

@RoutePage()
class JobDetailsScreen extends HookConsumerWidget {
  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  final BookingResponseEntity job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(false);
    final isExpanded1 = useState(false);

    void toggleDropdown() {
      isExpanded.value = !isExpanded.value;
    }

    void toggleDropdown1() {
      isExpanded1.value = !isExpanded1.value;
    }

    final bookingNotifier =
        ref.read(bookingProvider.notifier); // Read the booking notifier

    final Map<String, List<String>> groupedImages =
        getGroupedImages(job.bookingTrackers);

    final statusBooking = job.status.toBookingTypeEnum();
    // Truy cập BookingController
    final houseTypeController = ref.read(houseTypeControllerProvider.notifier);

    final useFetchHouseResult = useFetchObject<HouseEntities>(
      function: (context) =>
          houseTypeController.getHouseDetails(job.houseTypeId, context),
      context: context,
    );

    print(
        "object:  houseTypeState : ${useFetchHouseResult.data?.name.toString()}");
    // Kiểm tra xem danh sách assignments có phần tử nào không
    AssignmentsStatusType? statusAssignment;
    if (job.assignments.isNotEmpty) {
      statusAssignment = job.assignments.first.status.toAssignmentsTypeEnum();
    } else {
      // Gán một giá trị mặc định hoặc xử lý trường hợp không có assignments
      statusAssignment = null;
      print('Warning: Assignments list is empty.');
    }

    final buttonState = statusAssignment != null
        ? ButtonStateManager.getButtonState(statusBooking, statusAssignment)
        : ButtonState(isVisible: false);

    final state = ref.watch(bookingControllerProvider);
    final fetchResult = useFetch<BookingResponseEntity>(
      function: (model, context) => ref
          .read(bookingControllerProvider.notifier)
          .getBookings(model, context),
      initialPagingModel: PagingModel(
        pageSize: 50,
        pageNumber: 2,
      ),
      context: context,
    );

    final statusAsync = ref.watch(orderStatusStreamProvider(job.id.toString()));
    // final statusAsyncAssignment =
    //     ref.watch(orderStatusAssignmentStreamProvider(job.id.toString()));

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

    print("Status  statusAsync  của booking  : $statusAsync");

    print(
        "Status  statusAsyncAssignment  của booking  : $statusAsyncAssignment");

    print("service  của booking  : ${job.bookingDetails.map(
      (e) => (e.type),
    )} ");

    final debounce = useRef<Timer?>(null);
    final statusOrders = statusAsync.when(
      data: (status) => status,
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
    print("object: statusOrders  $statusOrders");
    // useEffect(() {
    //   statusAsync.whenData((status) {
    //     debounce.value?.cancel();
    //     debounce.value = Timer(const Duration(milliseconds: 300), () {
    //       fetchResult.refresh();
    //     });
    //   });
    //   statusAsyncAssignment.whenData((status) {
    //     debounce.value?.cancel();
    //     debounce.value = Timer(const Duration(milliseconds: 300), () {
    //       fetchResult.refresh();
    //     });
    //   });
    //   return () {
    //     debounce.value?.cancel();
    //   };
    // }, [statusAsync, statusAsyncAssignment]);

    return LoadingOverlay(
      isLoading: state.isLoading,
      child: Scaffold(
        appBar: CustomAppBar(
          backgroundColor: AssetsConstants.primaryMain,
          backButtonColor: AssetsConstants.whiteColor,
          showBackButton: true,
          title: "Thông tin đơn hàng #${job.id} ",
          iconSecond: Icons.home_outlined,
          // iconFirst: Icons.refresh,
          onBackButtonPressed: () {
            bookingNotifier.reset();
            Navigator.of(context).pop();
          },
          onCallBackSecond: () {
            final tabsRouter = context.router.root
                .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
            if (tabsRouter != null) {
              tabsRouter.setActiveIndex(0);
              context.router.popUntilRouteWithName(TabViewScreenRoute.name);
            }
          },
          // onCallBackFirst: () => {
          //   fetchResult.refresh(),
          // },
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bọc Column trong Expanded
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Đảm bảo nội dung bắt đầu từ đầu
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: statusAsync.when(
                                data: (status) => Text(
                                  getBookingStatusText(status).statusText,
                                  // status.toString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (err, stack) => Text('Error: $err'),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: statusAsyncAssignment.when(
                                data: (status) => Text(
                                  status.type.toString(),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (err, stack) => Text('Error: $err'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (statusAsync.when(
                                data: (status) => status,
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (err, stack) => Text('Error: $err'),
                              ) ==
                              BookingStatusType.pending &&
                          job.isReviewOnline == false)
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 18.0, left: 10.0),
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => ScheduleDialog(
                                    orderId: job.id.toString(),
                                    onDateTimeSelected:
                                        (DateTime selectedDateTime) async {
                                      final scheduledAt = selectedDateTime;
                                      print('Selected datetime: $scheduledAt');

                                      final reviewerUpdateController = ref.read(
                                          reviewerUpdateControllerProvider
                                              .notifier);

                                      await reviewerUpdateController
                                          .updateCreateScheduleReview(
                                        request: ReviewerTimeRequest(
                                          reviewAt: selectedDateTime,
                                        ),
                                        id: job.id,
                                        context: context,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AssetsConstants.primaryDark,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
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
                        ),

                      if (statusOrders == BookingStatusType.pending &&
                          job.isReviewOnline == true)
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 18.0, left: 10.0),
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors
                                        .white, // Đặt màu nền cho dialog là màu trắng
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: const Text(
                                      'Xác nhận đánh giá',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: const Text(
                                      'Bạn có chắc chắn muốn xác nhận đánh giá trực tuyến?',
                                      textAlign: TextAlign.center,
                                    ),
                                    actionsAlignment: MainAxisAlignment
                                        .center, // Căn giữa các button
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Đóng hộp thoại
                                        },
                                        child: const Text('Hủy'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          // TODO: Thêm logic xử lý khi xác nhận
                                          try {
                                            await ref
                                                .read(
                                                    reviewerUpdateControllerProvider
                                                        .notifier)
                                                .updateReviewerStatus(
                                                  id: job.id,
                                                  context: context,
                                                  request:
                                                      ReviewerStatusRequest(
                                                    status: statusBooking,
                                                  ),
                                                );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                'Đã đến thành công',
                                              )),
                                            );
                                            fetchResult.refresh();
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Cập nhật thất bại: $e')),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AssetsConstants.primaryDark,
                                        ),
                                        child: const Text('Xác nhận'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AssetsConstants.primaryDark,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
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
                        ),
                      //
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Center(
                    child: Container(
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF007bff),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(15),
                            child: const Row(
                              children: [
                                Icon(FontAwesomeIcons.home,
                                    color: Colors.white),
                                SizedBox(width: 10),
                                Text('Thông tin dịch vụ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Loại nhà : ${useFetchHouseResult.data?.name.toString()} ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                buildAddressRow(
                                  Icons.location_on_outlined,
                                  '${job.pickupAddress}',
                                ),
                                const Divider(
                                    height: 12,
                                    color: Colors.grey,
                                    thickness: 1),
                                buildAddressRow(
                                  Icons.location_searching,
                                  '${job.deliveryAddress}',
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildDetailColumn(FontAwesomeIcons.building,
                                        '${job.floorsNumber} tầng'),
                                    buildDetailColumn(FontAwesomeIcons.building,
                                        '${job.roomNumber} phòng'),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                buildPolicies(FontAwesomeIcons.checkCircle,
                                    'Miễn phí đặt lại'),
                                const SizedBox(height: 20),
                                buildPolicies(FontAwesomeIcons.checkCircle,
                                    'Áp dụng chính sách đổi lịch'),
                                const SizedBox(height: 20),
                                buildBookingCode('Mã đặt chỗ', 'FD8UH6'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Thông tin liên hệ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isExpanded.value
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: Colors.black54,
                            ),
                            onPressed: toggleDropdown,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (isExpanded.value) ...[
                        buildInfoItem('Họ và tên', 'NGUYEN VAN ANH'),
                        buildInfoItem('Mã số', '${job.userId}'),
                        buildInfoItem('Số điện thoại', '0900123456'),
                        buildInfoItem('Email', 'nguyenvananh@gmail.com'),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Thông tin hình ảnh',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isExpanded.value
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: Colors.black54,
                            ),
                            onPressed: toggleDropdown1, // Toggle dropdown
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (isExpanded1.value) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (groupedImages.isEmpty)
                                const Center(
                                  child: Text('Không có hình ảnh'),
                                )
                              else
                                ...groupedImages.entries.map((entry) => Section(
                                      title: getDisplayTitle(entry.key),
                                      imageUrls: entry.value,
                                    )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  // margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'chi tiết giá',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...job.bookingDetails
                          .where((detail) => detail.type == "TRUCK")
                          .map((truckDetail) => buildItem(
                                imageUrl:
                                    'https://storage.googleapis.com/a1aa/image/9rjSBLSWxmoedSK8EHEZx3zrEUxndkuAofGOwCAMywzUTWlTA.jpg',
                                title: truckDetail.name ?? 'Xe Tải',
                                description:
                                    truckDetail.description ?? 'Không có mô tả',
                              )),
                      ...job.bookingDetails.map((detail) => buildPriceItem(
                          detail.name ?? 'Dịch vụ không xác định',
                          formatPrice(detail.price))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Tổng',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              job.totalReal.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Ghi chú',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      UpdateStatusButton(job: job),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildItem(
    {required String imageUrl,
    required String title,
    required String description}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Image.network(imageUrl, width: 80, height: 80),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  );
}
