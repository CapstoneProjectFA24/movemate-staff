import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/features/order/presentation/widgets/Profile_card.dart';
import 'package:movemate_staff/features/order/presentation/widgets/TabView.dart';
import 'package:movemate_staff/features/order/presentation/widgets/card_footer_schedule.dart';

@RoutePage()
class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black),
          onPressed: () {
            context.router.pop();
          },
        ),
        title: const Text(
          'Xem thông tin',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            buildProfileCard(),
            const SizedBox(height: 10),
            buildTabView(),
            buildFooter(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
