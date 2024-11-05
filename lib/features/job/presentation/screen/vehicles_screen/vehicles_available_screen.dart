// available_vehicles_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
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
class AvailableVehiclesScreen extends HookConsumerWidget {
  const AvailableVehiclesScreen({
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

    // try {
    //   print(
    //       ' (AvailableVehiclesScreen) Direct print - Selected numberOfFloors: ${bookingState.numberOfFloors}');
    //   print(
    //       ' (AvailableVehiclesScreen) Direct print - Selected numberOfRooms: ${bookingState.numberOfRooms}');
    // } catch (e) {
    //   print("lỗi rồi $e");
    // }

    useEffect(() {
      scrollController.onScrollEndsListener(fetchResult.loadMore);

      return null;
    }, const []);

    final gettruck = job.bookingDetails
        .where((detail) => detail.type == "TRUCK")
        .map((truckDetail) => truckDetail.serviceId);
        // print("provider room ${}");

    return Scaffold(
      appBar: CustomAppBar(
        // showBackButton: true,
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
            // Hiển thị một dialog chờ
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );

            // Đóng dialog chờ
            Navigator.of(context).pop();

            context.router.push(BookingScreenServiceRoute(job: job));
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
