import 'package:flutter/material.dart';
import 'package:movemate_staff/features/order/presentation/widgets/schedule_item.dart';

  Widget buildScheduleSection() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        buildScheduleItem('Đơn 1: booking at: 14h30 - review at: 12h30'),
        buildScheduleItem('Đơn 2: booking at: 15h30 - review at: 13h30'),
      ],
    );
  }