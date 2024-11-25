import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/porter_screen_widget/porter_bottom_sheet.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/porter_screen_widget/porter_card.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/functions/datetime_utils.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/extensions/scroll_controller.dart';

final bookingPorterDateFrom = StateProvider.autoDispose<String>(
  (ref) => getDateTimeNow(),
);

final bookingPorterDateTo = StateProvider.autoDispose<String>(
  (ref) => getDateTimeNow(),
);

@RoutePage()
class PorterScreen extends HookConsumerWidget {
  const PorterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(porterControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final systemStatus = ref.watch(filterPorterSystemStatus);
    final scrollController = useScrollController();
    final selectedDate = useState(DateTime.now());
    final fetchResult = useFetch<BookingResponseEntity>(
      function: (model, context) => ref
          .read(porterControllerProvider.notifier)
          .getBookingsByPorter(model, context),
      initialPagingModel: PagingModel(filterContent: systemStatus.type),
      context: context,
    );

    useEffect(() {
      scrollController.onScrollEndsListener(fetchResult.loadMore);
      print("tuan check log card real time: ");
      return scrollController.dispose;
    }, const []);

    ref.listen<bool>(refreshPorterList, (_, __) => fetchResult.refresh());

    final jobs = _getJobsFromBookingResponseEntity(
      fetchResult.items,
      selectedDate.value,
    );

    jobs.sort((a, b) {
      final aStartTime = DateFormat('MM/dd/yyyy HH:mm:ss').parse(a.bookingAt);
      final bStartTime = DateFormat('MM/dd/yyyy HH:mm:ss').parse(b.bookingAt);
      return aStartTime.compareTo(bStartTime);
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Lịch công việc bốc vác',
        backgroundColor: AssetsConstants.primaryMain,
        backButtonColor: AssetsConstants.whiteColor,
        iconFirst: Icons.refresh_rounded,
        iconSecond: Icons.filter_list_alt,
        onCallBackFirst: fetchResult.refresh,
        onCallBackSecond: () {
          showPorterCustomBottomSheet(
            onCallback: fetchResult.refresh,
            context: context,
            size: size,
          );
        },
        showBackButton: true,
        onBackButtonPressed: () {
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
      ),
      body: Column(
        children: [
          // Week View (Horizontal Scroll)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 60,
              itemBuilder: (context, index) {
                final day = DateTime.now().add(Duration(days: index - 30));
                final isSelected = DateFormat.yMd().format(day) ==
                    DateFormat.yMd().format(selectedDate.value);
                return GestureDetector(
                  onTap: () {
                    selectedDate.value = day;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: Colors.orange.shade200,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(day),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat.d().format(day),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                final startTime =
                    DateFormat('MM/dd/yyyy HH:mm:ss').parse(job.bookingAt);
                final endTime = startTime.add(
                  Duration(
                    minutes:
                        ((double.tryParse(job.estimatedDeliveryTime ?? '0') ??
                                    0) *
                                60)
                            .round(),
                  ),
                );

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          DateFormat.Hm().format(startTime),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        if (index < jobs.length - 1)
                          Container(
                            height: 80,
                            width: 2,
                            color: Colors.orange.shade200,
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Job Card
                    Expanded(
                      child: PorterCard(
                        job: job,
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  List<BookingResponseEntity> _getJobsFromBookingResponseEntity(
      List<BookingResponseEntity> bookingResponseEntities,
      DateTime selectedDate) {
    return bookingResponseEntities
        .where((entity) =>
            DateFormat('MM/dd/yyyy').parse(entity.bookingAt).day ==
                selectedDate.day &&
            DateFormat('MM/dd/yyyy').parse(entity.bookingAt).month ==
                selectedDate.month &&
            DateFormat('MM/dd/yyyy').parse(entity.bookingAt).year ==
                selectedDate.year)
        .toList();
  }
}
