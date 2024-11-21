import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/available_staff_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/staff_entity.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';

@RoutePage()
class WorkShiftPorterUpdateScreen extends HookConsumerWidget {
  final int bookingId;

  const WorkShiftPorterUpdateScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = useState('Bốc vác');
    final startTime = useState('9:30 am');
    final endTime = useState('3:30 pm');

    final state = ref.watch(porterControllerProvider);
    final porterController = ref.read(porterControllerProvider.notifier);

    final useFetchResult = useFetchObject<AvailableStaffEntities>(
      function: (context) =>
          porterController.getPorterAvailableByBookingId(context, bookingId),
      context: context,
    );

    final datas = useFetchResult.data;

    return LoadingOverlay(
      isLoading: state.isLoading,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CustomAppBar(
          centerTitle: true,
          title: 'Cập nhật bốc vác',
          // iconFirst: Icons.refresh_rounded,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
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
                            // SizedBox(height: 16),
                            Text(
                              (datas?.staffType == null)
                                  ? 'null'
                                  : 'có dữ liệu',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildWorkShiftInfo(context: context),
                            SizedBox(height: 16),
                            _buildRoleSelection(datas: datas),
                            SizedBox(height: 16),
                            _buildEmployeeList(datas: datas),
                            SizedBox(height: 16),
                            _buildWorkTiming(startTime, endTime),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, -2),
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

  Widget _buildWorkShiftInfo({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ca làm việc', style: TextStyle(color: Colors.black)),
              Text('Ngày: february 09, 2021',
                  style: TextStyle(color: Colors.black)),
            ],
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text('Ca 1'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection({required AvailableStaffEntities? datas}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách nhân viên',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: datas?.countStaffInslots ?? 0,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                return Material(
                  type: MaterialType.transparency,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: datas!.isSussed
                              ? Colors.blue[100]
                              : Colors.orange[100],
                          child: Icon(
                            datas!.isSussed
                                ? Icons.drive_eta
                                : Icons.engineering,
                            color: datas!.isSussed
                                ? Colors.blue[700]
                                : Colors.orange[700],
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              datas?.staffInSlot
                                      .firstWhere((e) => e.id != null)
                                      .name ??
                                  '',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            SizedBox(height: 4),
                            Text(
                              datas?.staffInSlot
                                      .firstWhere((e) => e.id != null)
                                      .roleName ??
                                  '',
                              style: TextStyle(
                                fontSize: 12,
                                color: datas!.isSussed
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

  Widget _buildEmployeeList({required AvailableStaffEntities? datas}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thêm nhân viên',
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 8),
          Container(
            height: 100, // Adjust the height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Scroll horizontally
              itemCount: datas?.countOtherStaff ?? 0,
              itemBuilder: (context, index) {
                // Access each staff from datas.otherStaffs
                final staff = datas!.otherStaffs[index];
                return _buildEmployeeAvatar(
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

// Existing _buildEmployeeAvatar method
  Widget _buildEmployeeAvatar(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWorkTiming(
      ValueNotifier<String> startTime, ValueNotifier<String> endTime) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Start Time', style: TextStyle(color: Colors.black)),
              Text('End Time', style: TextStyle(color: Colors.black)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(child: Text(startTime.value)),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
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
        child: Text('Lưu'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
