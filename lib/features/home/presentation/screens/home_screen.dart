import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


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
