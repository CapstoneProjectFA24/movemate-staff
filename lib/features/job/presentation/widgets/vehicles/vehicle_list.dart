import 'package:flutter/material.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_enities.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/service_entity.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/widgets/vehicles/vehicle_card.dart';
import 'package:movemate_staff/utils/commons/widgets/custom_circular.dart';
import 'package:movemate_staff/utils/commons/widgets/empty_box.dart';
import 'package:movemate_staff/utils/commons/widgets/home_shimmer.dart';
import 'package:movemate_staff/utils/commons/widgets/no_more_content.dart';

// vehicle_list.dart
class VehicleList extends StatelessWidget {
  final dynamic state;
  final dynamic fetchResult;
  final ScrollController scrollController;
  final BookingNotifier bookingNotifier;
  final Booking bookingState;
  final BookingResponseEntity job;
  const VehicleList({
    super.key,
    required this.state,
    required this.fetchResult,
    required this.scrollController,
    required this.bookingNotifier,
    required this.bookingState,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && fetchResult.items.isEmpty) {
      return const Center(child: HomeShimmer(amount: 4));
    }
    if (fetchResult.items.isEmpty) {
      return const Align(
        alignment: Alignment.topCenter,
        child: EmptyBox(title: 'Các phương tiện đều bận'),
      );
    }
    try {
      // print(
      //     "(VehicleList) fetchResult job - serviceIdP: ${job?.bookingDetails.first.serviceId}");
    } catch (e) {
      print("lỗi rồi $e");
    }
    // Kiểm tra xem người dùng đã chọn vehicle mới chưa
    bool hasUserSelection = bookingState.selectedVehicle != null;
    final serviceIdOld = job.bookingDetails
        .where((detail) => detail.type == "TRUCK")
        .map((truckDetail) => truckDetail.serviceId);

    return ListView.builder(
      itemCount: fetchResult.items.length + 1,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      itemBuilder: (context, index) {
        if (index == fetchResult.items.length) {
          if (fetchResult.isFetchingData) {
            return const CustomCircular();
          }
          return fetchResult.isLastPage ? const NoMoreContent() : Container();
        }
        final service = fetchResult.items[index] as ServiceEntity;

        bool isSelected = hasUserSelection
            ? service.id == bookingState.selectedVehicle?.id
            : job.bookingDetails
                .any((detail) => detail.serviceId == service.id);

        // print("Service ID: ${service.id}");
        // print(
        //     "Booking Details Service IDs: ${job.bookingDetails.map((e) => e.serviceId).toList()}");
        // print("Is Service Selected: $isSelected");
        return GestureDetector(
          onTap: () {
            // print("service name được chọn là: ${service.name}");
            // print("service được chọn là: ${service.id}");
            // print("Xe được chọn là: ${service.truckCategory?.id}");
            // print(
            //     "Booking Details Service IDs: ${job.bookingDetails.map((e) => e.serviceId).toList()}");

            try {
              print(
                  ' (AvailableVehiclesScreen) Direct print - Selected numberOfFloors: ${bookingState.numberOfFloors}');
              print(
                  ' (AvailableVehiclesScreen) Direct print - Selected numberOfRooms: ${bookingState.numberOfRooms}');
            } catch (e) {
              print("lỗi rồi $e");
            }
            // Tìm serviceEntity cũ từ job.bookingDetails
            final oldServiceId = job.bookingDetails
                .where((detail) => detail.type == "TRUCK")
                .map((truckDetail) => truckDetail.serviceId)
                .firstOrNull;

            if (oldServiceId != null) {
              final serviceEntityOld = fetchResult.items.firstWhere(
                (entity) => entity.id == oldServiceId,
                orElse: () => ServiceEntity(
                  id: 0,
                  name: '',
                  description: '',
                  imageUrl: '',
                  amount: 0,
                  truckCategory: null,
                  isActived: false,
                  tier: 0,
                  type: '',
                  discountRate: 0,
                ),
              );
              bookingNotifier.updateSelectedVehicle(service);
              bookingNotifier.updateSelectedVehicleOld(serviceEntityOld);
            } else {
              bookingNotifier.updateSelectedVehicle(service);
            }
          },
          child:
              VehicleCard(service: service, isSelected: isSelected, job: job),
        );
      },
    );
  }
}
