import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/house_type_controller/house_type_controller.dart';
import 'package:movemate_staff/features/porter/presentation/screens/porter_confirm_upload/porter_confirm_upload.dart';
import 'package:movemate_staff/features/profile/domain/entities/profile_entity.dart';
import 'package:movemate_staff/features/profile/presentation/controllers/profile_controller/profile_controller.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
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
    // Lấy các thông tin từ widget
    // final status = job.status;
    // final assignment = job.assignments.firstWhere(
    //   (e) => e.userId == userId,
    //   orElse: () => AssignmentsResponseEntity(
    //       id: 0, userId: 0, bookingId: 0, status: '', staffType: ''),
    // );
    // final subStatus = assignment != null ? assignment.status : null;

    //   DRIVER
    // 30p trước thời điểm bookingAt thì nó mới được di chuyển (Nhưng lúc đó chưa chuyển từ COMING -> IN_PROGRESS) && subStatus (ASSIGNED -> INCOMING -> ARRIVED )
// + đầu tiên trạng thái của status là COMING thì sẽ có staffType là DRIVER và subStatus là waiting
// + một action của REVIEWER chọn cập nhật staffType DRIVER và subStatus từ waiting lên assigned  và status vẫn là coming
// + khi sắp tới giờ thì status COMING tự động chuyển thành status IN_PROGRESS
// -> Từ bây h trở đi trạng thái sẽ luôn giữ là status là IN_PROGRESS
// + Khi driver lái xe sắp tới thì (Chỗ này driver 1 action chính để bấm) -> subStatus từ incoming -> arrived (tới nơi để dọn hàng )
// + Khi driver dọn hàng lên xe và di chuyển (Chỗ này driver 1 action chính để bấm) -> subStatus từ arrived -> inprogress (dag trong quá trình di chuyển)
// + khi driver đã tới nơi để trả hàng thì kết thúc tiến trình chuyển (Chỗ này driver 1 action chính để bấm) -> inprogress -> completed

// disable -> flag bool chụp lần 1, chụp lần 2

    // final bookingAt = widget.job.bookingAt;
    // print("vinh test 3 ${subStatus}");
    // // Xác định thời gian và điều kiện

    // final now = DateTime.now();
    // final format = DateFormat("MM/dd/yyyy HH:mm:ss");
    // final bookingDateTime = format.parse(bookingAt);
    // final isValidDate = now.difference(bookingDateTime).inMinutes >= 30;

    // // Xác định các điều kiện hành động
    // final isPendingNotAction =
    //     status == "COMING" && subStatus == "WAITING" || subStatus == "ASSIGNED";

    // final canStartMoving = (status == "COMING" && subStatus == "ASSIGNED") ||
    //     (status == "IN_PROGRESS" && subStatus == "ARRIVED") ||
    //     (status == "IN_PROGRESS" && subStatus == "IN_PROGRESS") && !isValidDate;

    // final canFinishMoving =
    //     status == "IN_PROGRESS" && subStatus == "IN_PROGRESS";

    // print("vinh log 1 : ${isPendingNotAction}");
    // print("vinh log 2 : ${canStartMoving}");
    // print("vinh log 3 : ${canFinishMoving}");

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
                _buildDeliveryStatusCard(),
                _buildTrackingInfoCard(),
                _buildDetailsSheet(
                    context: context,
                    job: job,
                    houseTypeById: houseTypeById,
                    profile: userProfileById),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryStatusCard() {
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
            const Text(
              'Giao vào 11 Th10',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildProgressDot(true),
                _buildProgressLine(true),
                _buildProgressDot(true),
                _buildProgressLine(true),
                _buildProgressDot(true),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đã vận chuyển'),
                Text('Đang giao hàng'),
                Text('Đã giao hàng'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInfoCard() {
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPX Express',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'SPXVN0419102963A',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('Sao chép'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSheet(
      {required BuildContext context,
      required BookingResponseEntity job,
      required HouseEntities? houseTypeById,
      required ProfileEntity? profile}) {
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
                  const Divider(height: 32),
                  _buildSectionTitle('Thông tin khách hàng'),
                  const SizedBox(height: 16),
                  _buildCustomerInfo(profile: profile),
                  const SizedBox(height: 3),
                  _buildConfirmationImageLink(context),
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
        fontSize: 16,
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
              Text(
                'Loại nhà',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                house?.name ?? '',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số tầng',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                job.floorsNumber,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số phòng',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                job.roomNumber,
                style: TextStyle(fontSize: 14),
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
        _buildLocationRow('Địa điểm đón', '${job.pickupAddress}'),
        _buildLocationRow('Địa điểm đến', '${job.deliveryAddress}'),
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
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Xem thêm',
                style: TextStyle(
                  color: Color(0xFFFF7643),
                  fontSize: 14,
                ),
              ),
            ),
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
            Text(
              'Tên khách hàng',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              profile?.name ?? '',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Số điện thoại',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              profile?.phone ?? '',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmationImageLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const PorterConfirmScreen()),
        // );
        context.router.push(DriverConfirmUploadRoute());
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
