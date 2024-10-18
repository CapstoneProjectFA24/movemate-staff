import 'package:flutter/material.dart';
import 'package:movemate_staff/features/job/presentation/widgets/jobcard/job_card.dart';

class JobList extends StatelessWidget {
  final List<JobModel> jobs;

  const JobList({Key? key, required this.jobs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return JobCard(job: job);
      },
    );
  }
}