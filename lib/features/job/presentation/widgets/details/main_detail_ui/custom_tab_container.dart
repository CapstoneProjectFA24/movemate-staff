import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/domain/entities/available_staff_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/tab_container/list_widget_item.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class CustomTabContainer extends HookConsumerWidget {
  final int bookingId;
  final List<AssignmentsResponseEntity> porterItems;
  final List<AssignmentsResponseEntity> driverItems;

  const CustomTabContainer({
    super.key,
    required this.porterItems,
    required this.driverItems,
    required this.bookingId,
  });

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String staffType,
    String staffName,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AssetsConstants.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận gán trách nhiệm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryDarker,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn gán trách nhiệm cho $staffType này?\n\nNhân viên: $staffName',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Xác nhận',
                style: TextStyle(
                  color: AssetsConstants.primaryDarker,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = useState<String>('Bốc vác');
    final selectedPorter = useState<AssignmentsResponseEntity?>(null);
    final selectedDriver = useState<AssignmentsResponseEntity?>(null);

    useEffect(() {
      if (porterItems.isNotEmpty &&
          porterItems.any((item) => item.isResponsible!)) {
        selectedPorter.value =
            porterItems.firstWhere((item) => item.isResponsible!);
      }
      if (driverItems.isNotEmpty &&
          driverItems.any((item) => item.isResponsible!)) {
        selectedDriver.value =
            driverItems.firstWhere((item) => item.isResponsible!);
      }
      return null;
    }, [porterItems, driverItems]);

    final stateDriver = ref.watch(driverControllerProvider);
    final driverController = ref.read(driverControllerProvider.notifier);
    final useFetchResultDriver = useFetchObject<AvailableStaffEntities>(
      function: (context) =>
          driverController.getDriverAvailableByBookingId(context, bookingId),
      context: context,
    );
    final datasDriver = useFetchResultDriver.data;

    final statePorter = ref.watch(porterControllerProvider);
    final porterController = ref.read(porterControllerProvider.notifier);

    final useFetchResultPorter = useFetchObject<AvailableStaffEntities>(
      function: (context) =>
          porterController.getPorterAvailableByBookingId(context, bookingId),
      context: context,
    );
    final datasPorter = useFetchResultPorter.data;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            buildTabBar(selectedTab),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.2, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: selectedTab.value == 'Bốc vác'
                            ? Column(
                                children: [
                                  Expanded(
                                    child: buildPorterList(
                                      porterItems,
                                      selectedPorter,
                                      ref,
                                      context,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  buildPorterActionButtons(selectedPorter.value,
                                      ref, context, datasPorter),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: buildDriverList(
                                      driverItems,
                                      selectedDriver,
                                      ref,
                                      context,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  buildDriverActionButtons(selectedDriver.value,
                                      ref, context, datasDriver),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabBar(ValueNotifier<String> selectedTab) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          buildTabItem(
            selectedTab: selectedTab,
            tabName: 'Tài xế',
            icon: Icons.drive_eta_outlined,
            iconColor: Colors.green,
          ),
          buildTabItem(
            selectedTab: selectedTab,
            tabName: 'Bốc vác',
            icon: Icons.person_outlined,
            iconColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget buildTabItem({
    required ValueNotifier<String> selectedTab,
    required String tabName,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = selectedTab.value == tabName;

    return Expanded(
      child: InkWell(
        onTap: () => selectedTab.value = tabName,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? iconColor : Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                tabName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPorterList(
    List<AssignmentsResponseEntity> items,
    ValueNotifier<AssignmentsResponseEntity?> selectedPorter,
    WidgetRef ref,
    BuildContext context,
  ) {
    return ListView.builder(
      key: const ValueKey('PorterList'),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListItemWidget(
          item: item,
          selectedValue: selectedPorter.value,
          selectionNotifier: selectedPorter,
          icon: Icons.person_outlined,
          iconColor: Colors.blue,
          subtitle: (item.isResponsible ?? true) ? 'Trưởng' : 'Nhân viên',
          role: "porter",
        );
      },
    );
  }

  Widget buildDriverList(
    List<AssignmentsResponseEntity> items,
    ValueNotifier<AssignmentsResponseEntity?> selectedDriver,
    WidgetRef ref,
    BuildContext context,
  ) {
    return ListView.builder(
      key: const ValueKey('DriverList'),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListItemWidget(
          item: item,
          selectedValue: selectedDriver.value,
          selectionNotifier: selectedDriver,
          icon: Icons.drive_eta_outlined,
          iconColor: Colors.green,
          subtitle: (item.isResponsible ?? true) ? 'Trưởng' : 'Nhân viên',
          role: "driver",
        );
      },
    );
  }

  Widget buildPorterActionButtons(
    AssignmentsResponseEntity? selectedPorter,
    WidgetRef ref,
    BuildContext context,
    AvailableStaffEntities? datasPorter,
  ) {
    // Kiểm tra nếu có bất kỳ porter nào đã có isResponsible = true
    final bool hasResponsiblePorter =
        porterItems.any((item) => item.isResponsible == true);

    // Fetching porter data

    // Kiểm tra nếu danh sách assignmentInBooking của porter không rỗng
    final bool isPorterAssignmentExists =
        (datasPorter?.assignmentInBooking.length ?? 0) > 0;

    return Row(
      children: [
        Expanded(
          child: buildButton(
            onPressed: (selectedPorter != null && !hasResponsiblePorter)
                ? () async {
                    final currentState =
                        ref.read(reviewerUpdateControllerProvider);
                    if (currentState is AsyncLoading) return;
                    final confirmed = await _showConfirmationDialog(
                      context,
                      'Bốc vác',
                      selectedPorter.staffType,
                    );

                    if (confirmed == true) {
                      await ref
                          .read(reviewerUpdateControllerProvider.notifier)
                          .updateAssignStaffIsResponsibility(
                            assignmentId: selectedPorter.id,
                            context: context,
                            ref: ref,
                          );
                    }
                  }
                : null,
            label: 'Gán bốc vác trưởng',
            isPrimary: true,
            isEnabled: selectedPorter != null && !hasResponsiblePorter,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildButton(
            onPressed: !isPorterAssignmentExists
                ? () {
                    // Perform Chọn bốc vác khác action
                    context.router.push(
                      WorkShiftPorterUpdateScreenRoute(bookingId: bookingId),
                    );
                  }
                : null,
            label: 'Chọn bốc vác khác',
            isPrimary: false,
            isEnabled: !isPorterAssignmentExists,
          ),
        ),
      ],
    );
  }

  Widget buildDriverActionButtons(
    AssignmentsResponseEntity? selectedDriver,
    WidgetRef ref,
    BuildContext context,
    AvailableStaffEntities? datasDriver,
  ) {
    // Kiểm tra nếu có bất kỳ driver nào đã có isResponsible = true
    final bool hasResponsibleDriver =
        driverItems.any((item) => item.isResponsible == true);

    print(
        "tuan check assignmentInBooking  ${datasDriver?.assignmentInBooking.length ?? 0} ");
    // Kiểm tra nếu danh sách assignmentInBooking của driver không rỗng
    final bool isDriverAssignmentExists =
        (datasDriver?.assignmentInBooking.length ?? 0) > 0;

    return Row(
      children: [
        Expanded(
          child: buildButton(
            onPressed: (selectedDriver != null && !hasResponsibleDriver)
                ? () async {
                    final currentState =
                        ref.read(reviewerUpdateControllerProvider);
                    if (currentState is AsyncLoading) return;
                    final confirmed = await _showConfirmationDialog(
                      context,
                      'Tài xế',
                      selectedDriver.staffType,
                    );

                    if (confirmed == true) {
                      await ref
                          .read(reviewerUpdateControllerProvider.notifier)
                          .updateAssignStaffIsResponsibility(
                            assignmentId: selectedDriver.id,
                            context: context,
                            ref: ref,
                          );
                    }
                  }
                : null,
            label: 'Gán tài xế trưởng',
            isPrimary: true,
            isEnabled: selectedDriver != null && !hasResponsibleDriver,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildButton(
            onPressed: !isDriverAssignmentExists
                ? () {
                    // Perform Chọn tài xế khác action
                    context.router.push(
                      WorkShiftDriverUpdateScreenRoute(bookingId: bookingId),
                    );
                  }
                : null,
            label: 'Chọn tài xế khác',
            isPrimary: false,
            isEnabled: !isDriverAssignmentExists,
          ),
        ),
      ],
    );
  }

  Widget buildButton({
    required VoidCallback? onPressed,
    required String label,
    required bool isPrimary,
    required bool isEnabled,
  }) {
    Color backgroundColor;
    Color textColor;

    if (!isEnabled) {
      backgroundColor = AssetsConstants.whiteColor;
      textColor = Colors.grey.shade500;
    } else if (isPrimary) {
      backgroundColor = AssetsConstants.primaryDarker;
      textColor = Colors.white;
    } else {
      backgroundColor = AssetsConstants.primaryLighter.withOpacity(0.7);
      textColor = AssetsConstants.primaryDarker;
    }

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
