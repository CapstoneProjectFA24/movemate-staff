// lib/features/job/presentation/widgets/custom_tab_container.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

class CustomTabContainer extends HookConsumerWidget {
  final List<String> porterItems; // Danh sách cho Porter
  final List<String> driverItems; // Danh sách cho Driver

  const CustomTabContainer({
    Key? key,
    required this.porterItems,
    required this.driverItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Quản lý trạng thái tab hiện tại
    final selectedTab = useState<String>('Porter');
    // Quản lý trạng thái chọn Porter và Driver
    final selectedPorter = useState<String?>(null);
    final selectedDriver = useState<String?>(null);

    return Container(
      height: 400, // Chiều cao cố định cho container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Buttons
            Row(
              children: [
                // Tab Porter
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      selectedTab.value = 'Porter';
                      // Không reset selection khi chuyển tab
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selectedTab.value == 'Porter'
                                ? Colors.blue
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Porter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: selectedTab.value == 'Porter'
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tab Driver
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      selectedTab.value = 'Driver';
                      // Không reset selection khi chuyển tab
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selectedTab.value == 'Driver'
                                ? Colors.blue
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.drive_eta,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Driver',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: selectedTab.value == 'Driver'
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Hiển thị danh sách dựa trên tab được chọn với cuộn dọc
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: selectedTab.value == 'Porter'
                    ? _buildPorterList(porterItems, selectedPorter)
                    : _buildDriverList(driverItems, selectedDriver),
              ),
            ),
            const SizedBox(height: 10),
            // Hiển thị các button điều kiện
            _buildConditionalButtons(
                selectedTab.value, selectedPorter.value, selectedDriver.value),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng danh sách Porter với cuộn dọc và Radio Button
  Widget _buildPorterList(
      List<String> items, ValueNotifier<String?> selectedPorter) {
    return ListView.builder(
      key: const ValueKey('PorterList'),
      scrollDirection: Axis.vertical, // Cuộn dọc
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: LabelText(
              content: item,
              size: 16,
              fontWeight: FontWeight.bold,
            ),
            subtitle: const LabelText(
              content: 'Thông tin bổ sung về Porter',
              size: 14,
              fontWeight: FontWeight.normal,
            ),
            trailing: Radio<String>(
              value: item,
              groupValue: selectedPorter.value,
              onChanged: (value) {
                // Nếu người dùng nhấn vào Radio Button đã chọn, bỏ chọn nó
                if (selectedPorter.value == value) {
                  selectedPorter.value = null;
                } else {
                  selectedPorter.value = value;
                }
              },
            ),
            onTap: () {
              // Nếu người dùng nhấn vào ListTile đã chọn, bỏ chọn nó
              if (selectedPorter.value == item) {
                selectedPorter.value = null;
              } else {
                selectedPorter.value = item;
              }
            },
          ),
        );
      },
    );
  }

  // Widget xây dựng danh sách Driver với cuộn dọc và Radio Button
  Widget _buildDriverList(
      List<String> items, ValueNotifier<String?> selectedDriver) {
    return ListView.builder(
      key: const ValueKey('DriverList'),
      scrollDirection: Axis.vertical, // Cuộn dọc
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: ListTile(
            leading: const Icon(Icons.drive_eta, color: Colors.green),
            title: LabelText(
              content: item,
              size: 16,
              fontWeight: FontWeight.bold,
            ),
            subtitle: const LabelText(
              content: 'Thông tin bổ sung về Driver',
              size: 14,
              fontWeight: FontWeight.normal,
            ),
            trailing: Radio<String>(
              value: item,
              groupValue: selectedDriver.value,
              onChanged: (value) {
                // Nếu người dùng nhấn vào Radio Button đã chọn, bỏ chọn nó
                if (selectedDriver.value == value) {
                  selectedDriver.value = null;
                } else {
                  selectedDriver.value = value;
                }
              },
            ),
            onTap: () {
              // Nếu người dùng nhấn vào ListTile đã chọn, bỏ chọn nó
              if (selectedDriver.value == item) {
                selectedDriver.value = null;
              } else {
                selectedDriver.value = item;
              }
            },
          ),
        );
      },
    );
  }

  // Widget để hiển thị các button điều kiện
  Widget _buildConditionalButtons(
      String selectedTab, String? selectedPorter, String? selectedDriver) {
    if (selectedTab == 'Porter') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Button 1: Enable nếu có Porter được chọn, disable nếu không
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  AssetsConstants.primaryLighter.withOpacity(0.7)),
            ),
            onPressed: selectedPorter != null
                ? () {
                    // Xử lý khi nhấn Button 1
                    // Ví dụ: Gửi yêu cầu cho Porter đã chọn
                    print('Button 1 pressed for $selectedPorter');
                    // Thêm logic của bạn ở đây
                  }
                : null, // Disable nếu không có Porter được chọn
            child: const LabelText(
              content: 'Button 1',
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryDarker,
            ),
          ),
          // Button 2: Luôn luôn được enable
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  AssetsConstants.primaryLighter.withOpacity(0.7)),
            ),
            onPressed: () {
              // Xử lý khi nhấn Button 2
              // Ví dụ: Hủy chọn Porter đã chọn hoặc thực hiện hành động khác
              print('Button 2 pressed');
              // Thêm logic của bạn ở đây
            },
            child: const LabelText(
              content: 'Button 2',
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryDarker,
            ),
          ),
        ],
      );
    } else if (selectedTab == 'Driver') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Button 3: Enable nếu có Driver được chọn, disable nếu không
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  AssetsConstants.primaryLighter.withOpacity(0.7)),
            ),
            onPressed: selectedDriver != null
                ? () {
                    // Xử lý khi nhấn Button 3
                    // Ví dụ: Gửi yêu cầu cho Driver đã chọn
                    print('Button 3 pressed for $selectedDriver');
                    // Thêm logic của bạn ở đây
                  }
                : null, // Disable nếu không có Driver được chọn
            child: const LabelText(
              content: 'Button 3',
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryDarker,
            ),
          ),
          // Button 4: Luôn luôn được enable
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  AssetsConstants.primaryLighter.withOpacity(0.7)),
            ),
            onPressed: () {
              // Xử lý khi nhấn Button 4
              // Ví dụ: Hủy chọn Driver đã chọn hoặc thực hiện hành động khác
              print('Button 4 pressed');
              // Thêm logic của bạn ở đây
            },
            child: const LabelText(
              content: 'Button 4',
              size: 16,
              fontWeight: FontWeight.bold,
              color: AssetsConstants.primaryDarker,
            ),
          ),
        ],
      );
    } else {
      return const SizedBox(); // Không hiển thị gì nếu không có tab nào được chọn
    }
  }
}
