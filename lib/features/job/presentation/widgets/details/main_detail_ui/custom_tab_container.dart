import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/job/presentation/controllers/reviewer_update_controller/reviewer_update_controller.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/main_detail_ui/tab_container/list_widget_item.dart';
import 'package:movemate_staff/features/profile/domain/entities/profile_entity.dart';
import 'package:movemate_staff/features/profile/presentation/controllers/profile_controller/profile_controller.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class CustomTabContainer extends HookConsumerWidget {
  final List<AssignmentsResponseEntity> porterItems;
  final List<AssignmentsResponseEntity> driverItems;

  const CustomTabContainer({
    Key? key,
    required this.porterItems,
    required this.driverItems,
  }) : super(key: key);

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

    //  final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));

    // final userProfile = useFetchObject<ProfileEntity>(
    //   function: (context) => ref
    //       .read(profileControllerProvider.notifier)
    //       .getUserInfo(item.userId, context),
    //   context: context,
    // );

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
    }, [porterItems, driverItems]);

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
                                  buildPorterActionButtons(
                                    selectedPorter.value,
                                    ref,
                                    context,
                                  ),
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
                                  buildDriverActionButtons(
                                    selectedDriver.value,
                                    ref,
                                    context,
                                  ),
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
        );
      },
    );
  }

  Widget buildPorterActionButtons(
    AssignmentsResponseEntity? selectedPorter,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: buildButton(
            onPressed: selectedPorter != null
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
            isEnabled: selectedPorter != null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildButton(
            onPressed: () {
              // Perform Chọn bốc vác khác action
            },
            label: 'Chọn bốc vác khác',
            isPrimary: false,
            isEnabled: true,
          ),
        ),
      ],
    );
  }

  Widget buildDriverActionButtons(
    AssignmentsResponseEntity? selectedDriver,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: buildButton(
            onPressed: selectedDriver != null
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
                              ref: ref);
                    }
                  }
                : null,
            label: 'Gán tài xế trưởng',
            isPrimary: true,
            isEnabled: selectedDriver != null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildButton(
            onPressed: () {
              // Perform Chọn tài xế khác action
            },
            label: 'Chọn tài xế khác',
            isPrimary: false,
            isEnabled: true,
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
