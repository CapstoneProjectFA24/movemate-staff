import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Routes
import 'package:movemate_staff/configs/routes/app_router.dart';

// Models & Entities
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/contact_info_section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/detail_info_basic.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/header_status_section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/image_info_section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/price_service_section.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/models/request/paging_model.dart';

// Controllers & Providers
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/controllers/house_type_controller/house_type_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';

// Widgets
import 'package:movemate_staff/features/job/presentation/widgets/details/action_button.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/commons/widgets/loading_overlay.dart';

// Hooks & Utils
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';

@RoutePage()
class JobDetailsScreen extends HookConsumerWidget {
  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  final BookingResponseEntity job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(false);
    final isExpanded1 = useState(false);

    void toggleDropdown() {
      isExpanded.value = !isExpanded.value;
    }

    void toggleDropdown1() {
      isExpanded1.value = !isExpanded1.value;
    }

    final bookingNotifier = ref.read(bookingProvider.notifier);

    final Map<String, List<String>> groupedImages =
        getGroupedImages(job.bookingTrackers);

    final statusBooking = job.status.toBookingTypeEnum();
    // Truy cập BookingController
    final houseTypeController = ref.read(houseTypeControllerProvider.notifier);

    final useFetchHouseResult = useFetchObject<HouseEntities>(
      function: (context) =>
          houseTypeController.getHouseDetails(job.houseTypeId, context),
      context: context,
    );

    AssignmentsStatusType? statusAssignment;
    if (job.assignments.isNotEmpty) {
      statusAssignment = job.assignments.first.status.toAssignmentsTypeEnum();
    } else {
      statusAssignment = null;
      print('Warning: Assignments list is empty.');
    }

    final buttonState = statusAssignment != null
        ? ButtonStateManager.getButtonState(statusBooking, statusAssignment)
        : ButtonState(isVisible: false);

    final state = ref.watch(bookingControllerProvider);
    final fetchResult = useFetch<BookingResponseEntity>(
      function: (model, context) => ref
          .read(bookingControllerProvider.notifier)
          .getBookings(model, context),
      initialPagingModel: PagingModel(
        pageSize: 50,
        pageNumber: 1,
      ),
      context: context,
    );

    final statusAsync = ref.watch(orderStatusStreamProvider(job.id.toString()));
    // final statusAsyncAssignment =
    //     ref.watch(orderStatusAssignmentStreamProvider(job.id.toString()));

    final statusAsyncAssignment = ref
        .watch(orderStatusAssignmentStreamProvider(job.id.toString()))
        .when<AsyncValue<AssignmentsStatusType>>(
          data: (statusList) {
            if (statusList.isEmpty || statusList.first == null) {
              return AsyncValue.data(AssignmentsStatusType
                  .arrived); // Giá trị mặc định nếu list rỗng
            }
            return AsyncValue.data(statusList.first);
          },
          loading: () => const AsyncValue.loading(),
          error: (err, stack) => AsyncValue.error(err, stack),
        );

    final debounce = useRef<Timer?>(null);
    final statusOrders = statusAsync.when(
      data: (status) => status,
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
    // useEffect(() {
    //   statusAsync.whenData((status) {
    //     debounce.value?.cancel();
    //     debounce.value = Timer(const Duration(milliseconds: 300), () {
    //       fetchResult.refresh();
    //     });
    //   });
    //   statusAsyncAssignment.whenData((status) {
    //     debounce.value?.cancel();
    //     debounce.value = Timer(const Duration(milliseconds: 300), () {
    //       fetchResult.refresh();
    //     });
    //   });
    //   return () {
    //     debounce.value?.cancel();
    //   };
    // }, [statusAsync, statusAsyncAssignment]);

    return LoadingOverlay(
      isLoading: state.isLoading,
      child: Scaffold(
        appBar: CustomAppBar(
          backgroundColor: AssetsConstants.primaryMain,
          backButtonColor: AssetsConstants.whiteColor,
          showBackButton: true,
          title: "Thông tin đơn hàng #${job.id} ",
          iconSecond: Icons.home_outlined,
          // iconFirst: Icons.refresh,
          onBackButtonPressed: () {
            bookingNotifier.reset();
            Navigator.of(context).pop();
          },
          onCallBackSecond: () {
            final tabsRouter = context.router.root
                .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
            if (tabsRouter != null) {
              tabsRouter.setActiveIndex(0);
              context.router.popUntilRouteWithName(TabViewScreenRoute.name);
            }
          },
          // onCallBackFirst: () => {
          //   fetchResult.refresh(),
          // },
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookingHeaderStatusSection(
                  isReviewOnline: job.isReviewOnline,
                  job: job,
                  fetchResult: fetchResult,
                ),
                const SizedBox(height: 50),
                DetailInfoBasicCard(
                  job: job,
                  useFetchHouseResult: useFetchHouseResult,
                ),
                const SizedBox(height: 20),
                ContactInfoSection(
                  isExpanded: isExpanded,
                  toggleDropdown: () => isExpanded.value = !isExpanded.value,
                  job: job,
                ),
                const SizedBox(height: 10),
                ImageInfoSection(
                  isExpanded1: isExpanded1,
                  toggleDropdown1: () => isExpanded1.value = !isExpanded1.value,
                  groupedImages: groupedImages,
                ),
                const SizedBox(height: 20),
                PriceDetailsContainer(job: job)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
