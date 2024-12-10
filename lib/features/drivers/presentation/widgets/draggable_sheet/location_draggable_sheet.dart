import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // Import for hooks
import 'package:intl/intl.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_details_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/house_type_controller/house_type_controller.dart';
import 'package:movemate_staff/features/profile/domain/entities/profile_entity.dart';
import 'package:movemate_staff/features/profile/presentation/controllers/profile_controller/profile_controller.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/services/realtime_service/booking_realtime_entity/booking_realtime_entity.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';
import 'package:movemate_staff/utils/commons/widgets/loading_overlay.dart';

class DeliveryDetailsBottomSheet extends HookConsumerWidget {
  final BookingResponseEntity job;
  final int? userId;
  const DeliveryDetailsBottomSheet(
      {super.key, required this.job, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final bookingStatus =
        useBookingStatus(bookingAsync.value, job.isReviewOnline);
    final state = ref.watch(houseTypeControllerProvider);

    print("vinh status ${bookingStatus.driverStatusMessage}");
    print("vinh status ${bookingStatus.isDriverMoving}");

    // Show 'Credit Booking' only if isCredit is true

    final bookingControllerHouse =
        ref.read(houseTypeControllerProvider.notifier);

    // Sử dụng useFetchObject để gọi getHouseDetails
    final useFetchResult = useFetchObject<HouseEntities>(
      function: (context) =>
          bookingControllerHouse.getHouseDetails(job.houseTypeId, context),
      context: context,
    );
    final houseTypeById = useFetchResult.data;

    final useFetchUserResult = useFetchObject<ProfileEntity>(
      function: (context) => ref
          .read(profileControllerProvider.notifier)
          .getUserInfo(job.userId, context),
      context: context,
    );
    final userProfileById = useFetchUserResult.data;

// Normal content if isCredit is false
    return LoadingOverlay(
      isLoading: state.isLoading,
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.8,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                _buildDeliveryStatusCard(
                  job: job,
                  status: bookingStatus,
                  bookingAsync: bookingAsync.value,
                  context: context,
                  ref: ref,
                ),
                _buildTrackingInfoCard(
                  job: job,
                  status: bookingStatus,
                  context: context,
                ),
                _buildDetailsSheet(
                  context: context,
                  job: job,
                  houseTypeById: houseTypeById,
                  profile: userProfileById,
                  status: bookingStatus,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showConfirmModal(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.white, // Keep the background white for contrast
          title: const Text(
            'Xác nhận đã nhận tiền mặt',
            style: TextStyle(
              color: Colors.green, // Set title color to blue for emphasis
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn đã nhận tiền mặt cho đơn này?',
            style: TextStyle(
              color: Colors.black87, // Slightly softer color for content text
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            //button hủy
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Colors.orange, // Orange background for the Cancel button
                iconColor: Colors.white, // White text on the orange button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // Rounded corners for the button
                ),
              ),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            //button: xác nhận
            TextButton(
              onPressed: () async {
                // Handle confirm action here
                Navigator.pop(context); // Close the dialog
                await ref
                    .read(driverControllerProvider.notifier)
                    .driverConfirmCashPayment(context: context, id: id);

                // final tabsRouter = context.router.root
                //     .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
                // if (tabsRouter != null) {
                //   tabsRouter.setActiveIndex(0);
                //   context.router.popUntilRouteWithName(TabViewScreenRoute.name);
                // } else {
                //   context.router.replaceAll([
                //     const TabViewScreenRoute(children: [HomeScreenRoute()]),
                //   ]);
                // }
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Colors.green, // Blue background for the Confirm button
                iconColor: Colors.white, // White text on the blue button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // Rounded corners for the button
                ),
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeliveryStatusCard({
    required BookingResponseEntity job,
    required BookingStatusResult status,
    required BookingRealtimeEntity? bookingAsync,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final dateParts = job.bookingAt.split(' ')[0].split('/');
    final timeParts = job.bookingAt.split(' ')[1].split(':');
    final month = dateParts[0];
    final day = dateParts[1];
    final year = dateParts[2];
    final hour = timeParts[0];
    final minute = timeParts[1];

    // Tạo chuỗi định dạng
    final formattedBookingAt = '$hour:$minute $day/$month/$year';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Thời gian dự kiến $formattedBookingAt',
                  style: TextStyle(
                    fontSize: bookingAsync?.isCredit == null
                        ? 14
                        : (bookingAsync!.isCredit! ? 12 : 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (bookingAsync?.isCredit == true && !status.isCompleted)
                  Positioned(
                    top: 16,
                    right: 25,
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.credit_card, color: Colors.green),
                          onPressed: () {
                            _showConfirmModal(context, ref, job.id);
                          },
                        ),
                        const FittedBox(
                          child: Text(
                            'Nhận tiền mặt',
                            style: const TextStyle(
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
                //coming
                //inProgress
                //completed
                children: [
                  if (status.isBookingComing == true) ...[
                    _buildProgressDot(true),
                    _buildProgressLine(false),
                    _buildProgressDot(false),
                    _buildProgressLine(false),
                    _buildProgressDot(false),
                  ],
                  if (status.isInProgress == true) ...[
                    _buildProgressDot(true),
                    _buildProgressLine(true),
                    _buildProgressDot(true),
                    _buildProgressLine(false),
                    _buildProgressDot(false),
                  ],
                  if (status.isCompleted == true) ...[
                    _buildProgressDot(true),
                    _buildProgressLine(true),
                    _buildProgressDot(true),
                    _buildProgressLine(true),
                    _buildProgressDot(true),
                  ],
                ]),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sẵn sàng'),
                Text('Đang trong tiến trình'),
                Text('Hoàn tất'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInfoCard(
      {required BookingResponseEntity job,
      required BookingStatusResult status,
      required BuildContext context}) {
    // print("check status ${bookingStatus.statusMessage}");
    //PORTER
    //REVIEWER
    String getDriverRole() {
      try {
        final isResponsible = job.assignments
            .firstWhere((e) => e.staffType == 'DRIVER')
            .isResponsible;

        return isResponsible == true ? "Trưởng" : "Nhân viên";
      } catch (e) {
        return "Bốc vác"; // Giá trị mặc định nếu không tìm thấy Driver
      }
    }

    // print("check status ${getDriverRole()}");
    // print(
    //     "check status: ${status.driverStatusMessage?.contains('-') == true ? status.driverStatusMessage?.split('-')[1].trim() : status.driverStatusMessage ?? ''}");

    print(
        "check status ConfirmIncoming  ${status.canDriverConfirmIncoming.toString()}");
    print("check status StartMoving ${status.canDriverStartMoving.toString()}");
    print(
        "check status ConfirmArrived ${status.canDriverConfirmArrived.toString()}");
    print(
        "check statusCompleteDelivery${status.canDriverCompleteDelivery.toString()}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Icon(Icons.local_shipping),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tài xế ${getDriverRole()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getDisplayStatus(status),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            // const Spacer(),
            // TextButton(
            //   onPressed: () {},
            //   child: const Text('Sao chép'),
            // ),
          ],
        ),
      ),
    );
  }

  String getDisplayStatus(BookingStatusResult status) {
    return status.driverStatusMessage?.contains('-') == true
        ? status.driverStatusMessage!.split('-')[1].trim()
        : status.driverStatusMessage ?? '';
  }

  Widget _buildDetailsSheet({
    required BuildContext context,
    required BookingResponseEntity job,
    required HouseEntities? houseTypeById,
    required ProfileEntity? profile,
    required BookingStatusResult status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Thông tin dịch vụ'),
                  const SizedBox(height: 16),
                  _buildServiceInfo(job: job, house: houseTypeById),
                  const SizedBox(height: 16),
                  _buildLocationInfo(job: job),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: (job.bookingDetails.length * 25)
                        .toDouble(), // Fixed height for services list
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //TODO: OPTIONAL field for services list have type TRUCK
                          buildServicesList(
                            job.bookingDetails,
                          ), // Hiển thị danh sách
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  _buildSectionTitle('Thông tin khách hàng'),
                  const SizedBox(height: 16),
                  _buildCustomerInfo(profile: profile),
                  const SizedBox(height: 3),
                  _buildConfirmationImageLink(
                      context: context, job: job, status: status),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFFFF7643),
      ),
    );
  }

  Widget _buildServiceInfo(
      {required BookingResponseEntity job, required HouseEntities? house}) {
    // print("check home ${job.userId}");
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loại nhà',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                house?.name ?? '',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Số tầng',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.floorsNumber,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Số phòng',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.roomNumber,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo({required BookingResponseEntity job}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationRow('Từ', job.pickupAddress),
        _buildLocationRow('Đến', job.deliveryAddress),
      ],
    );
  }

  Widget _buildLocationRow(String title, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                address,
                style: const TextStyle(fontSize: 14),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // const SizedBox(width: 12),
            // TextButton(
            //   onPressed: () {},
            //   child: const Text(
            //     'Xem thêm',
            //     style: TextStyle(
            //       color: Color(0xFFFF7643),
            //       fontSize: 14,
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerInfo({required ProfileEntity? profile}) {
    print('check pro ${profile?.name}');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tên khách hàng',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile?.name ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Số điện thoại',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile?.phone ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmationImageLink(
      {required BookingResponseEntity job,
      required BookingStatusResult status,
      required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const PorterConfirmScreen()),
        // );
        context.router.push(DriverConfirmUploadRoute(
          job: job,
        ));
      },
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xem hình ảnh xác nhận',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProgressDot(bool isCompleted) {
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isCompleted ? Colors.orange : Colors.grey[300],
      border: Border.all(
        color: isCompleted ? Colors.orange : Colors.grey[300]!,
        width: 2,
      ),
    ),
    child: isCompleted
        ? const Icon(
            Icons.check,
            size: 12,
            color: Colors.white,
          )
        : null,
  );
}

Widget _buildProgressLine(bool isCompleted) {
  return Expanded(
    child: Container(
      height: 2,
      color: isCompleted ? Colors.orange : Colors.grey[300],
    ),
  );
}

Widget buildPriceItem(String description, String price) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      Row(
        children: [
          const SizedBox(width: 12),
          Text(
            price,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    ],
  );
}

// Hàm hỗ trợ để định dạng giá
String formatPrice(int price) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(price)} đ';
}

Widget buildServicesList(List<BookingDetailsResponseEntity> bookingDetails,
    {bool isFilterByTruck = false}) {
  // Lọc các dịch vụ có type là 'TRUCK'
  // Lọc danh sách nếu cần
  final filteredServices = isFilterByTruck
      ? bookingDetails.where((detail) => detail.type == 'TRUCK').toList()
      : bookingDetails;

  // Trả về danh sách Widget để hiển thị
  return Column(
    children: filteredServices.map((detail) {
      return buildPriceItem(detail.name ?? 'Unknown Service',
          formatPrice(detail.price?.toInt() ?? 0));
    }).toList(),
  );
}
