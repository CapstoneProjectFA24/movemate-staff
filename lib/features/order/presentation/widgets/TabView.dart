import 'package:flutter/material.dart';
import 'package:movemate_staff/features/order/presentation/widgets/order_success.dart';
import 'package:movemate_staff/features/order/presentation/widgets/order_waiting.dart';

Widget buildTabView() {
  return DefaultTabController(
    length: 2,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(5), // Bo tròn cho Container
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1), // Màu bóng
            spreadRadius: 2, // Độ lan tỏa
            blurRadius: 5, // Độ mờ
            offset: Offset(0, 2), // Vị trí bóng
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.orange[700],
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10)), // Bo tròn cho Container
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Màu bóng
                  spreadRadius: 2, // Độ lan tỏa
                  blurRadius: 5, // Độ mờ
                  offset: Offset(0, 2), // Vị trí bóng
                ),
              ],
            ),
            child: const TabBar(
              tabs: [
                Tab(text: 'lịch đã duyệt'),
                Tab(text: 'lịch chưa duyệt'),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
            ),
          ),
          SizedBox(
            height: 300, // Adjust height as needed
            child: TabBarView(
              children: [
                buildScheduleSection(),
                buildCreateScheduleSection(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
