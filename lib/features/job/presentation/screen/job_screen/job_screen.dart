import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/features/job/presentation/widgets/jobcard/job_card.dart';
import 'package:movemate_staff/features/job/presentation/widgets/jobcard/job_list.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

// model

@RoutePage()
class JobScreen extends HookConsumerWidget {
  const JobScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);

    final List<JobModel> fakeJobs = [
      JobModel(
        title: 'Chemical Delivery',
        details: 'Truck No. | Tyre | Octane',
        location: 'Raiput to Delhi',
        status: 'Complete',
        statusColor: Colors.green,
        imageUrl:
            'https://storage.googleapis.com/a1aa/image/QiBUUfN0wCyYXKwUzTc25upJXi2vmsmd1XU0Sqb5DWSJnelTA.jpg',
      ),
      JobModel(
        title: 'Furniture Moving',
        details: 'Van No. | Furniture Type',
        location: 'Mumbai to Pune',
        status: 'Ongoing',
        statusColor: Colors.yellow,
        imageUrl:
            'https://storage.googleapis.com/a1aa/image/QiBUUfN0wCyYXKwUzTc25upJXi2vmsmd1XU0Sqb5DWSJnelTA.jpg',
      ),
      JobModel(
        title: 'Electronics Shipment',
        details: 'Truck No. | Electronics',
        location: 'Bangalore to Chennai',
        status: 'Pending',
        statusColor: Colors.orange,
        imageUrl:
            'https://storage.googleapis.com/a1aa/image/QiBUUfN0wCyYXKwUzTc25upJXi2vmsmd1XU0Sqb5DWSJnelTA.jpg',
      ),
      JobModel(
        title: 'Food Delivery',
        details: 'Bike No. | Perishables',
        location: 'Local City Delivery',
        status: 'Complete',
        statusColor: Colors.green,
        imageUrl:
            'https://storage.googleapis.com/a1aa/image/QiBUUfN0wCyYXKwUzTc25upJXi2vmsmd1XU0Sqb5DWSJnelTA.jpg',
      ),
    ];

    List<String> tabs = [
      // "Tất cả việc",
      "Việc sắp tới",
      "Việc đã hoàn thành",
      "Khác"
    ];

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).unfocus();
      });
      return null;
    }, []);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        backgroundColor: AssetsConstants.mainColor,
        title: "Công việc của tôi",
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              indicatorColor: Colors.orange,
              indicatorWeight: 2,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // JobList(jobs: fakeJobs),
          JobList(
            jobs: fakeJobs.where((j) => j.status == 'Pending').toList(),
          ),
          JobList(
            jobs: fakeJobs.where((j) => j.status == 'Complete').toList(),
          ),
          JobList(
            jobs: fakeJobs.where((j) => j.status == 'Complete').toList(),
          ),
        ],
      ),
    );
  }
}
