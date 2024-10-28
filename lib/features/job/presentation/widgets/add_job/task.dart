import 'package:flutter/material.dart';
import 'package:movemate_staff/features/job/domain/entities/task_entity.dart';
import 'package:movemate_staff/features/job/presentation/screen/generate_new_job_screen/generate_new_job_screen.dart';
import 'package:movemate_staff/features/job/presentation/screen/job_details_screen/job_details_screen.dart';

class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final DateTime selectedDay;

  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          color: Colors.orange[100],
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => JobDetailsScreen(),
              //   ),
              // );
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 5,
                  children: task.participants.map((participant) {
                    return CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage(participant['image']!),
                    );
                  }).toList(),
                ),
              ],
            ),
            subtitle: Text(
              task.description,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
