import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/features/home/presentation/widgets/background_image.dart';
import 'package:movemate_staff/features/home/presentation/widgets/header.dart';
import 'package:movemate_staff/features/home/presentation/widgets/promotion_banner.dart';
import 'package:movemate_staff/features/home/presentation/widgets/promotion_section.dart';
import 'package:movemate_staff/features/home/presentation/widgets/service_section.dart';
import 'package:movemate_staff/features/home/presentation/widgets/service_selector.dart';
import 'package:movemate_staff/features/home/presentation/widgets/vehicle_carousel.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: const Center(
        child: Text('Home PackageDetailScreen!'),
      ),
    );
  }
}
