import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movemate_staff/features/job/presentation/widgets/jobcard/job_card.dart';
import 'package:movemate_staff/features/job/presentation/widgets/tabItem/tab_item.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

@RoutePage()
class JobScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: 'Công việc của tôi',
        showBackButton: true,
        centerTitle: false,
        backgroundColor: AssetsConstants.mainColor,
        backButtonColor: AssetsConstants.whiteColor,
        onCallBackFirst: () {
          context.router.pop();
        },
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TabItem(title: 'Tất cả việc', isActive: true),
                    TabItem(title: 'Việc sắp tới'),
                    TabItem(title: 'Việc đã hoàn thành'),
                    TabItem(title: 'Khác'),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Job Cards
              JobCard(
                title: 'Chemical Delivery',
                details: 'Truck No. | Tyre | Octane',
                location: 'Raiput to Delhi',
                status: 'Complete',
                statusColor: Colors.green,
                imageUrl:
                    'https://storage.googleapis.com/a1aa/image/QiBUUfN0wCyYXKwUzTc25upJXi2vmsmd1XU0Sqb5DWSJnelTA.jpg',
              ),
              JobCard(
                title: 'Chemical Delivery',
                details: 'Truck No. | Tyre | Octane',
                location: 'Raiput to Delhi',
                status: 'Ongoing',
                statusColor: Colors.yellow,
                imageUrl:
                    'https://storage.googleapis.com/a1aa/image/QiBUUfN0wCyYXKwUzTc25upJXi2vmsmd1XU0Sqb5DWSJnelTA.jpg',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
