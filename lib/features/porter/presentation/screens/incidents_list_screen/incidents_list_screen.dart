import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/porter/domain/entities/order_tracker_entity_response.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/features/porter/presentation/screens/incidents_list_screen/incident_card_item.dart';

import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/commons/widgets/custom_circular.dart';
import 'package:movemate_staff/utils/commons/widgets/empty_box.dart';
import 'package:movemate_staff/utils/commons/widgets/home_shimmer.dart';
import 'package:movemate_staff/utils/commons/widgets/loading_overlay.dart';
import 'package:movemate_staff/utils/commons/widgets/no_more_content.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/extensions/extensions_export.dart';

@RoutePage()
// Widget chính
class IncidentsListScreen extends HookConsumerWidget {
  final int bookingId;
  const IncidentsListScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(porterControllerProvider);
    final controller = ref.read(porterControllerProvider.notifier);
    final size = MediaQuery.sizeOf(context);
    final scrollController = useScrollController();
    print('checking bookingID $bookingId');
    final fetchResult = useFetch<BookingTrackersIncidentEntity>(
      function: (model, context) async {
        final servicesList = await controller.getIncidentListByBookingId(
          model,
          context,
          bookingId,
        );
        return servicesList;
      },
      initialPagingModel: PagingModel(),
      context: context,
    );

    ref.listen<bool>(refreshIncidentList, (_, __) => fetchResult.refresh());

    final dataListIcident = fetchResult.items;

    useEffect(() {
      scrollController.onScrollEndsListener(fetchResult.loadMore);
      return scrollController.dispose;
    }, const []);

    return LoadingOverlay(
      isLoading: state.isLoading,
      child: Scaffold(
        appBar: CustomAppBar(
          backgroundColor: AssetsConstants.primaryMain,
          backButtonColor: AssetsConstants.whiteColor,
          title: "Danh sách sự cố",
          iconSecond: Icons.home_outlined,
          onCallBackSecond: () {
            final tabsRouter = context.router.root
                .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
            if (tabsRouter != null) {
              tabsRouter.setActiveIndex(0);
              context.router.popUntilRouteWithName(TabViewScreenRoute.name);
            } else {
              context.router.pushAndPopUntil(
                const TabViewScreenRoute(children: [
                  HomeScreenRoute(),
                ]),
                predicate: (route) => false,
              );
            }
          },
          iconFirst: Icons.refresh,
          onCallBackFirst: fetchResult.refresh,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.02),
            (state.isLoading && fetchResult.items.isEmpty)
                ? const Center(
                    child: HomeShimmer(amount: 4),
                  )
                : fetchResult.items.isEmpty
                    ? const Align(
                        alignment: Alignment.topCenter,
                        child: EmptyBox(title: ''),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: fetchResult.items.length + 1,
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AssetsConstants.defaultPadding - 10.0,
                          ),
                          itemBuilder: (_, index) {
                            if (index == fetchResult.items.length) {
                              if (fetchResult.isFetchingData) {
                                return const CustomCircular();
                              }
                              return fetchResult.isLastPage
                                  ? const NoMoreContent()
                                  : Container();
                            }
                            final reservation = dataListIcident[index];
                            return ReservationCard(reservation: reservation);
                          },
                        ),
                      ),
          ],
        ),

        //     Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: ListView.builder(
        //     itemCount: dataListIcident.length,
        //     itemBuilder: (context, index) {
        //       final reservation = dataListIcident[index];
        //       return ReservationCard(reservation: reservation);
        //     },
        //   ),
        // ),
      ),
    );
  }
}
