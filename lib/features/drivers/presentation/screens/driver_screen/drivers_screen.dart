import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/drivers_screen_widget/custom_bottom_sheet.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/drivers_screen_widget/driver_card.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/functions/datetime_utils.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/extensions/scroll_controller.dart';

final bookingDateFrom = StateProvider.autoDispose<String>(
  (ref) => getDateTimeNow(),
);

final bookingDateTo = StateProvider.autoDispose<String>(
  (ref) => getDateTimeNow(),
);

@RoutePage()
class DriversScreen extends HookConsumerWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final systemStatus = ref.watch(filterSystemStatus);
    final scrollController = useScrollController();
    final selectedDate = useState(DateTime.now());

    final fetchResult = useFetch<BookingResponseEntity>(
      function: (model, context) => ref
          .read(driverControllerProvider.notifier)
          .getBookingsByDriver(model, context),
      initialPagingModel: PagingModel(filterContent: systemStatus.type),
      context: context,
    );

    useEffect(() {
      scrollController.onScrollEndsListener(fetchResult.loadMore);

      return scrollController.dispose;
    }, const []);

    final jobs = _getJobsFromBookingResponseEntity(
      fetchResult.items,
      selectedDate.value,
    );
    jobs.sort((a, b) {
      final aStartTime = DateFormat('MM/dd/yyyy HH:mm:ss').parse(a.bookingAt);
      final bStartTime = DateFormat('MM/dd/yyyy HH:mm:ss').parse(b.bookingAt);
      return aStartTime.compareTo(bStartTime);
    });

    // flag true hoặc false
    ref.listen<bool>(refreshOrderList, (_, __) => fetchResult.refresh);
  
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Lịch công việc lái xe',
          backgroundColor: AssetsConstants.primaryMain,
          backButtonColor: AssetsConstants.whiteColor,
          iconFirst: Icons.refresh_rounded,
          iconSecond: Icons.filter_list_alt,
          onCallBackFirst: fetchResult.refresh,
          onCallBackSecond: () {
            showDriverCustomBottomSheet(
              onCallback: fetchResult.refresh,
              context: context,
              size: size,
            );
          }),
      body: Column(
        children: [
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = DateTime.now().add(Duration(days: index));
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
          SizedBox(height: size.height * 0.02),
          (state.isLoading && fetchResult.loadMore == false)
              ? const Center(
                  child: HomeShimmer(amount: 4),
                )
              : fetchResult.items.isEmpty
                  ? const Align(
                      alignment: Alignment.topCenter,
                      child: EmptyBox(title: 'Đơn hàng trống'),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          final startTime = DateFormat('MM/dd/yyyy HH:mm:ss')
                              .parse(job.bookingAt);
                          final endTime = startTime.add(
                            Duration(
                                minutes: int.parse(
                                    job.estimatedDeliveryTime ?? '0')),
                          );

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time Indicator and Timeline Line
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
                                child: DriverCard(
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
