import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Routes
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';

// Models & Entities
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/screen/chat_screens/reviewer_chat_with_customer/reviewer_chat_with_customer.dart';
import 'package:movemate_staff/features/job/presentation/screen/check_available/check_available.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/detail_info_basic.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/header_status_section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/image_info_section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/custom_tab_container.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/features/profile/domain/entities/profile_entity.dart';
import 'package:movemate_staff/features/profile/presentation/controllers/profile_controller/profile_controller.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/models/request/paging_model.dart';

// Controllers & Providers
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/controllers/house_type_controller/house_type_controller.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';

// Widgets
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/commons/widgets/loading_overlay.dart';

// Hooks & Utils
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/hooks/use_fetch.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/enums/booking_status_type.dart';

@RoutePage()
class JobDetailsScreen extends HookConsumerWidget {
  final BookingResponseEntity job;
  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(false);
    final state = ref.watch(bookingControllerProvider);
    void toggleDropdown() {
      isExpanded.value = !isExpanded.value;
    }

    final bookingNotifier = ref.read(bookingProvider.notifier);

    final Map<String, List<String>> groupedImages =
        getGroupedImages(job.bookingTrackers);

    final useFetchHouseResult = useFetchObject<HouseEntities>(
      function: (context) => ref
          .read(houseTypeControllerProvider.notifier)
          .getHouseDetails(job.houseTypeId, context),
      context: context,
    );

    final useFetchUserResult = useFetchObject<ProfileEntity>(
      function: (context) => ref
          .read(profileControllerProvider.notifier)
          .getUserInfo(job.userId, context),
      context: context,
    );

    final fetchResult = useFetch<BookingResponseEntity>(
      function: (model, context) => ref
          .read(bookingControllerProvider.notifier)
          .getBookings(model, context),
      initialPagingModel: PagingModel(
        pageSize: 10,
        pageNumber: 1,
      ),
      context: context,
    );
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final status = useBookingStatus(bookingAsync.value, job.isReviewOnline);

    bool isStepCompleted(int currentStep, List<bool> conditions) {
      for (int i = currentStep; i < conditions.length; i++) {
        if (conditions[i]) return true;
      }
      return false;
    }

    final progressionStates = [
      status.canConfirmReview,
      status.canUpdateServices,
      status.canConfirmSuggestion,
      status.isReviewed,
      status.isWaitingPayment,
      status.isReviewed,
      status.isBookingComing || status.isInProgress || status.isConfirmed,
      status.isCompleted,
    ];

    final progressionStatesOffline = [
      status.canCreateSchedule,
      status.isWaitingCustomer || status.isWaitingPayment,
      status.canConfirmMoving,
      status.isStaffEnroute,
      status.canUpdateServices,
      status.canConfirmSuggestion,
      status.isReviewed,
      status.isBookingComing,
      status.isBookingComing || status.isInProgress || status.isConfirmed,
      status.isCompleted,
    ];

    final availableOnline = job.isReviewOnline &&
        (isStepCompleted(2, progressionStates) ||
            isStepCompleted(3, progressionStates) ||
            isStepCompleted(4, progressionStates) ||
            isStepCompleted(6, progressionStates));

    final availableOffline = !job.isReviewOnline &&
        (isStepCompleted(5, progressionStatesOffline) ||
            isStepCompleted(6, progressionStatesOffline) ||
            isStepCompleted(7, progressionStatesOffline));

    // flag true hoặc false
    ref.listen<bool>(refreshDriverList, (_, __) => fetchResult.refresh());
    ref.listen<bool>(refreshPorterList, (_, __) => fetchResult.refresh());
    ref.listen<bool>(refreshJobList, (_, __) => fetchResult.refresh());
    return LoadingOverlay(
      isLoading: state.isLoading,
      child: Scaffold(
        appBar: CustomAppBar(
          backgroundColor: AssetsConstants.primaryMain,
          backButtonColor: AssetsConstants.whiteColor,
          showBackButton: true,
          title: "Thông tin đơn hàng #${job.id} ",
          iconSecond: Icons.home_outlined,
          iconFirst: Icons.chat_outlined,
          onBackButtonPressed: () {
            bookingNotifier.reset();
            Navigator.of(context).pop();
          },
          onCallBackFirst: () {
            print("onCallBackFirst triggered");
            context.router.push(ChatWithCustomerScreenRoute(
              customerId: job.userId.toString(),
              bookingId: job.id.toString(),
            ));
          },
          onCallBackSecond: () {
            final tabsRouter = context.router.root
                .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
            if (tabsRouter != null) {
              tabsRouter.setActiveIndex(0);
              context.router.popUntilRouteWithName(TabViewScreenRoute.name);
            }
          },
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (availableOnline || availableOffline)
                  CheckAvailable(job: job),
                BookingHeaderStatusSection(
                  isReviewOnline: job.isReviewOnline,
                  job: job,
                  fetchResult: fetchResult,
                ),
                const SizedBox(height: 20),
                CombinedInfoSection(
                  job: job,
                  useFetchHouseResult: useFetchHouseResult,
                  useFetchUserResult: useFetchUserResult,
                  isExpanded: isExpanded,
                  toggleDropdown: () => isExpanded.value = !isExpanded.value,
                  groupedImages: groupedImages,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
