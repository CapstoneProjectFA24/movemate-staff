// booking_screen_service.dart
//route
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/screen/job_details_screen/job_details_screen.dart';
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

    final fetchResult = useFetch<ServicesPackageEntity>(
      function: (model, context) async {
        final result = await ref
            .read(bookingControllerProvider.notifier)
            .getServicesPackage(model, context);
        return result; // Ensure this returns data
      },
      initialPagingModel: PagingModel(
        sortContent: "1",
      ),
      context: context,
    );

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
                        return ServicePackageTile(servicePackage: package);
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
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text('Bạn có chắc muốn cập nhật đơn hàng?'),
              backgroundColor:
                  Colors.white, // Set the background color to white
              actions: [
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Cancel button
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Hủy',
                          style: TextStyle(color: AssetsConstants.primaryMain),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () async {
                          // Confirm button
                          // Navigator.of(context).pop();// đóng nó lại nếu không sẽ lỗi không chuyển màn hình được
                          final bookingResponse = await ref
                              .read(bookingControllerProvider.notifier)
                              .updateBooking(
                                context: context,
                                id: job.id,
                              );
                          if (bookingResponse != null) {
                            // Điều hướng tới JobDetailsScreen sau khi thành công
                            if (context.mounted) {
                              // Đảm bảo widget vẫn còn mounted
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      JobDetailsScreen(job: bookingResponse),
                                ),
                              );
                            }
                          } else {
                            final tabsRouter = context.router.root
                                .innerRouterOf<TabsRouter>(
                                    TabViewScreenRoute.name);
                            if (tabsRouter != null) {
                              tabsRouter.setActiveIndex(0);
                              context.router.popUntilRouteWithName(
                                  TabViewScreenRoute.name);
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
        // priceLabel: 'Tổng giá',
      ),
    );
  }
}
