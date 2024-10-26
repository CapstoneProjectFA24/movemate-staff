import 'package:flutter/material.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/screen/job_details_screen/job_details_screen.dart';
import 'package:auto_route/auto_route.dart';

class JobModel {
  final String title;
  final String details;
  final String location;
  final String status;
  final Color statusColor;
  final String imageUrl;

  JobModel({
    required this.title,
    required this.details,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.imageUrl,
  });
}

class JobCard extends StatelessWidget {
  final BookingResponseEntity job;
  final VoidCallback onCallback;

  JobCard({
    super.key,
    required this.onCallback,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFFF7F50)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.id.toString(),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(job.typeBooking, style: TextStyle(fontSize: 14)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    ClipOval(
                      child: Image.network(
                        'https://storage.googleapis.com/a1aa/image/fpR5CaQW2ny0CCt8MBn1ufzjTBuLAgHXz4yQMiYIxzaWDIlTA.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        job.status,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Job Details
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red),
              SizedBox(width: 5),
              Text(job.pickupAddress),
            ],
          ),
          SizedBox(height: 10),
          // Job Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFE4E1),
                  foregroundColor: Color(0xFFFF4500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Bo tròn góc
                  ),
                ),
                onPressed: () {
                  // Chat action
                },
                child: Text('Chat'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF4500),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Bo tròn góc
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JobDetailsScreen(job: job)),
                  );
                  // context.router.push(JobDetailsScreenRoute(job:job));
                },
                child: Text('Xem'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
