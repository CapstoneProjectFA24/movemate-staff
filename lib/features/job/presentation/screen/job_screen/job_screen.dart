import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/widgets/jobcard/job_card.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/models/request/paging_model.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';
import 'package:intl/intl.dart';
import 'package:movemate_staff/utils/extensions/scroll_controller.dart';

@RoutePage()
class JobScreen extends HookConsumerWidget {
  final bool isReviewOnline;

  const JobScreen({
    super.key,
    required this.isReviewOnline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    final currentTabStatus = useState<String>("Đang đợi đánh giá");

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentTabStatus.value =
            tabController.index == 0 ? "Đang đợi đánh giá" : "Đã đánh giá";
      }
    });

    final state = ref.watch(bookingControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final scrollController = useScrollController();
    final selectedDate = useState(DateTime.now());
    final todayIndex = useState(7);

    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: useSingleTickerProvider(),
    )..repeat(reverse: true);

    final pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: pulseController,
      curve: Curves.easeInOut,
    ));

    final fetchResult = useFetch<BookingResponseEntity>(
      function: (model, context) => ref
          .read(bookingControllerProvider.notifier)
          .getBookings(model, context),
      initialPagingModel: PagingModel(
        pageSize: 10,
        pageNumber: 1,
        isReviewOnline: isReviewOnline,
      ),
      context: context,
    );

    useEffect(() {
      scrollController.onScrollEndsListener(fetchResult.loadMore);
      return scrollController.dispose;
    }, const []);

    List<String> tabs = [
      "Đang đợi đánh giá",
      "Đã đánh giá",
    ];

    //  hàm đếm tổng số đơn theo trạng thái
    int getTotalBookingsForStatus(String tabStatus) {
      return fetchResult.items.where((booking) {
        final status = booking.status.toBookingTypeEnum();
        if (tabStatus == "Đang đợi đánh giá") {
          return [
            BookingStatusType.pending,
            BookingStatusType.assigned,
            BookingStatusType.waiting,
            BookingStatusType.depositing,
          ].contains(status);
        } else {
          return [
            BookingStatusType.reviewing,
            BookingStatusType.reviewed,
            BookingStatusType.coming,
            BookingStatusType.inProgress,
            BookingStatusType.completed,
            BookingStatusType.confirmed,
          ].contains(status);
        }
      }).length;
    }

    // Hàm mới để lọc booking theo ngày và status
    List<BookingResponseEntity> getBookingsForDateAndStatus(
        DateTime date, String tabStatus) {
      return fetchResult.items.where((booking) {
        // Kiểm tra ngày
        final bookingDate = DateFormat('MM/dd/yyyy').parse(booking.bookingAt);
        final isSameDate = bookingDate.day == date.day &&
            bookingDate.month == date.month &&
            bookingDate.year == date.year;

        // Kiểm tra status
        final status = booking.status.toBookingTypeEnum();
        if (tabStatus == "Đang đợi đánh giá") {
          return isSameDate &&
              [
                BookingStatusType.pending,
                BookingStatusType.assigned,
                BookingStatusType.waiting,
                BookingStatusType.depositing,
              ].contains(status);
        } else {
          return isSameDate &&
              [
                BookingStatusType.reviewing,
                BookingStatusType.reviewed,
                BookingStatusType.coming,
                BookingStatusType.inProgress,
                BookingStatusType.completed,
                BookingStatusType.confirmed,
              ].contains(status);
        }
      }).toList();
    }

    ref.listen<bool>(refreshJobList, (_, __) => fetchResult.refresh());
    ref.listen<bool>(refreshDriverList, (_, __) => fetchResult.refresh());
    ref.listen<bool>(refreshPorterList, (_, __) => fetchResult.refresh());

    Widget buildTabContent(String tabName) {
      List<BookingResponseEntity> filteredBookings =
          getBookingsForDateAndStatus(
        selectedDate.value,
        tabName,
      );

      return CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    controller: useScrollController(
                      initialScrollOffset: todayIndex.value * 80.0,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      final day = DateTime.now().add(Duration(days: index - 7));
                      bool isSelected = DateFormat.yMd().format(day) ==
                          DateFormat.yMd().format(selectedDate.value);

                      final bookingsCount = getBookingsForDateAndStatus(
                        day,
                        currentTabStatus.value,
                      ).length;

                      return GestureDetector(
                        onTap: () {
                          selectedDate.value = day;
                          todayIndex.value = index;
                          fetchResult.refresh();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 10,
                          ),
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
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat.E().format(day),
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                DateFormat.d().format(day),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (bookingsCount > 0)
                                ScaleTransition(
                                  scale: pulseAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.3)
                                              : Colors.green.withOpacity(0.3),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '$bookingsCount',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AssetsConstants.green1,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate.value),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Số lượng công việc trong ngày: ${filteredBookings.length}',
                        style: TextStyle(
                          fontSize: 16,
                          color: filteredBookings.isNotEmpty
                              ? Colors.orange.shade800
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
          if (state.isLoading && filteredBookings.isEmpty)
            const SliverToBoxAdapter(
              child: Center(child: HomeShimmer(amount: 4)),
            )
          else if (filteredBookings.isEmpty)
            const SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topCenter,
                child: EmptyBox(title: 'Không có đơn để đánh giá'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AssetsConstants.defaultPadding - 10.0,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == filteredBookings.length) {
                      if (fetchResult.isFetchingData) {
                        return const CustomCircular();
                      }
                      return fetchResult.isLastPage
                          ? const NoMoreContent()
                          : Container();
                    }

                    return JobCard(
                      job: filteredBookings[index],
                      onCallback: fetchResult.refresh,
                      isReviewOnline: isReviewOnline,
                      currentTab: currentTabStatus.value,
                    );
                  },
                  childCount: filteredBookings.length + 1,
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        backgroundColor: AssetsConstants.mainColor,
        backButtonColor: AssetsConstants.whiteColor,
        title: "Công việc của tôi",
        iconFirst: Icons.refresh_rounded,
        iconSecond: Icons.filter_list_alt,
        onCallBackFirst: fetchResult.refresh,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              indicatorColor: Colors.orange,
              indicatorWeight: 2,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: tabs.map((tab) {
                final count = getTotalBookingsForStatus(tab);
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tab),
                      if (count > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tabController.index == tabs.indexOf(tab)
                                ? Colors.orange
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: tabController.index == tabs.indexOf(tab)
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: tabs.map((tab) => buildTabContent(tab)).toList(),
      ),
    );
  }
}
