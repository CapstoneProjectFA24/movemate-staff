import 'package:flutter/material.dart';
import 'package:movemate_staff/features/order/presentation/widgets/schedule_item.dart';

Widget buildCreateScheduleSection() {
  return ListView(
    padding: const EdgeInsets.all(10),
    children: [
      buildScheduleItem('Đơn 3: booking at: 14h30 - review at: 12h30'),
      buildScheduleItem('Đơn 4: booking at: 15h30 - review at: 13h30'),
    ],
  );
}
