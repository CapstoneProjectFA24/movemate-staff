import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/image.dart';

class Section extends StatelessWidget {
  final String title;
  final List<String> imageUrls;

  const Section({super.key, required this.title, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Display images in a row or a grid
          FadeInUp(
            child: Row(
              children: imageUrls.map((url) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.network(url, width: 98, height: 98),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
