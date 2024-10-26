import 'package:flutter/material.dart';


  Widget buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

