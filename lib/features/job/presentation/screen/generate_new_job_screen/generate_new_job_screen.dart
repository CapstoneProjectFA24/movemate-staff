import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/house_type_controller/house_type_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/image.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/label.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/number_input.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/text_input.dart';
import 'package:movemate_staff/features/job/presentation/widgets/house_type/house_type_selection_modal.dart';
import 'package:movemate_staff/features/porter/presentation/screens/porter_detail_screen/porter_detail_screen.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
// Hooks

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
    final state = ref.watch(houseTypeControllerProvider);

    // Truy cập BookingController
    final bookingController = ref.read(houseTypeControllerProvider.notifier);

    // Sử dụng useFetchObject để gọi getHouseDetails
    final useFetchResult = useFetchObject<HouseEntities>(
      function: (context) =>
          bookingController.getHouseDetails(job.houseTypeId, context),
      context: context,
    );
    final houseTypeById = useFetchResult.data;
    // print('vinh log $houseTypeById');

    useEffect(() {
      if (houseTypeById != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          bookingNotifier.updateHouseType(houseTypeById);
        });
      }
      return null;
    }, [houseTypeById]);

    final roomNumberController =
        useTextEditingController(text: job.roomNumber.toString() ?? "1");

    final floorsNumberController =
        useTextEditingController(text: job.floorsNumber.toString() ?? "1");
    // print("object ${job.roomNumber} ");

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bookingNotifier.updateNumberOfRooms(int.tryParse(job.roomNumber) ?? 1);
        bookingNotifier
            .updateNumberOfFloors(int.tryParse(job.floorsNumber) ?? 1);
      });
      return null;
    }, [roomNumberController, floorsNumberController]);

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AssetsConstants.primaryMain,
        backButtonColor: AssetsConstants.whiteColor,
        showBackButton: true,
        title: "Cập nhật Thông tin đơn hàng",
        onBackButtonPressed: () {
          // bookingNotifier.reset();
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

                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const HouseTypeSelectionModal(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                bookingState.houseType?.name ?? "Chọn loại nhà",
                                style: TextStyle(
                                  color: bookingState.houseType != null
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Number of Bedrooms and Floors
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Số phòng"),
                                buildNumberInput(
                                  controller: roomNumberController,
                                  onChanged: (value) {
                                    final roomNumber = int.tryParse(value);
                                    if (roomNumber != null) {
                                      bookingNotifier
                                          .updateNumberOfRooms(roomNumber);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Số tầng"),
                                buildNumberInput(
                                  controller: floorsNumberController,
                                  onChanged: (value) {
                                    final floorsNumber = int.tryParse(value);
                                    if (floorsNumber != null) {
                                      bookingNotifier
                                          .updateNumberOfFloors(floorsNumber);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // Customer-Provided Images
                      // buildLabel("Hình ảnh khách hàng cung cấp"),
                      // buildImageRow(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 30.0, top: 30, right: 10, left: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          context.router
                              .push(AvailableVehiclesScreenRoute(job: job));
                          // bookingNotifier.updateDropOffLocation(Location(latitude: job.pickupPoint, longitude: job.deliveryPoint));
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
                          'Bước tiếp theo',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
