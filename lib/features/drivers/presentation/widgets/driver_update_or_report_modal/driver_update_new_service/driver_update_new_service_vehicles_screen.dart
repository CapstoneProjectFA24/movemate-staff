// available_vehicles_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/driver_update_or_report_modal/driver_update_new_service/driver_update_new_service_children_screen.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/location_model_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/service_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/widgets/button_next/summary_section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/vehicles/vehicle_list.dart';
import 'package:movemate_staff/models/request/paging_model.dart';

// Hooks
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';

import 'package:movemate_staff/utils/extensions/scroll_controller.dart';
// Widgets and Extensions
// import 'package:movemate/models/request/paging_model.dart';
// import 'package:movemate/utils/commons/widgets/widgets_common_export.dart';

// import 'package:movemate/utils/extensions/scroll_controller.dart';

// Data - Entity

@RoutePage()
class DriverUpdateNewServiceVehiclesScreen extends HookConsumerWidget {
  const DriverUpdateNewServiceVehiclesScreen({
    super.key,
    required this.job,
  });
  final BookingResponseEntity job;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scrollController = useScrollController();
    final state = ref.watch(bookingControllerProvider);

    final bookingState = ref.watch(bookingProvider); // Watch the booking state
    final bookingNotifier =
        ref.read(bookingProvider.notifier); // Read the booking notifier

    final fetchResult = useFetch<ServiceEntity>(
      function: (model, context) async {
        final result = await ref
            .read(bookingControllerProvider.notifier)
            .getVehicle(model, context);
        return result.map((e) => e).toList();
      },
      initialPagingModel: PagingModel(
        searchContent: "1",
      ),
      context: context,
    );

    useEffect(() {
      scrollController.onScrollEndsListener(fetchResult.loadMore);

      return null;
    }, const []);

    final gettruck = job.bookingDetails
        .where((detail) => detail.type == "TRUCK")
        .map((truckDetail) => truckDetail.serviceId);


    return Scaffold(
      appBar: CustomAppBar(
        // showBackButton: true,
        backButtonColor: Colors.white,
        title: 'Phương tiện có sẵn',
        iconFirst: Icons.refresh_rounded,
        onCallBackFirst: fetchResult.refresh,
      ),
      body: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          Expanded(
            child: VehicleList(
              job: job,
              state: state,
              fetchResult: fetchResult,
              scrollController: scrollController,
              bookingNotifier: bookingNotifier,
              bookingState: bookingState,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SummarySection(
        buttonText: "Bước tiếp theo",
        // priceLabel: 'Giá',
        buttonIcon: false,
        // totalPrice: bookingState.totalPrice ?? 0.0,
        isButtonEnabled: bookingState.selectedVehicle != null,
        onPlacePress: () async {
          if (bookingState.selectedVehicle != null
              // &&bookingState.selectedVehicle?.id == gettruck.first
              ) {
            // Tách pickupPoint và deliveryPoint từ chuỗi
            final List<String> pickupCoordinates = job.pickupPoint.split(",");
            final double pickupLatitude = double.parse(pickupCoordinates[0]);
            final double pickupLongitude = double.parse(pickupCoordinates[1]);

            final List<String> deliveryCoordinates =
                job.deliveryPoint.split(",");

            final double deliveryLatitude =
                double.parse(deliveryCoordinates[0]);

            final double deliveryLongitude =
                double.parse(deliveryCoordinates[1]);

            // Tạo đối tượng LocationModel cho pickupPoint
            final pickupLocation = LocationModel(
              label: 'Điểm đón',
              address: job.pickupAddress,
              latitude: pickupLatitude,
              longitude: pickupLongitude,
              distance: job.estimatedDistance,
            );

            // Tạo đối tượng LocationModel cho deliveryPoint
            final deliveryLocation = LocationModel(
              label: 'Điểm giao',
              address: job
                  .deliveryAddress, // Có thể sử dụng một trường phù hợp từ job hoặc để trống nếu không có sẵn
              latitude: deliveryLatitude,
              longitude: deliveryLongitude,
              distance: job.estimatedDistance,
            );

            // Cập nhật vào BookingProvider
            bookingNotifier.updatePickUpLocation(pickupLocation);
            bookingNotifier.updateDropOffLocation(deliveryLocation);

            // Hiển thị một dialog chờ
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );

            // Đóng dialog chờ
            Navigator.of(context).pop();

            context.router
                .push(DriverUpdateNewServiceChildrenScreenRoute(job: job));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Vui lòng chọn phương tiện phù hợp')),
            );
          }
        },
      ),
    );
  }
}
