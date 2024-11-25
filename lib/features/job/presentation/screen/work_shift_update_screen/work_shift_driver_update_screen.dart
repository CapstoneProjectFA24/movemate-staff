import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/data/model/response/staff_response.dart';
import 'package:movemate_staff/features/job/domain/entities/available_staff_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/staff_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

@RoutePage()
class WorkShiftDriverUpdateScreen extends HookConsumerWidget {
  final int bookingId;

  const WorkShiftDriverUpdateScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingStreamProvider(bookingId.toString()));
    final selectedRole = useState('Bốc vác');
    final startTime = useState('9:30 am');
    final endTime = useState('3:30 pm');

    final state = ref.watch(driverControllerProvider);
    final driverController = ref.read(driverControllerProvider.notifier);
    useEffect(() {
      // Fetch data when the widget is first built to avoid data inconsistency
      driverController.getDriverAvailableByBookingId(context, bookingId);
      return null;
    }, []);
    final useFetchResult = useFetchObject<AvailableStaffEntities>(
      function: (context) =>
          driverController.getDriverAvailableByBookingId(context, bookingId),
      context: context,
    );

    useEffect(() {
      useFetchResult.refresh();
      return null;
    }, [bookingAsync.value?.assignments.length]);

    final datas = useFetchResult.data;

    return LoadingOverlay(
      isLoading: state.isLoading,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: const CustomAppBar(
          centerTitle: true,
          title: 'Cập nhật tài xế',
          // iconFirst: Icons.refresh_rounded,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (datas?.staffType == null)
                                  ? 'Null'
                                  : 'Thêm tài xế',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            // SizedBox(height: 16),
                            _buildWorkShiftInfo(
                                context: context,
                                ref: ref,
                                id: bookingId,
                                datas: datas),
                            const SizedBox(height: 16),
                            _buildRoleSelection(datas: datas),
                            const SizedBox(height: 16),
                            _buildEmployeeList(datas: datas, context: context),
                            // SizedBox(height: 16),
                            // _buildWorkTiming(startTime, endTime),
                            // SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: _buildSaveButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkShiftInfo(
      {required BuildContext context,
      required WidgetRef ref,
      required int id,
      required AvailableStaffEntities? datas}) {
    final state = ref.watch(driverControllerProvider);
    final driverController = ref.read(driverControllerProvider.notifier);

    print("tuan check  data ${datas?.assignmentInBooking.length}");
    return LoadingOverlay(
      isLoading: state.isLoading,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Existing Row with 'Ca làm việc' and 'Ngày...'
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text('Ca làm việc', style: TextStyle(color: Colors.black)),
            //     Text('Ngày: february 09, 2021',
            //         style: TextStyle(color: Colors.black)),
            //   ],
            // ),
            const SizedBox(height: 8),
            // New Row with 'Ca 1' and 'Thêm tự động' button

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text('Ca 1', style: TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: (datas?.assignmentInBooking.length ?? 0) > 0
                      ? null
                      : () async {
                          // Handle the 'Thêm tự động' button press
                          await driverController
                              .updateManualDriverAvailableByBookingId(
                            context,
                            id,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Choose your preferred color
                  ),
                  child: const Text('Thêm tự động'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection({required AvailableStaffEntities? datas}) {
    // Danh sách mẫu bao gồm cả tài xế và bốc vác

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách tài xế sẵn sàng cho đơn hàng',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: datas?.countStaffInslots ?? 0,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return Material(
                  type: MaterialType.transparency,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: datas!.isSuccessed
                              ? Colors.blue[100]
                              : Colors.orange[100],
                          child: Icon(
                            datas.isSuccessed
                                ? Icons.drive_eta
                                : Icons.engineering,
                            color: datas.isSuccessed
                                ? Colors.blue[700]
                                : Colors.orange[700],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              datas.staffInSlot
                                      .firstWhere((e) => e.id != null)
                                      .name ??
                                  '',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              datas.staffInSlot
                                      .firstWhere((e) => e.id != null)
                                      .roleName ??
                                  '',
                              style: TextStyle(
                                fontSize: 12,
                                color: datas.isSuccessed
                                    ? Colors.blue[700]
                                    : Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Updated _buildEmployeeList method
  Widget _buildEmployeeList({
    required BuildContext context,
    required AvailableStaffEntities? datas,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thêm nhân viên',
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100, // Adjust the height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Scroll horizontally
              itemCount: datas?.countOtherStaff ?? 0,
              itemBuilder: (context, index) {
                // Access each staff from datas.otherStaffs
                final staff = datas!.otherStaffs[index];
                return _buildEmployeeAvatar(
                  context,
                  staff.name ?? '',
                  staff.avatarUrl ?? '',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Updated _buildEmployeeAvatar method
  Widget _buildEmployeeAvatar(
    BuildContext context,
    String name,
    String imageUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // Wrap CircleAvatar with GestureDetector to make it clickable
          GestureDetector(
            onTap: () {
              // Show popup modal when avatar is clicked
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: const LabelText(
                      content: 'Xác nhận',
                      size: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    content: LabelText(
                        content:
                            'Bạn có muốn thêm tài xế $name vào trong đơn hàng này?',
                        size: 14,
                        fontWeight: FontWeight.w400),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const LabelText(
                            content: 'Hủy',
                            size: 13,
                            fontWeight: FontWeight.w400),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          // Handle the confirmation action here
                          // For example, add the driver to the order
                          _addDriverToOrder(name);
                        },
                        child: const LabelText(
                            content: 'Xác nhận',
                            size: 13,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  );
                },
              );
            },
            child: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Dummy method to handle adding driver to order
  void _addDriverToOrder(String name) {
    // Implement the logic to add the driver to the order
    print('Driver $name has been added to the order.');
  }

  Widget _buildWorkTiming(
      ValueNotifier<String> startTime, ValueNotifier<String> endTime) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Start Time', style: TextStyle(color: Colors.black)),
              Text('End Time', style: TextStyle(color: Colors.black)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(child: Text(startTime.value)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(child: Text(endTime.value)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Xử lý lưu dữ liệu
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Lưu'),
      ),
    );
  }
}
