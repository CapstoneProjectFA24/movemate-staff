import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class CustomTabContainer extends HookConsumerWidget {
  final List<AssignmentsResponseEntity> porterItems;
  final List<AssignmentsResponseEntity> driverItems;

  const CustomTabContainer({
    Key? key,
    required this.porterItems,
    required this.driverItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = useState<String>('Porter');
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
                        child: selectedTab.value == 'Porter'
                            ? buildPorterList(porterItems, selectedPorter)
                            : buildDriverList(driverItems, selectedDriver),
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildActionButtons(
                      selectedTab.value,
                      selectedPorter.value,
                      selectedDriver.value,
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
            tabName: 'Porter',
            icon: Icons.person_outlined,
            iconColor: Colors.blue,
          ),
          buildTabItem(
            selectedTab: selectedTab,
            tabName: 'Driver',
            icon: Icons.drive_eta_outlined,
            iconColor: Colors.green,
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

  Widget buildListItem({
    required AssignmentsResponseEntity item,
    required AssignmentsResponseEntity? selectedValue,
    required ValueNotifier<AssignmentsResponseEntity?> selectionNotifier,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
  }) {
    final isSelected = selectedValue == item;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          selectionNotifier.value = isSelected ? null : item;
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.staffType, // Display appropriate field from AssignmentsResponseEntity
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<AssignmentsResponseEntity>(
                value: item,
                groupValue: selectedValue,
                onChanged: (value) {
                  selectionNotifier.value = isSelected ? null : value;
                },
                activeColor: Colors.blue,
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
  ) {
    return ListView.builder(
      key: const ValueKey('PorterList'),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return buildListItem(
          item: items[index],
          selectedValue: selectedPorter.value,
          selectionNotifier: selectedPorter,
          icon: Icons.person_outlined,
          iconColor: Colors.blue,
          subtitle: 'Thông tin Porter',
        );
      },
    );
  }

  Widget buildDriverList(
    List<AssignmentsResponseEntity> items,
    ValueNotifier<AssignmentsResponseEntity?> selectedDriver,
  ) {
    return ListView.builder(
      key: const ValueKey('DriverList'),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return buildListItem(
          item: items[index],
          selectedValue: selectedDriver.value,
          selectionNotifier: selectedDriver,
          icon: Icons.drive_eta_outlined,
          iconColor: Colors.green,
          subtitle: 'Thông tin Driver',
        );
      },
    );
  }

  Widget buildActionButtons(
    String selectedTab,
    AssignmentsResponseEntity? selectedPorter,
    AssignmentsResponseEntity? selectedDriver,
  ) {
    String primaryLabel;
    String secondaryLabel;
    VoidCallback? primaryAction;
    VoidCallback? secondaryAction;

    switch (selectedTab) {
      case 'Porter':
        primaryLabel = 'Gán bốc vác';
        secondaryLabel = 'Chọn bốc vác khác';
        primaryAction = selectedPorter != null
            ? () {
                // Perform Gán bốc vác action
              }
            : null;
        secondaryAction = selectedPorter != null || selectedPorter == null
            ? () {
                // Perform Chọn bốc vác khác action
              }
            : null;
        break;

      case 'Driver':
        primaryLabel = 'Gán tài xế';
        secondaryLabel = 'Chọn tài xế khác';
        primaryAction = selectedDriver != null
            ? () {
                // Perform Gán tài xế action
              }
            : null;
        secondaryAction = selectedDriver != null || selectedDriver == null
            ? () {
                // Perform Chọn tài xế khác action
              }
            : null;
        break;

      default:
        primaryLabel = 'Gán';
        secondaryLabel = 'Chọn khác';
        primaryAction = () {
          // Perform Gán chung action
        };
        secondaryAction = () {
          // Perform Chọn khác action
        };
        break;
    }

    return Row(
      children: [
        Expanded(
          child: buildButton(
            onPressed: primaryAction,
            label: primaryLabel,
            isPrimary: true,
            isEnabled: primaryAction != null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildButton(
            onPressed: secondaryAction,
            label: secondaryLabel,
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
      backgroundColor = Colors.black.withOpacity(0.1);
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
