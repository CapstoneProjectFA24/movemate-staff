import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

@RoutePage()
class PorterScreen extends HookConsumerWidget {
  const PorterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final jobs = _getJobsForSelectedDate(selectedDate.value);

    jobs.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch công việc bốc vác',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Week View (Horizontal Scroll)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = DateTime.now().add(Duration(days: index));
                final isSelected = DateFormat.yMd().format(day) ==
                    DateFormat.yMd().format(selectedDate.value);
                return GestureDetector(
                  onTap: () {
                    selectedDate.value = day;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: Colors.orange.shade200,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(day),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat.d().format(day),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // List of Job Cards for the selected day, displayed as a timeline
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Indicator and Timeline Line
                    Column(
                      children: [
                        Text(
                          DateFormat.Hm()
                              .format(job.startTime), // Default time formatting
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        if (index < jobs.length - 1)
                          Container(
                            height: 80,
                            width: 2,
                            color: Colors.orange.shade200,
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),

                    // Job Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.router.push(const PorterDetailScreenRoute());
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: job.status == 'Đã vận chuyển'
                                    ? [
                                        Colors.green.shade700,
                                        Colors.green.shade400
                                      ]
                                    : [
                                        Colors.orange.shade700,
                                        Colors.orange.shade400
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      job.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: job.status == 'Đã vận chuyển'
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        job.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        color: Colors.white70, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${DateFormat.Hm().format(job.startTime)} - ${DateFormat.Hm().format(job.endTime)}', // Default time formatting
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.white70, size: 18),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        job.pickupAddress,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.flag,
                                        color: Colors.white70, size: 18),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        job.dropoffAddress,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<BookingJob> _getJobsForSelectedDate(DateTime selectedDate) {
    final allJobs = [
      BookingJob(
        id: 'JOB001',
        title: 'Chuyển nhà',
        description: 'Chuyển nhà từ quận 1 đến quận 7',
        status: 'Đã vận chuyển',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 4)),
        pickupAddress: '123 Đường A, Quận 1, TP. HCM',
        dropoffAddress: '456 Đường B, Quận 7, TP. HCM',
      ),
      BookingJob(
        id: 'JOB002',
        title: 'Chuyển kho hàng',
        description: 'Chuyển kho hàng từ quận 5 đến quận 8',
        status: 'Chưa vận chuyển',
        startTime: DateTime.now().add(const Duration(hours: 6)),
        endTime: DateTime.now().add(const Duration(hours: 8)),
        pickupAddress: '111 Đường E, Quận 5, TP. HCM',
        dropoffAddress: '222 Đường F, Quận 8, TP. HCM',
      ),
      BookingJob(
        id: 'JOB003',
        title: 'Chuyển kho hàng',
        description: 'Chuyển kho hàng từ quận 5 đến quận 8',
        status: 'Chưa vận chuyển',
        startTime: DateTime.now().add(const Duration(hours: 15)),
        endTime: DateTime.now().add(const Duration(hours: 18)),
        pickupAddress: '111 Đường E, Quận 5, TP. HCM',
        dropoffAddress: '222 Đường F, Quận 8, TP. HCM',
      ),
    ];

    return allJobs.where((job) {
      return DateFormat.yMd().format(job.startTime) ==
          DateFormat.yMd().format(selectedDate);
    }).toList();
  }
}

// Job model with hourly start and end times
class BookingJob {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final String pickupAddress;
  final String dropoffAddress;

  BookingJob({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.pickupAddress,
    required this.dropoffAddress,
  });
}
