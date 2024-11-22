import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/custom_tab_container.dart';
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

    final selectedDate = useState(DateTime.now());
    final todayIndex = useState(7);

    List<BookingResponseEntity> getJobsForSelectedDate() {
      return fetchResult.items.where((booking) {
        DateTime bookingDate =
            DateFormat("MM/dd/yyyy HH:mm:ss").parse(booking.bookingAt);
        return DateFormat.yMd().format(bookingDate) ==
            DateFormat.yMd().format(selectedDate.value);
      }).toList();
    }

    ref.listen<bool>(refreshJobList, (_, __) => fetchResult.refresh());
    ref.listen<bool>(refreshDriverList, (_, __) => fetchResult.refresh());
    ref.listen<bool>(refreshPorterList, (_, __) => fetchResult.refresh());
    
    Widget buildTabContent(String tabName) {
      List<BookingResponseEntity> filteredBookings = getJobsForSelectedDate();

      switch (tabName) {
        case "Đang đợi đánh giá":
          filteredBookings = filteredBookings.where((booking) {
            final status = booking.status.toBookingTypeEnum();
            return [
              BookingStatusType.pending,
              BookingStatusType.assigned,
              BookingStatusType.waiting,
              BookingStatusType.depositing,
            ].contains(status);
          }).toList();
          break;
        case "Đã đánh giá":
          filteredBookings = filteredBookings.where((booking) {
            final status = booking.status.toBookingTypeEnum();
            return [
              BookingStatusType.reviewing,
              BookingStatusType.reviewed,
              BookingStatusType.coming,
              BookingStatusType.inProgress,
              BookingStatusType.completed,
              BookingStatusType.confirmed,
            ].contains(status);
          }).toList();
          break;
        default:
          filteredBookings = [];
      }

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
                              horizontal: 5, vertical: 10),
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
          if (state.isLoading && filteredBookings.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: HomeShimmer(amount: 4),
              ),
            )
          else if (filteredBookings.isEmpty)
            const SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topCenter,
                child: EmptyBox(title: 'Không có đơn để đánh giá '),
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
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
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
