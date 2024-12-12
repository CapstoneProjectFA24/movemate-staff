import 'dart:convert';
import 'dart:ffi';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/data/model/request/driver_report_incident_request.dart';
import 'package:movemate_staff/features/job/data/model/request/resource.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

import 'package:movemate_staff/utils/commons/widgets/cloudinary/cloudinary_camera_upload_widget.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/providers/common_provider.dart';

import '../../../../../../../utils/commons/widgets/widgets_common_export.dart';

final orderControllerProvider = StateProvider<String>((ref) => '');

@RoutePage()
class IncidentsScreen extends HookConsumerWidget {
  final BookingResponseEntity order;
  const IncidentsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportType = useState<String?>('Hư xe');
    final user = ref.read(authProvider);
    final stateIsLoading = useState<bool>(false);

    final state = ref.watch(orderControllerProvider);

    final descriptionController = useTextEditingController();
    final reasonController = useTextEditingController();

    final description = useState<String>('');
    final title = useState<String>('');

    final isRequestSent = useState<bool>(false);

    List<String> supportTypes = [
      'Hư xe',
      'Sự cố giao thông',
      'Sự cố không mong muốn',
      'Thay đổi xe',
    ];

    Future<void> handleSubmit() async {
      if (stateIsLoading.value) return;

      try {
        stateIsLoading.value = true;

        // Show loading dialog
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AssetsConstants.primaryMain),
              ),
            ),
          );
        }

        description.value = descriptionController.text;

        final int getAssignmentId = order.assignments
            .firstWhere((e) => e.staffType == 'DRIVER' && e.userId == user?.id)
            .id;

        final String requests = 'Loại hỗ trợ: ${supportType.value}\n' +
            'Mô tả: ${description.value}\n';

        final request = DriverReportIncidentRequest(
          failReason: requests,
        );

        await ref.read(driverControllerProvider.notifier).driverReportIncident(
              context: context,
              id: getAssignmentId,
              request: request,
            );

        // Handle success
        if (context.mounted) {
          Navigator.of(context).pop(); // Remove loading dialog

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gửi báo cáo sự cố thành công'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to home
          final tabsRouter = context.router.root
              .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
          if (tabsRouter != null) {
            tabsRouter.setActiveIndex(0);
            context.router.popUntilRouteWithName(TabViewScreenRoute.name);
          } else {
            context.router.pushAndPopUntil(
              const TabViewScreenRoute(children: [HomeScreenRoute()]),
              predicate: (route) => false,
            );
          }
        }
      } catch (error) {
        // Handle error
        if (context.mounted) {
          Navigator.of(context).pop(); // Remove loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        stateIsLoading.value = false;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AssetsConstants.primaryMain,
        backButtonColor: AssetsConstants.whiteColor,
        title: "Báo cáo sự cố",
        iconSecond: Icons.home_outlined,
        onCallBackSecond: () {
          final tabsRouter = context.router.root
              .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
          if (tabsRouter != null) {
            tabsRouter.setActiveIndex(0);
            context.router.popUntilRouteWithName(TabViewScreenRoute.name);
          } else {
            context.router.pushAndPopUntil(
              const TabViewScreenRoute(children: [
                HomeScreenRoute(),
              ]),
              predicate: (route) => false,
            );
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tab selection
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRequestSent.value
                              ? Colors.grey[200]
                              : AssetsConstants.primaryLight,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () {
                          isRequestSent.value =
                              false; // Switch to "Yêu cầu hỗ trợ"
                        },
                        child: LabelText(
                          content: 'Yêu cầu hỗ trợ',
                          size: 14,
                          color: isRequestSent.value
                              ? AssetsConstants.greyColor.shade600
                              : AssetsConstants.whiteColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Common form fields (support type, order ID, description)
                const Text('Loại hỗ trợ',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: supportType.value ?? 'Vỡ hàng',
                  onChanged: isRequestSent.value
                      ? null // Disable editing for "Yêu cầu đã gửi"
                      : (value) {
                          supportType.value = value;
                          // Thêm ngay sau khi khởi tạo supportType
                          title.value =
                              'Vỡ hàng'; // Set initial title value; // Lưu giá trị vào `title`
                        },
                  items: supportTypes
                      .map((e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "Chọn loại hỗ trợ",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Mô tả',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: descriptionController,
                  // enabled: isRequestSent
                  //     .value, // Disable editing for "Yêu cầu đã gửi"
                  maxLines: 4,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Nhập mô tả',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: stateIsLoading.value ? null : handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: AssetsConstants.defaultBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Gửi báo cáo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: stateIsLoading.value
                            ? Colors.grey
                            : AssetsConstants.whiteColor,
                      ),
                    ),
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
