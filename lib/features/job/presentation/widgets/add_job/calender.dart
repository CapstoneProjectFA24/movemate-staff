// import 'package:animate_do/animate_do.dart';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CalendarWidget extends StatelessWidget {
//   final DateTime focusedDay;
//   final DateTime selectedDay;
//   final Function(DateTime, DateTime) onDaySelected;

//   CalendarWidget({
//     required this.focusedDay,
//     required this.selectedDay,
//     required this.onDaySelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: FadeInDown(
//         child: TableCalendar(
//           focusedDay: focusedDay,
//           firstDay: DateTime.utc(2000, 1, 1),
//           lastDay: DateTime.utc(2030, 1, 1),
//           headerStyle: HeaderStyle(
//             formatButtonVisible: false,
//             titleCentered: true,
//           ),
//           selectedDayPredicate: (day) => isSameDay(day, selectedDay),
//           onDaySelected: onDaySelected,
//           availableGestures: AvailableGestures.all,
//           calendarStyle: CalendarStyle(
//             todayDecoration: BoxDecoration(
//               color: Colors.green,
//               shape: BoxShape.circle,
//             ),
//             selectedDecoration: BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
