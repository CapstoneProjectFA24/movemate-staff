import 'package:flutter/material.dart';
import 'package:movemate_staff/features/history/presentation/widget/feature.dart';

class HistoryItem extends StatelessWidget {
  final String title, imageUrl, location, museums, archives, tourDuration;

  const HistoryItem({
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.museums,
    required this.archives,
    required this.tourDuration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Phần hiển thị ảnh và tiêu đề
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Phần thông tin chi tiết
        Padding(
          padding: const EdgeInsets.only(top: 32.0, right: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFeatureItem(Icons.location_on, location),
              buildFeatureItem(Icons.apartment, museums),
              buildFeatureItem(Icons.archive, archives),
              buildFeatureItem(Icons.calendar_today, tourDuration),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "View in detail",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
