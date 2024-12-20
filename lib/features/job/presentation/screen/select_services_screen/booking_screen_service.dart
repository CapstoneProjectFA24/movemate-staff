// booking_screen_service.dart
//route
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_details_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/screen/complete_proposal_screen/complete_proposal_screen.dart';
import 'package:movemate_staff/features/job/presentation/screen/select_services_screen/service_package_tile.dart';
import 'package:movemate_staff/features/job/presentation/widgets/button_next/summary_section.dart';
//entity

//hook & extentions
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

@RoutePage()
class BookingScreenService extends HookConsumerWidget {
  const BookingScreenService({
    super.key,
    required this.job,
  });
  final BookingResponseEntity job;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scrollController = useScrollController();
    final bookingState = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    final state = ref.watch(bookingControllerProvider);
    final double price = bookingState.totalPrice;
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

    final fetchResultBooing = useFetch<BookingResponseEntity>(
      function: (model, context) => ref
          .read(bookingControllerProvider.notifier)
          .getBookings(model, context),
      initialPagingModel: PagingModel(
        pageSize: 50,
        pageNumber: 1,
      ),
      context: context,
    );

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

    // print('vinh log ${selectedServices.value.map((e) => e.toJson())}');
    // print('vinh log ${quantities.value}');
    // Sử dụng useEffect để init data một lần duy nhất
    // useEffect(() {
    //   if (!hasInitialized.value) {
    //     hasInitialized.value = true;

    //     // Sử dụng addPostFrameCallback để tránh update state trong build
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       syncData(job, fetchResult.items, bookingNotifier);
    //     });
    //   }
    //   return null;
    // }, []);

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
        title: const Text('Thông tin đặt hàng'),
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
                        return ServicePackageTile(
                          servicePackage: package,
                          job: job,
                          selectedServices: selectedServices,
                          quantities: quantities,
                        );
                        // return ServicePackageList(servicePackages: servicePackages);
                      },
                    ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
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
        onPlacePress: () {
          // final bookingRequest =
          //     BookingUpdateRequest.fromBookingUpdate(bookingState);
          // final bookingstate = ref.watch(bookingProvider);
          // print(
          //     'tuan Booking bookingstate pickUpLocation service: ${jsonEncode(bookingstate.pickUpLocation)}');
          // print(
          //     'tuan Booking bookingstate dropOffLocation service: ${jsonEncode(bookingstate.dropOffLocation)}');
          // print('tuan Booking Request: ${jsonEncode(bookingRequest.toMap())}');

          // showDialog(
          //   context: context,
          //   builder: (context) => AlertDialog(
          //     title: const Text('Xác nhận'),
          //     content: const Text('Bạn có chắc muốn cập nhật đơn hàng?'),
          //     backgroundColor:
          //         Colors.white, // Set the background color to white
          //     actions: [
          //       Align(
          //         alignment: Alignment.center,
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             TextButton(
          //               onPressed: () {
          //                 // Cancel button
          //                 Navigator.of(context).pop();
          //               },
          //               child: const Text(
          //                 'Hủy',
          //                 style: TextStyle(color: AssetsConstants.primaryMain),
          //               ),
          //             ),
          //             const SizedBox(width: 16),
          //             TextButton(
          //               onPressed: () async {
          //                 // Confirm button
          //                 // Navigator.of(context).pop();
          //                 final bookingResponse = await ref
          //                     .read(bookingControllerProvider.notifier)
          //                     .updateBooking(
          //                       context: context,
          //                       id: job.id,
          //                     );
          //                 print("bookingResponse screen $bookingResponse");
          //                 print("booking id  ${job.id}");
          //                 if (bookingResponse != null) {
          //                   // Điều hướng tới JobDetailsScreen sau khi thành công
          //                   if (context.mounted) {
          //                     // Đảm bảo widget vẫn còn mounted
          //                     Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                         builder: (context) =>
          //                             JobDetailsScreen(job: bookingResponse),
          //                       ),
          //                     );
          //                     // context.router.pushAll([
          //                     //   JobDetailsScreenRoute(job: bookingResponse),
          //                     //   // Các tuyến đường khác nếu cần
          //                     // ]);

          //                     print("context.mounted ${context.mounted}");
          //                     // context.router.push(
          //                     //   JobDetailsScreenRoute(job: bookingResponse),
          //                     //   // predicate: (route) => false,
          //                     // );
          //                   }
          //                 }
          //                 // else {
          //                 //   final tabsRouter = context.router.root
          //                 //       .innerRouterOf<TabsRouter>(
          //                 //           TabViewScreenRoute.name);
          //                 //   if (tabsRouter != null) {
          //                 //     tabsRouter.setActiveIndex(0);
          //                 //     context.router.popUntilRouteWithName(
          //                 //         TabViewScreenRoute.name);
          //                 //   }
          //                 // }
          //               },
          //               child: const Text(
          //                 'Xác nhận',
          //                 style: TextStyle(color: AssetsConstants.primaryMain),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // );

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CompleteProposalScreen(
                      job: job,
                    )),
          );
        },
        buttonText: 'Bước tiếp theo',
        // priceLabel: 'Tổng giá',
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
