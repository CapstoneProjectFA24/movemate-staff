// lib/features/job/presentation/widgets/custom_tab_container.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

/// Widget CustomTabContainer hiển thị các tab "Porter" và "Driver" kèm theo danh sách và các hành động tương ứng.
class CustomTabContainer extends HookConsumerWidget {
  final List<String> porterItems;
  final List<String> driverItems;

  const CustomTabContainer({
    super.key,
    required this.porterItems,
    required this.driverItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = useState<String>('Porter');
    final selectedPorter = useState<String?>(null);
    final selectedDriver = useState<String?>(null);

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

  /// Xây dựng thanh tab với hai tab "Porter" và "Driver".
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

  /// Xây dựng một tab đơn lẻ với biểu tượng và tên tab.
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

  /// Xây dựng một mục danh sách có thể chọn được, hiển thị thông tin về Porter hoặc Driver.
  Widget buildListItem({
    required String item,
    required String? selectedValue,
    required ValueNotifier<String?> selectionNotifier,
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
                      item,
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
              Radio<String>(
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

  /// Xây dựng danh sách các porter.
  Widget buildPorterList(
    List<String> items,
    ValueNotifier<String?> selectedPorter,
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

  /// Xây dựng danh sách các driver.
  Widget buildDriverList(
    List<String> items,
    ValueNotifier<String?> selectedDriver,
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

  /// Xây dựng các nút hành động ở dưới cùng của container.
  Widget buildActionButtons(
    String selectedTab,
    String? selectedPorter,
    String? selectedDriver,
  ) {
    // Xác định nhãn và hành động dựa trên tab được chọn
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
                // Thực hiện hành động Gán bốc vác
              }
            : null;
        //luôn luôn hiển thị nút chọn bốc vác khác
        secondaryAction = selectedPorter != null || selectedPorter == null
            ? () {
                // Thực hiện hành động Chọn bốc vác khác
              }
            : null;
        break;

      case 'Driver':
        primaryLabel = 'Gán tài xế';
        secondaryLabel = 'Chọn tài xế khác';
        primaryAction = selectedDriver != null
            ? () {
                // Thực hiện hành động Gán tài xế
              }
            : null;
        //luôn luôn hiển thị nút chọn tài xế khác
        secondaryAction = selectedDriver != null || selectedDriver == null
            ? () {
                // Thực hiện hành động Chọn tài xế khác
              }
            : null;
        break;

      default:
        primaryLabel = 'Gán';
        secondaryLabel = 'Chọn khác';
        primaryAction = () {
          // Thực hiện hành động Gán chung
        };
        secondaryAction = () {
          // Thực hiện hành động Chọn khác
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

  /// Xây dựng một nút tùy chỉnh với các thuộc tính được định nghĩa.
  Widget buildButton({
    required VoidCallback? onPressed,
    required String label,
    required bool isPrimary,
    required bool isEnabled,
  }) {
    // Xác định màu nền và màu chữ dựa trên trạng thái nút
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
