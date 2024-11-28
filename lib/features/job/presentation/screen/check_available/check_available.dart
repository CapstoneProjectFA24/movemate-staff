import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/job/domain/entities/available_staff_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/utils/commons/widgets/loading_overlay.dart';

class CheckAvailable extends HookConsumerWidget {
  final BookingResponseEntity job;

  const CheckAvailable({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetching driver data
    final stateDriver = ref.watch(driverControllerProvider);
    final driverController = ref.read(driverControllerProvider.notifier);

    final useFetchResultDriver = useFetchObject<AvailableStaffEntities>(
      function: (context) =>
          driverController.getDriverAvailableByBookingId(context, job.id),
      context: context,
    );

    final datasDriver = useFetchResultDriver.data;

    // Fetching porter data
    final statePorter = ref.watch(porterControllerProvider);
    final porterController = ref.read(porterControllerProvider.notifier);

    final useFetchResultPorter = useFetchObject<AvailableStaffEntities>(
      function: (context) =>
          porterController.getPorterAvailableByBookingId(context, job.id),
      context: context,
    );

    final datasPorter = useFetchResultPorter.data;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        LoadingOverlay(
          isLoading: stateDriver.isLoading || statePorter.isLoading,
          child: Container(),
        ),
        TextButton.icon(
          onPressed: () {
            // showDialog(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return Dialog(
            //       backgroundColor: Colors.transparent,
            //       child: Container(
            //         decoration: BoxDecoration(
            //           // Apply your gradient or styling here
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(16.0),
            //         ),
            //         child: Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             // Nội dung có thể cuộn
            //             Flexible(
            //               child: SingleChildScrollView(
            //                 child: Padding(
            //                   padding: const EdgeInsets.all(12.0),
            //                   child: Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       // For Drivers
            //                       if (datasDriver != null &&
            //                           datasDriver.staffInSlot.isNotEmpty &&
            //                           datasDriver.countStaffInslots >=
            //                               datasDriver.bookingNeedStaffs)
            //                         // Case 1: Staff in slot >= booking need staffs
            //                         Column(
            //                           crossAxisAlignment:
            //                               CrossAxisAlignment.start,
            //                           children: [
            //                             const Text(
            //                               'Tài xế dự bị cho đơn hàng',
            //                               style: TextStyle(
            //                                 fontWeight: FontWeight.bold,
            //                                 fontSize: 16,
            //                                 color: Colors.black,
            //                               ),
            //                             ),
            //                             const SizedBox(height: 16),
            //                             ListView.builder(
            //                               shrinkWrap: true,
            //                               physics:
            //                                   const NeverScrollableScrollPhysics(),
            //                               itemCount:
            //                                   datasDriver.countStaffInslots,
            //                               itemBuilder: (context, index) {
            //                                 final reviewer =
            //                                     datasDriver.staffInSlot[index];
            //                                 return ListTile(
            //                                   leading: CircleAvatar(
            //                                     backgroundImage: NetworkImage(
            //                                         reviewer.avatarUrl ?? ''),
            //                                   ),
            //                                   title: Text(
            //                                     reviewer.name ?? '',
            //                                     style: const TextStyle(
            //                                         color: Colors.black),
            //                                   ),
            //                                   subtitle: Text(
            //                                     reviewer.roleName ?? '',
            //                                     style: const TextStyle(
            //                                         color: Colors.black54),
            //                                   ),
            //                                   // trailing: IconButton(
            //                                   //   icon: const Icon(
            //                                   //     Icons.chat,
            //                                   //     color: Colors.blue,
            //                                   //     size: 20,
            //                                   //   ),
            //                                   //   onPressed: () {
            //                                   //     // Navigate to chat screen with driver
            //                                   //     navigateToChatScreen(
            //                                   //       context: context,
            //                                   //       userId:
            //                                   //           reviewer.id.toString(),
            //                                   //       name: reviewer.name ?? '',
            //                                   //       avatarUrl:
            //                                   //           reviewer.avatarUrl,
            //                                   //       role: 'driver',
            //                                   //     );
            //                                   //   },
            //                                   // ),
            //                                 );
            //                               },
            //                             ),
            //                           ],
            //                         )
            //                       else if (datasDriver != null &&
            //                           datasDriver.staffInSlot.isNotEmpty &&
            //                           datasDriver.staffInSlot.length <
            //                               datasDriver.bookingNeedStaffs)
            //                         // Case 2: Staff in slot < booking need staffs
            //                         // Column(
            //                         //   crossAxisAlignment:
            //                         //       CrossAxisAlignment.start,
            //                         //   children: [
            //                         //     Text(
            //                         //       'Tài xế khả dụng ngoài đơn hàng',
            //                         //       style: const TextStyle(
            //                         //         fontWeight: FontWeight.bold,
            //                         //         fontSize: 16,
            //                         //         color: Colors.black,
            //                         //       ),
            //                         //     ),
            //                         //     const SizedBox(height: 16),
            //                         //     ListView.builder(
            //                         //       shrinkWrap: true,
            //                         //       physics:
            //                         //           const NeverScrollableScrollPhysics(),
            //                         //       itemCount:
            //                         //           datasDriver.countOtherStaff,
            //                         //       itemBuilder: (context, index) {
            //                         //         final reviewer =
            //                         //             datasDriver.otherStaffs[index];
            //                         //         return ListTile(
            //                         //           leading: CircleAvatar(
            //                         //             backgroundImage: NetworkImage(
            //                         //                 reviewer.avatarUrl ?? ''),
            //                         //           ),
            //                         //           title: Text(
            //                         //             reviewer.name ?? '',
            //                         //             style: const TextStyle(
            //                         //                 color: Colors.black),
            //                         //           ),
            //                         //           subtitle: Text(
            //                         //             reviewer.roleName ?? '',
            //                         //             style: const TextStyle(
            //                         //                 color: Colors.black54),
            //                         //           ),
            //                         //           trailing: IconButton(
            //                         //             icon: const Icon(
            //                         //               Icons.chat,
            //                         //               color: Colors.blue,
            //                         //               size: 20,
            //                         //             ),
            //                         //             onPressed: () {
            //                         //               // Navigate to chat screen with driver
            //                         //               navigateToChatScreen(
            //                         //                 context: context,
            //                         //                 userId:
            //                         //                     reviewer.id.toString(),
            //                         //                 name: reviewer.name ?? '',
            //                         //                 avatarUrl:
            //                         //                     reviewer.avatarUrl,
            //                         //                 role: 'driver',
            //                         //               );
            //                         //             },
            //                         //           ),
            //                         //         );
            //                         //       },
            //                         //     ),
            //                         //   ],
            //                         // ),

            //                         // For Porters
            //                         if (datasPorter != null &&
            //                             datasPorter.staffInSlot.isNotEmpty &&
            //                             datasPorter.staffInSlot.length >=
            //                                 datasPorter.bookingNeedStaffs)
            //                           // Case 1: Staff in slot >= booking need staffs
            //                           Column(
            //                             crossAxisAlignment:
            //                                 CrossAxisAlignment.start,
            //                             children: [
            //                               const SizedBox(height: 16),
            //                               const Text(
            //                                 'Khuân vác dự bị cho đơn hàng',
            //                                 style: TextStyle(
            //                                   fontWeight: FontWeight.bold,
            //                                   fontSize: 16,
            //                                   color: Colors.black,
            //                                 ),
            //                               ),
            //                               const SizedBox(height: 16),
            //                               ListView.builder(
            //                                 shrinkWrap: true,
            //                                 physics:
            //                                     const NeverScrollableScrollPhysics(),
            //                                 itemCount:
            //                                     datasPorter.countStaffInslots,
            //                                 itemBuilder: (context, index) {
            //                                   final reviewer = datasPorter
            //                                       .staffInSlot[index];
            //                                   return ListTile(
            //                                     leading: CircleAvatar(
            //                                       backgroundImage: NetworkImage(
            //                                           reviewer.avatarUrl ?? ''),
            //                                     ),
            //                                     title: Text(
            //                                       reviewer.name ?? '',
            //                                       style: const TextStyle(
            //                                           color: Colors.black),
            //                                     ),
            //                                     subtitle: Text(
            //                                       reviewer.roleName ?? '',
            //                                       style: const TextStyle(
            //                                           color: Colors.black54),
            //                                     ),
            //                                     // trailing: IconButton(
            //                                     //   icon: const Icon(
            //                                     //     Icons.chat,
            //                                     //     color: Colors.blue,
            //                                     //     size: 20,
            //                                     //   ),
            //                                     //   onPressed: () {
            //                                     //     // Navigate to chat screen with porter
            //                                     //     navigateToChatScreen(
            //                                     //       context: context,
            //                                     //       userId:
            //                                     //           reviewer.id.toString(),
            //                                     //       name: reviewer.name ?? '',
            //                                     //       avatarUrl:
            //                                     //           reviewer.avatarUrl,
            //                                     //       role: 'porter',
            //                                     //     );
            //                                     //   },
            //                                     // ),
            //                                   );
            //                                 },
            //                               ),
            //                             ],
            //                           )
            //                         else if (datasPorter != null &&
            //                             datasPorter.staffInSlot.isNotEmpty &&
            //                             datasPorter.staffInSlot.length <
            //                                 datasPorter.bookingNeedStaffs)
            //                           // Case 2: Staff in slot < booking need staffs
            //                           // Column(
            //                           //   crossAxisAlignment:
            //                           //       CrossAxisAlignment.start,
            //                           //   children: [
            //                           //     const SizedBox(height: 16),
            //                           //     Text(
            //                           //       'Khuân vác khả dụng ngoài đơn hàng',
            //                           //       style: const TextStyle(
            //                           //         fontWeight: FontWeight.bold,
            //                           //         fontSize: 16,
            //                           //         color: Colors.black,
            //                           //       ),
            //                           //     ),
            //                           //     const SizedBox(height: 16),
            //                           //     ListView.builder(
            //                           //       shrinkWrap: true,
            //                           //       physics:
            //                           //           const NeverScrollableScrollPhysics(),
            //                           //       itemCount:
            //                           //           datasPorter.countOtherStaff,
            //                           //       itemBuilder: (context, index) {
            //                           //         final reviewer =
            //                           //             datasPorter.otherStaffs[index];
            //                           //         return ListTile(
            //                           //           leading: CircleAvatar(
            //                           //             backgroundImage: NetworkImage(
            //                           //                 reviewer.avatarUrl ?? ''),
            //                           //           ),
            //                           //           title: Text(
            //                           //             reviewer.name ?? '',
            //                           //             style: const TextStyle(
            //                           //                 color: Colors.black),
            //                           //           ),
            //                           //           subtitle: Text(
            //                           //             reviewer.roleName ?? '',
            //                           //             style: const TextStyle(
            //                           //                 color: Colors.black54),
            //                           //           ),
            //                           //           trailing: IconButton(
            //                           //             icon: const Icon(
            //                           //               Icons.chat,
            //                           //               color: Colors.blue,
            //                           //               size: 20,
            //                           //             ),
            //                           //             onPressed: () {
            //                           //               // Navigate to chat screen with porter
            //                           //               navigateToChatScreen(
            //                           //                 context: context,
            //                           //                 userId:
            //                           //                     reviewer.id.toString(),
            //                           //                 name: reviewer.name ?? '',
            //                           //                 avatarUrl:
            //                           //                     reviewer.avatarUrl,
            //                           //                 role: 'porter',
            //                           //               );
            //                           //             },
            //                           //           ),
            //                           //         );
            //                           //       },
            //                           //     ),
            //                           //   ],
            //                           // ),

            //                           // Nếu không có nhân viên khả dụng
            //                           if ((datasDriver
            //                                       .staffInSlot.isEmpty) &&
            //                               (datasPorter.staffInSlot.isEmpty))
            //                             const Text(
            //                               'Không có nhân viên khả dụng.',
            //                               style: TextStyle(color: Colors.black),
            //                             ),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             // Nút "Đóng" cố định
            //             Padding(
            //               padding: const EdgeInsets.all(16.0),
            //               child: Align(
            //                 alignment: Alignment.centerRight,
            //                 child: ElevatedButton(
            //                   onPressed: () {
            //                     Navigator.of(context).pop();
            //                   },
            //                   style: ElevatedButton.styleFrom(
            //                     backgroundColor: Colors.orange,
            //                   ),
            //                   child: const Text('Đóng',
            //                       style: TextStyle(color: Colors.white)),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     );
            //   },
            // );
          },
          icon: (datasDriver?.isSuccessed == true ||
                  datasPorter?.isSuccessed == true)
              ? const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 14,
                )
              : const Icon(
                  Icons.circle_outlined,
                  color: Colors.red,
                  size: 14,
                ),
          label: Text(
            (datasDriver?.isSuccessed == true ||
                    datasPorter?.isSuccessed == true)
                ? 'Đơn hàng khả dụng'
                : 'Đơn hàng không khả dụng',
            style: TextStyle(
              color: (datasDriver?.isSuccessed == true ||
                      datasPorter?.isSuccessed == true)
                  ? Colors.green
                  : Colors.red,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// Hàm điều hướng tới màn hình chat cho cả Driver và Porter
void navigateToChatScreen({
  required BuildContext context,
  required String userId,
  required String name,
  required String? avatarUrl,
  required String role, // 'driver' hoặc 'porter'
}) {
  if (role == 'driver') {
    context.router.push(
      ChatWithDriverScreenRoute(
        driverId: userId,
        driverName: name,
        driverAvatar: avatarUrl,
      ),
    );
  } else if (role == 'porter') {
    context.router.push(
      ChatWithPorterScreenRoute(
        porterId: userId,
        porterName: name,
        porterAvatar: avatarUrl,
      ),
    );
  }
}
