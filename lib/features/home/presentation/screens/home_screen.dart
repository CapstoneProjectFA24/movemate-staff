import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/home/presentation/widgets/dash_board_card/dash_board_card.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/providers/common_provider.dart';

@RoutePage()
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider);
    const List<String> validRoles = [
      'admin',
      'manager',
      'reviewer',
      'driver',
      'porter',
    ];

    bool isValidRoleName(String? roleType) {
      if (roleType == null) return false;
      return validRoles.contains(roleType.toLowerCase());
    }

    final isReviewer = user?.roleName.type.toUpperCase() == 'REVIEWER' ?? false;
    final isDriver = user?.roleName.type == 'DRIVER' ?? false;
    final isPorter = user?.roleName.type == 'PORTER' ?? false;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.pexels.com/photos/2199293/pexels-photo-2199293.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // const Positioned(
            //   top: 50,
            //   right: 20,
            //   child: Text(
            //     'Địa chỉ hiện tại: HCM - Việt Nam',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 14,
            //       fontWeight: FontWeight.w400,
            //       shadows: [
            //         Shadow(
            //           offset: Offset(1.0, 1.0),
            //           blurRadius: 3.0,
            //           color: Color.fromARGB(255, 0, 0, 0),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            Positioned(
              left: 20,
              top: 100,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHÀO MỪNG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${user?.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Chức vụ: ${user?.roleName.type}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Mã nhân viên: #${user?.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 20,
              top: 220,
              child: Icon(
                Icons.notifications,
                color: Colors.white,
                size: 30,
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.65, // Chiều cao ban đầu là 40% màn hình
              minChildSize: 0.3, // Chiều cao tối thiểu
              maxChildSize: 0.8, // Chiều cao tối đa khi kéo lên
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController, // Cho phép cuộn nội dung
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        // DashboardCard(
                        //   icon: Icons.add_circle,
                        //   color: Colors.pinkAccent,
                        //   title: 'Công Việc Mới',
                        //   description: 'Bắt đầu chuyến đi ',
                        //   onTap: () {
                        //     // context.router.push(const JobScreenRoute());
                        //     AutoTabsRouter.of(context).setActiveIndex(1);
                        //   },
                        // ),
                        if (isReviewer)
                          DashboardCard(
                            icon: Icons.add_to_home_screen_rounded,
                            color: Colors.orange,
                            title: 'Đánh giá tại nhà',
                            onTap: () {
                              context.router
                                  .push(JobScreenRoute(isReviewOnline: false));
                            },
                          ),
                        if (isReviewer)
                          DashboardCard(
                            icon: Icons.online_prediction_rounded,
                            color: Colors.greenAccent,
                            title: 'Đánh giá trực tuyến',
                            onTap: () {
                              context.router
                                  .push(JobScreenRoute(isReviewOnline: true));
                            },
                          ),
                        if (isPorter)
                          DashboardCard(
                            icon: Icons.tab,
                            color: Colors.orange,
                            title: 'Công việc bốc vác',
                            onTap: () {
                              context.router.push(const PorterScreenRoute());
                            },
                          ),

                        // DashboardCard(
                        //   icon: Icons.money,
                        //   color: Colors.green,
                        //   title: 'Chi Phí',
                        //   description: 'Theo dõi chi phí của bạn.',
                        //   onTap: () {
                        //     context.router.push(const JobScreenRoute(isReviewOnline: trrue));
                        //   },
                        // ),

                        DashboardCard(
                          icon: Icons.notification_add_outlined,
                          color: const Color.fromARGB(255, 86, 76, 175),
                          title: 'Yêu cầu',
                          onTap: () {
                            context.router.push(const OrderScreenRoute());
                          },
                        ),
                        if (isDriver)
                          DashboardCard(
                            icon: Icons.local_shipping,
                            color: AssetsConstants.primaryMain,
                            title: 'Tài xế',
                            onTap: () {
                              context.router.push(const DriversScreenRoute());
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
