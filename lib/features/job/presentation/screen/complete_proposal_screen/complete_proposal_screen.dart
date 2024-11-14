// booking_screen_service.dart
import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/data/model/request/booking_requesst.dart';
import 'package:movemate_staff/features/job/data/model/request/resource.dart';
import 'package:movemate_staff/features/job/data/model/request/reviewer_status_request.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_details_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/image_data.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/screen/job_details_screen/job_details_screen.dart';
import 'package:movemate_staff/features/job/presentation/screen/select_services_screen/service_package_tile.dart';
import 'package:movemate_staff/features/job/presentation/widgets/button_next/summary_section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/image_button/room_media_section.dart';
//entity

//hook & extentions
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

@RoutePage()
class CompleteProposalScreen extends HookConsumerWidget {
  final FetchResult<BookingResponseEntity> fetchResult;

  const CompleteProposalScreen({
    super.key,
    required this.job,
    required this.fetchResult,
  });

  final BookingResponseEntity job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Các biến trạng thái cần thiết
    final size = MediaQuery.sizeOf(context);
    final scrollController = useScrollController();
    final bookingState = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    final state = ref.watch(bookingControllerProvider);
    final double price = bookingState.totalPrice;

    // Trạng thái để hiển thị phần xác nhận trực tiếp trên màn hình
    final timeController = useTextEditingController();
    final timeTypeNotifier = useState<String>('hour');
    final images = ref.watch(bookingProvider).livingRoomImages;

    // Hàm để chuyển đổi list ImageData thành list Resource
    List<Resource> convertImage(List<ImageData>? images) {
      return images!
          .map((image) => Resource(
                type: 'IMG',
                resourceUrl: image.url,
                resourceCode: 'LIVING_ROOM',
              ))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin xác nhận'),
        backgroundColor: AssetsConstants.primaryMain,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nội dung chính của trang
            if (state.isLoading && fetchResult.items.isEmpty)
              const Center(
                child: HomeShimmer(amount: 4),
              )
            else if (fetchResult.items.isEmpty)
              const Align(
                alignment: Alignment.topCenter,
                child: EmptyBox(title: 'Không có dịch vụ nào'),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chọn thời gian",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Phần chọn thời gian
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

                  // Time Input Field with floating label
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
                        hintText:
                            timeTypeNotifier.value == 'hour' ? 'Giờ' : 'Phút',
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

                  const SizedBox(height: 16),

                  // Phần chụp ảnh
                  const Text(
                    "Chụp ảnh",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                color: AssetsConstants.primaryLighter,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Tải ảnh lên',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
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

                  // Các dịch vụ khác (nếu có)
                  // Bạn có thể thêm các phần khác tại đây
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SummarySection(
          buttonIcon: false,
          isButtonEnabled: true,
          onPlacePress: () async {
            final bookingRequest =
                BookingUpdateRequest.fromBookingUpdate(bookingState);
            final bookingstate = ref.watch(bookingProvider);
            final bookingNotifier = ref.read(bookingProvider.notifier);
            final inputTime = double.tryParse(timeController.text);

            // Cập nhật thời gian vào bookingNotifier
            bookingNotifier.updateEstimatedDeliveryTime(inputTime.toString());
            if (inputTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 12),
                        Text('Vui lòng nhập thời gian hợp lệ'),
                      ],
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              return;
            }

            // final estimatedTime =
            //     timeTypeNotifier.value == 'minute' ? inputTime / 60 : inputTime;

            // final resourseListReq = convertImage(images);

            // print("check time estimatedTime $estimatedTime");
            // print("check img resourseListReq $resourseListReq");

            // print(
            //     'tuan Booking bookingstate pickUpLocation service: ${jsonEncode(bookingstate.pickUpLocation)}');
            // print(
            //     'tuan Booking bookingstate dropOffLocation service: ${jsonEncode(bookingstate.dropOffLocation)}');
            print(
                'tuan Booking Request: ${jsonEncode(bookingRequest.toMap())}');
            print(
                'tuan Booking Request image: ${jsonEncode(bookingRequest.resourceList.toString())}');

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xác nhận'),
                content: const Text('Bạn có chắc muốn cập nhật đơn hàng?'),
                backgroundColor:
                    Colors.white, // Set the background color to white
                actions: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Cancel button
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Hủy',
                            style:
                                TextStyle(color: AssetsConstants.primaryMain),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () async {
                            // Confirm button
                            // Navigator.of(context).pop();
                            final bookingResponse = await ref
                                .read(bookingControllerProvider.notifier)
                                .updateBooking(
                                  context: context,
                                  id: job.id,
                                );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JobDetailsScreen(job: bookingResponse),
                              ),
                            );
                            print("bookingResponse screen $bookingResponse");
                            print("booking id  ${job.id}");
                            final updateReviewerStatusRequest =
                                ReviewerStatusRequest(
                              estimatedDeliveryTime: double.parse(
                                  bookingRequest.estimatedDeliveryTime),
                              resourceList: bookingRequest.resourceList,
                            );
                            // Thực hiện cập nhật booking
                            await ref
                                .read(reviewerUpdateControllerProvider.notifier)
                                .updateReviewerStatus(
                                  context: context,
                                  id: job.id,
                                );

                            print(
                                "object check ${updateReviewerStatusRequest.toJson()} ");
                          
                          },
                          child: const Text(
                            'Xác nhận',
                            style:
                                TextStyle(color: AssetsConstants.primaryMain),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          buttonText: 'Xác nhận cập chính sửa',
          // priceLabel: 'Tổng giá',
        ),
      ),
    );
  }
}
