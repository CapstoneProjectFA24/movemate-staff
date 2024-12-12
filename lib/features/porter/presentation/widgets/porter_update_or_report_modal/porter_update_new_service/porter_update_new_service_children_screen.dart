// booking_screen_service.dart
//route
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/data/models/request/driver_update_service_request.dart';
import 'package:movemate_staff/features/drivers/data/models/request/porter_update_service_request.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/driver_update_or_report_modal/driver_update_new_service/driver_update_service_package_tile.dart';
import 'package:movemate_staff/features/job/data/model/request/booking_requesst.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_details_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/screen/complete_proposal_screen/complete_proposal_screen.dart';
import 'package:movemate_staff/features/job/presentation/screen/select_services_screen/service_package_tile.dart';
import 'package:movemate_staff/features/job/presentation/widgets/button_next/summary_section.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/porter_update_or_report_modal/porter_update_new_service/porter_update_service_package_tile.dart';
//entity

//hook & extentions
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

@RoutePage()
class PorterUpdateNewServiceChildrenScreen extends HookConsumerWidget {
  const PorterUpdateNewServiceChildrenScreen({
    super.key,
    required this.job,
  });
  final BookingResponseEntity job;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    // final scrollController = useScrollController();
    final bookingState = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    final state = ref.watch(bookingControllerProvider);
    // final double price = bookingState.totalPrice;
    // Sử dụng một flag để track việc đã init chưa
    final hasInitialized = useRef(false);

    final fetchResult = useFetch<ServicesPackageEntity>(
      function: (model, context) async {
        final result = await ref
            .read(bookingControllerProvider.notifier)
            .getServicesPackage(model, context);
        return result; // Ensure this returns data
      },
      initialPagingModel: PagingModel(
        sortColumn: '1',
      ),
      context: context,
    );

    // final fetchResultBooing = useFetch<BookingResponseEntity>(
    //   function: (model, context) => ref
    //       .read(bookingControllerProvider.notifier)
    //       .getBookings(model, context),
    //   initialPagingModel: PagingModel(
    //     pageSize: 50,
    //     pageNumber: 1,
    //   ),
    //   context: context,
    // );

    final selectedServices = useState<List<ServicesPackageEntity>>([]);
    final quantities = useState<Map<String, int>>({});

    final bookingDetails = job.bookingDetails;
    final services = fetchResult.items;

    useEffect(() {
      if (bookingDetails.isNotEmpty && services.isNotEmpty) {
        final initialSelectedServices = <ServicesPackageEntity>[];
        final initialQuantities = <String, int>{};

        for (final service in services) {
          final mainServiceInBooking = bookingDetails
              .firstWhereOrNull((bd) => bd.serviceId == service.id);
          if (mainServiceInBooking != null) {
            final serviceWithQuantity = service.copyWith(
              quantity: mainServiceInBooking.quantity,
            );
            initialSelectedServices.add(serviceWithQuantity);
            initialQuantities[service.id.toString()] =
                mainServiceInBooking.quantity;
          }

          for (final childService in service.inverseParentService ?? []) {
            final childServiceInBooking = bookingDetails
                .firstWhereOrNull((bd) => bd.serviceId == childService.id);
            if (childServiceInBooking != null) {
              final childServiceWithQuantity = childService.copyWith(
                quantity: childServiceInBooking.quantity,
              );
              initialSelectedServices.add(childServiceWithQuantity);
              initialQuantities[childService.id.toString()] =
                  childServiceInBooking.quantity;
            }
          }
        }

        selectedServices.value = initialSelectedServices;
        quantities.value = initialQuantities;
      }
      return null;
    }, [bookingDetails, services]);

    // Theo dõi sự thay đổi của fetchResult.items
    useEffect(() {
      if (fetchResult.items.isNotEmpty && hasInitialized.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          syncData(job, fetchResult.items, bookingNotifier);
        });
      }
      return null;
    }, [fetchResult.items]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin dịch vụ'),
        backgroundColor: AssetsConstants.primaryMain,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01),
                  if (state.isLoading && fetchResult.items.isEmpty)
                    const Center(
                      child: HomeShimmer(amount: 4),
                    )
                  else if (fetchResult.items.isEmpty)
                    const Align(
                      alignment: Alignment.topCenter,
                      child: EmptyBox(title: 'Không có dịch vụ hiện tại'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: fetchResult.items.length + 1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AssetsConstants.defaultPadding - 10.0,
                      ),
                      itemBuilder: (_, index) {
                        if (index == fetchResult.items.length) {
                          if (fetchResult.isFetchingData) {
                            return const CustomCircular();
                          }
                          return fetchResult.isLastPage
                              ? const SizedBox.shrink()
                              : Container();
                        }
                        final package = fetchResult.items[index];
                        return PorterUpdateServicePackageTile(
                          servicePackage: package,
                          job: job,
                          selectedServices: selectedServices,
                          quantities: quantities,
                        );
                        // return ServicePackageList(servicePackages: servicePackages);
                      },
                    ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SummarySection(
        buttonIcon: false,
        // totalPrice: price ?? 0.0,
        isButtonEnabled: true,

        onPlacePress: () async {
          final bookingRequest =
              DriverUpdateServiceRequest.fromBookingUpdate(bookingState);

          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              // Use dialogContext instead of context
              title: const Text('Xác nhận'),
              content: const Text('Bạn có chắc muốn cập nhật đơn hàng?'),
              backgroundColor: Colors.white,
              actions: [
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext)
                              .pop(); // Use dialogContext
                        },
                        child: const Text(
                          'Hủy',
                          style: TextStyle(color: AssetsConstants.primaryMain),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () async {
                          // Pop the dialog first
                          Navigator.of(dialogContext).pop();

                          try {
                            final PorterUpdateServiceRequest porterRequest =
                                PorterUpdateServiceRequest(
                              bookingDetails: bookingRequest.bookingDetails
                                ..first,
                            );

                            // Show loading indicator if needed
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }

                            // Perform the update
                            await ref
                                .read(porterControllerProvider.notifier)
                                .porterUpdateNewService(
                                  request: porterRequest,
                                  context: context,
                                  id: job.id,
                                );

                            // Dismiss loading indicator and navigate
                            if (context.mounted) {
                              // Navigator.of(context)
                              //     .pop(); // Remove loading indicator
                              context.router.replaceAll([
                                const TabViewScreenRoute(
                                    children: [HomeScreenRoute()]),
                              ]);
                            }
                          } catch (error) {
                            // Handle error case
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pop(); // Remove loading indicator if showing
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error: ${error.toString()}')),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(color: AssetsConstants.primaryMain),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },

        buttonText: 'Cập nhật',
      ),
    );
  }

  void syncData(
    BookingResponseEntity job,
    List<ServicesPackageEntity> services,
    BookingNotifier bookingNotifier,
  ) {
    // Reset state
    bookingNotifier.reset();

    // Sync services và sub-services
    for (var service in services) {
      // Tìm booking detail cho service
      final serviceDetail = job.bookingDetails.firstWhere(
        (detail) => detail.serviceId == service.id,
        orElse: () => BookingDetailsResponseEntity(
          id: 0,
          serviceId: 0,
          bookingId: 0,
          quantity: 0,
        ),
      );

      // Update service quantity nếu tìm thấy
      if (serviceDetail.serviceId == service.id) {
        bookingNotifier.updateServicePackageQuantity(
          service,
          serviceDetail.quantity,
        );

        // Sync sub-services
        for (var subService in service.inverseParentService) {
          final subServiceDetail = job.bookingDetails.firstWhere(
            (detail) => detail.serviceId == subService.id,
            orElse: () => BookingDetailsResponseEntity(
              id: 0,
              serviceId: 0,
              bookingId: 0,
              quantity: 0,
            ),
          );

          // Update sub-service quantity nếu tìm thấy
          if (subServiceDetail.serviceId == subService.id) {
            bookingNotifier.updateSubServiceQuantity(
              subService,
              subServiceDetail.quantity,
            );
          }
        }
      }
    }
  }
}
