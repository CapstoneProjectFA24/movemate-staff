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

import '../../../../../../utils/commons/widgets/widgets_common_export.dart';

final orderControllerProvider = StateProvider<String>((ref) => '');

@RoutePage()
class IncidentsScreen extends HookConsumerWidget {
  final BookingResponseEntity order;
  const IncidentsScreen({super.key, required this.order});

  // Hàm để lấy vị trí hiện tại
  Future<Position> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Không có quyền truy cập vị trí");
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Hàm để gọi Reverse Geocoding API của VietMap
  Future<Map<String, dynamic>> getAddressFromLatLng(Position position) async {
    const apiKey = APIConstants.apiVietMapKey;
    final double latitude = position.latitude;
    final double longitude = position.longitude;

    final String url =
        'https://maps.vietmap.vn/api/reverse/v3?apikey=$apiKey&lat=$latitude&lng=$longitude';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Lấy thông tin từ boundaries
          String display = data[0]['display'];
          return {'display': display, 'position': position};
        } else {
          return {'display': "Không tìm thấy địa chỉ", 'position': position};
        }
      } else {
        return {
          'display': "Lỗi khi gọi API: ${response.statusCode}",
          'position': position
        };
      }
    } catch (e) {
      return {'display': "Không thể lấy địa chỉ: $e", 'position': position};
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportType = useState<String?>('Hư xe');

    final stateIsLoading = useState<bool?>(false);

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
                  width: double.infinity, // Chiều ngang toàn màn hình
                  child: ElevatedButton(
                    onPressed: stateIsLoading.value == false
                        ? () async {
                            try {
                              description.value = descriptionController.text;

                              print('text controller ${description.value}');
                              print(
                                  'text controller  title ${supportType.value}');

                              final int getAssignmentId = order.assignments
                                  .firstWhere((e) =>
                                      e.isResponsible == true &&
                                      e.staffType == 'DRIVER')
                                  .id;
                              final request = DriverReportIncidentRequest(
                                type: description.value,
                              );

                              final String requests =
                                  'Loại hỗ trợ: ${supportType.value} ' +
                                      ' Mô tả : ${description.value}';
                              await ref
                                  .read(driverControllerProvider.notifier)
                                  .driverReportIncident(
                                    context: context,
                                    id: getAssignmentId,
                                    request: requests,
                                  );

                              // Đánh dấu yêu cầu đã được gửi
                              // isRequestSent.value = true;
                            } catch (e) {
                              // Xử lý lỗi nếu có
                              print('Error sending report: $e');
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: AssetsConstants.defaultBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Bo góc
                      ),
                    ),
                    child: Consumer(builder: (context, ref, _) {
                      final bookingState = ref.watch(orderControllerProvider);
                      final isLoading = bookingState is AsyncLoading;
                      return isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AssetsConstants.whiteColor),
                                strokeWidth: 2.0,
                              ),
                            )
                          : const LabelText(
                              content: 'Gửi yêu cầu',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: AssetsConstants.whiteColor,
                            );
                    }),
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
