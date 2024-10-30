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
import 'package:movemate_staff/features/job/presentation/widgets/house_type/house_form_controller.dart';
import 'package:movemate_staff/features/job/presentation/widgets/house_type/house_type_selection_modal.dart';
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

    // Truy cập BookingController
    final bookingController = ref.read(bookingControllerProvider.notifier);

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
        useTextEditingController(text: job.roomNumber?.toString() ?? "1");

    final floorsNumberController =
        useTextEditingController(text: job.floorsNumber?.toString() ?? "1");

    // Cập nhật StateProvider khi TextField thay đổi
    useEffect(() {
      void listener() {
        final roomText = roomNumberController.text;
        final floorsText = floorsNumberController.text;

        final roomNumber = int.tryParse(roomText);
        final floorsNumber = int.tryParse(floorsText);

        if (roomNumber != null) {
          bookingNotifier.updateNumberOfRooms(roomNumber);
        }

        if (floorsNumber != null) {
          bookingNotifier.updateNumberOfFloors(floorsNumber);
        }
      }

      roomNumberController.addListener(listener);
      floorsNumberController.addListener(listener);

      return () {
        roomNumberController.removeListener(listener);
        floorsNumberController.removeListener(listener);
      };
    }, [roomNumberController, floorsNumberController]);

    //  Đồng bộ state với controller khi state thay đổi từ bên ngoài
    useEffect(() {
      if (bookingState.numberOfRooms != null &&
          bookingState.numberOfRooms.toString() != roomNumberController.text) {
        roomNumberController.text = bookingState.numberOfRooms.toString();
      }

      if (bookingState.numberOfFloors != null &&
          bookingState.numberOfFloors.toString() !=
              floorsNumberController.text) {
        floorsNumberController.text = bookingState.numberOfFloors.toString();
      }

      return null;
    }, [bookingState.numberOfRooms, bookingState.numberOfFloors]);

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
                                buildLabel("Số phòng ngủ"),
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
