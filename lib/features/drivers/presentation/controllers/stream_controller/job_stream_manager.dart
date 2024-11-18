import 'dart:async';

import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

class JobStreamManager {
  static final JobStreamManager _instance = JobStreamManager.internal();

  factory JobStreamManager() => _instance;
  JobStreamManager.internal();

  final _jobController = StreamController<BookingResponseEntity>.broadcast();
  Stream<BookingResponseEntity> get jobStream => _jobController.stream;

  void updateJob(BookingResponseEntity newJob) {
    print(
        'Updating order in StreamManager: ${newJob.assignments.map((e) => e.toJson())}');

    _jobController.add(newJob);
  }

  void dispose() {
    _jobController.close();
  }
}
