import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';

import 'package:movemate_staff/features/profile/presentation/widgets/input/custom_text.dart';
import 'package:movemate_staff/features/profile/presentation/widgets/input/input_item.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

@RoutePage()
class ContactScreen extends HookConsumerWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> formData = [
      {
        'label': 'Địa chỉ',
        'value': 'đường 3/2, quận 10, TP.Hồ Chí Minh',
        'icon': FontAwesomeIcons.users,
      },
      {
        'label': 'Email',
        'value': 'staff@gmail.com',
        'icon': FontAwesomeIcons.users,
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AssetsConstants.primaryMain,
        backButtonColor: AssetsConstants.whiteColor,
        showBackButton: true,
        title: "Thông tin liên hệ",
        centerTitle: true,
        iconSecond: Icons.home_outlined,
        onCallBackSecond: () {
          final tabsRouter = context.router.root
              .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
          if (tabsRouter != null) {
            tabsRouter.setActiveIndex(0);
            // Pop back to the TabViewScreen
            context.router.popUntilRouteWithName(TabViewScreenRoute.name);
          }
        },
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: formData.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: FormGroup(
                    label: field['label'],
                    icon: field['icon'],
                    child: CustomTextField(
                      value: field['value'],
                      onChanged: (newValue) {
                        // Xử lý khi giá trị thay đổi
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
