// booking_screen_service.dart
//route
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
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
  const BookingScreenService({super.key});

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
    // Shared method to show the confirmation dialog
    void showConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            // child: const DailyUIChallengeCard(),
          );
        },
      );
    }

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
          showConfirmationDialog();
        },
        buttonText: 'Cập nhật',
        // priceLabel: 'Tổng giá',
        onConfirm: () {
          Navigator.pop(context);
          showConfirmationDialog();
        },
      ),
    );
  }

  
}
