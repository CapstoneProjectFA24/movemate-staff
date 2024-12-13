import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/porter/presentation/screens/porter_screen/porter_screen.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/porter_screen_widget/search_time_box.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';

final optionsPorterSystemStatus = [
  BookingStatusType.coming,
  BookingStatusType.inProgress,
  BookingStatusType.paused,
  BookingStatusType.completed,
];
final refreshOrderList = StateProvider.autoDispose<bool>(
  (ref) => true,
);

final filterPorterSystemStatus = StateProvider.autoDispose<BookingStatusType>(
  (ref) => BookingStatusType.coming,
);
showPorterCustomBottomSheet({
  required BuildContext context,
  required Size size,
  required VoidCallback onCallback,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      String getTitleSystemStatus(BookingStatusType type) {
        switch (type) {
          case BookingStatusType.coming:
            return 'Đơn vận chuyển mới';
          case BookingStatusType.inProgress:
            return 'Đang trong tiến trình';
          case BookingStatusType.paused:
            return 'Chờ khách hàng kiểm định';
          case BookingStatusType.completed:
            return 'Hoàn thành';
          default:
            return 'Unknow!';
        }
      }

      return Consumer(
        builder: (_, ref, __) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AssetsConstants.defaultPadding - 10.0,
            ),
            height: size.height * 0.7, // Updated to 70% of screen height
            width: size.width * 1,
            decoration: const BoxDecoration(
              color: AssetsConstants.scaffoldColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AssetsConstants.defaultBorder + 10.0),
                topRight: Radius.circular(AssetsConstants.defaultBorder + 10.0),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.filter_alt_rounded,
                            color: AssetsConstants.blackColor,
                          ),
                          SizedBox(
                            width: size.width * 0.02,
                          ),
                          const LabelText(
                            content: 'Lọc',
                            size: AssetsConstants.defaultFontSize - 10.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          onCallback();
                          context.router.pop();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AssetsConstants.blackColor,
                        ),
                      )
                    ],
                  ),
                  SearchTimeBox(
                    searchType: SearchDateType.bookingsearch,
                    dateFrom: ref.watch(bookingPorterDateFrom),
                    dateTo: ref.watch(bookingPorterDateTo),
                    borderColor: AssetsConstants.borderColor,
                    title: 'Tra cứu thời gian thực thi',
                    icon: Icons.shopping_bag_rounded,
                    contentColor: AssetsConstants.blackColor,
                    backGroundColor: AssetsConstants.whiteColor,
                    onCallBack: () {
                      onCallback();
                      context.router.pop();
                    },
                  ),
                  SizedBox(height: size.height * 0.01),
                  const LabelText(
                    content: 'Trạng thái hệ thống',
                    fontWeight: FontWeight.w600,
                    size: AssetsConstants.defaultFontSize - 10.0,
                  ),
                  SizedBox(height: size.height * 0.01),
                  Container(
                    decoration: BoxDecoration(
                      color: AssetsConstants.primaryLight,
                      border: Border.all(
                        color: AssetsConstants.blue2,
                      ),
                      borderRadius: BorderRadius.circular(
                        AssetsConstants.defaultBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        RadioListTile(
                          title: LabelText(
                            content: getTitleSystemStatus(
                              BookingStatusType.coming,
                            ),
                            size: AssetsConstants.defaultFontSize - 10.0,
                          ),
                          value: optionsPorterSystemStatus[0],
                          groupValue: ref.watch(filterPorterSystemStatus),
                          onChanged: (val) {
                            ref.read(filterPorterSystemStatus.notifier).update(
                                (state) => optionsPorterSystemStatus[0]);
                          },
                          activeColor: AssetsConstants.blue2,
                        ),
                        RadioListTile(
                          title: LabelText(
                            content: getTitleSystemStatus(
                              BookingStatusType.inProgress,
                            ),
                            size: AssetsConstants.defaultFontSize - 10.0,
                          ),
                          value: optionsPorterSystemStatus[1],
                          groupValue: ref.watch(filterPorterSystemStatus),
                          onChanged: (val) {
                            ref.read(filterPorterSystemStatus.notifier).update(
                                (state) => optionsPorterSystemStatus[1]);
                          },
                          activeColor: AssetsConstants.blue2,
                        ),
                        RadioListTile(
                          title: LabelText(
                            content: getTitleSystemStatus(
                              BookingStatusType.paused,
                            ),
                            size: AssetsConstants.defaultFontSize - 10.0,
                          ),
                          value: optionsPorterSystemStatus[2],
                          groupValue: ref.watch(filterPorterSystemStatus),
                          onChanged: (val) {
                            ref.read(filterPorterSystemStatus.notifier).update(
                                (state) => optionsPorterSystemStatus[2]);
                          },
                          activeColor: AssetsConstants.blue2,
                        ),
                        RadioListTile(
                          title: LabelText(
                            content: getTitleSystemStatus(
                                BookingStatusType.completed),
                            size: AssetsConstants.defaultFontSize - 10.0,
                          ),
                          value: optionsPorterSystemStatus[3],
                          groupValue: ref.watch(filterPorterSystemStatus),
                          onChanged: (val) {
                            ref.read(filterPorterSystemStatus.notifier).update(
                                (state) => optionsPorterSystemStatus[3]);
                          },
                          activeColor: AssetsConstants.blue2,
                        ),
                      ],
                    ),
                  
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
