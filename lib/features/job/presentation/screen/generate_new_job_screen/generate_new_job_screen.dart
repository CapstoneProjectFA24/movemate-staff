import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/address.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/booking_code.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/column.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/image.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/infoItem.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/item.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/policies.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/priceItem.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/summary.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/popup.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/image.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/label.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/number_input.dart';
import 'package:movemate_staff/features/job/presentation/widgets/function/text_input.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:animate_do/animate_do.dart';

@RoutePage()
class GenerateNewJobScreen extends HookConsumerWidget {
  const GenerateNewJobScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(
        backgroundColor: AssetsConstants.primaryMain,
        backButtonColor: AssetsConstants.whiteColor,
        showBackButton: true,
        title: "Cập nhật Thông tin đơn hàng",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  width:
                      380, // Equivalent to w-80 in Tailwind CSS (80 * 4 = 320)
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Date/Time Input Field
                      buildLabel("Ngày/ giờ"),
                      buildTextInput(
                        hintText: "Chọn ngày/ giờ",
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),
                      // Start Location Input Field
                      buildLabel("Địa điểm bắt đầu chuyển"),
                      buildTextInput(
                        hintText: "Địa điểm",
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      // End Location Input Field
                      buildLabel("Địa điểm chuyển đến"),
                      buildTextInput(
                        hintText: "Địa điểm",
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      // House Type Dropdown
                      buildLabel("Loại nhà"),
                      buildDropdown(
                        items: ['Nhà riêng'],
                        icon: Icons.arrow_drop_down,
                      ),
                      const SizedBox(height: 16),
                      // Number of Bedrooms and Floors
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Số phòng ngủ"),
                                buildNumberInput(initialValue: "1"),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("Số tầng"),
                                buildNumberInput(initialValue: "1"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Customer-Provided Images
                      buildLabel("Hình ảnh khách hàng cung cấp"),
                      buildImageRow(),
                      const SizedBox(height: 16),
                      // Vehicle Type Dropdown
                      buildLabel("Loại xe"),
                      buildDropdown(
                        items: ['Xe tải 500kg'],
                        icon: Icons.arrow_drop_down,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Additional info section
                const Padding(
                  padding: EdgeInsets.only(left: 14.0, top: 14.0),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        "Số lượng bốc vác",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thời gian ước lượng hoàn thành: 3 tiếng",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "Thời gian ước lượng kết thúc: ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "11h30",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
