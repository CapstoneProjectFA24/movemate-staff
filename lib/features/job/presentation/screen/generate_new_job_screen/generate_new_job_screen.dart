import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/house_type_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/house_type_controller/house_type_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/widgets/button_next/confirmation_button_sheet.dart'
    as confirm_button_sheet;
import 'package:movemate_staff/features/job/presentation/widgets/function/popup.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/image.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/label.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/number_input.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/text_input.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:animate_do/animate_do.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';
// Hooks
import 'package:movemate_staff/hooks/use_fetch.dart';

@RoutePage()
class GenerateNewJobScreen extends HookConsumerWidget {
  const GenerateNewJobScreen({
    super.key,
    required this.job,
  });
  final BookingResponseEntity job;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingNotifier = ref.read(bookingProvider.notifier);
    final bookingState = ref.watch(bookingProvider);
    final state = ref.watch(bookingControllerProvider);
    // print(state.isLoading ? "Loading" : "Not Loading");
    print("Job House Type ID: ${job.houseTypeId}");

    // Truy cập BookingController
    final bookingController = ref.read(bookingControllerProvider.notifier);

    // Sử dụng useFetchObject để gọi getHouseDetails
    final useFetchResult = useFetchObject<HouseEntities>(
      function: (context) =>
          bookingController.getHouseDetails(job.houseTypeId, context),
      context: context,
    );
    final houseTypeById = useFetchResult.data;
    print('vinh log $houseTypeById');

    useEffect(() {
      if (houseTypeById != null) {
        // Cập nhật vào provider
        try {
          bookingNotifier.updateHouseType(houseTypeById);
        } catch (e) {
          print('Error updating house type in provider');
        }
      }
      return null;
    }, [houseTypeById]);

    final fetchResult = useFetch<HouseEntities>(
      function: (model, context) => bookingController.getHouse(model, context),
      initialPagingModel: PagingModel(),
      context: context,
    );
    final houseTypeEntities = fetchResult.items;
    final houseTypes = houseTypeEntities.map((e) => e.name).toList();

    // print("House Type name : ${houseTypeById?.name}");
    // print("House Type  : ${houseTypeById?.toJson()}");
    // print("House Type  all  : ${houseTypes}");

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AssetsConstants.primaryMain,
        backButtonColor: AssetsConstants.whiteColor,
        showBackButton: true,
        title: "Cập nhật Thông tin đơn hàng",
        onBackButtonPressed: () {
          bookingNotifier.reset();
          print("bookingState reset: ${bookingState.selectedVehicle}");
          Navigator.of(context).pop();
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Date/Time Input Field
                      buildLabel("Ngày/ giờ"),
                      buildTextInput(
                        defaultValue: job.createdAt,
                        hintText: "Chọn ngày/ giờ",
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),
                      // Start Location Input Field
                      buildLabel("Địa điểm bắt đầu chuyển"),
                      buildTextInput(
                        defaultValue: job.pickupAddress,
                        hintText: "Địa điểm",
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      // End Location Input Field
                      buildLabel("Địa điểm chuyển đến"),
                      buildTextInput(
                        defaultValue: job.deliveryAddress,
                        hintText: "Địa điểm",
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      // House Type Dropdown
                      buildLabel("Loại nhà"),
                      buildDropdown(
                        items: [
                          '${job.houseTypeId == houseTypeById?.id ? houseTypeById?.name : "Chọn loại nhà"}'
                        ],
                        icon: Icons.arrow_drop_down,
                      ),
                      const SizedBox(height: 16),
                      // Number of Bedrooms and Floors
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Số phòng ngủ"),
                                buildNumberInput(initialValue: "1"),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Số tầng"),
                                buildNumberInput(initialValue: "1"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Customer-Provided Images
                      buildLabel("Hình ảnh khách hàng cung cấp"),
                      buildImageRow(),
                      const SizedBox(height: 16),
                      // Vehicle Type Dropdown
                      buildLabel("Loại xe"),
                      buildDropdown(
                        items: ['Xe tải 500kg'],
                        icon: Icons.arrow_drop_down,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Additional info section
                const Padding(
                  padding: EdgeInsets.only(left: 14.0, top: 14.0),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        "Số lượng bốc vác",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thời gian ước lượng hoàn thành: 3 tiếng",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "Thời gian ước lượng kết thúc: ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "11h30",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final updatedBooking = ref.read(bookingProvider);
                      showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        context: context,
                        builder: (BuildContext context) {
                          return confirm_button_sheet.ConfirmationBottomSheet(
                            // job: job,
                            job: job.copyWith(
                              roomNumber:
                                  updatedBooking.numberOfRooms?.toString(),
                              floorsNumber:
                                  updatedBooking.numberOfFloors?.toString(),
                              createdAt:
                                  updatedBooking.bookingDate?.toIso8601String(),
                              houseTypeId: updatedBooking.houseType?.id,
                            ),
                            onConfirm: () {
                              context.router
                                  .push(AvailableVehiclesScreenRoute(job: job));
                            },
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
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
