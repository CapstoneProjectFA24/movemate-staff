import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

Widget buildNumberInput({
  required TextEditingController controller,
  required Function(String) onChanged,
}) {
  return FadeInUp(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            // hintText: initialValue, // Không cần nữa vì sử dụng controller
          ),
          onChanged: onChanged,
        ),
      ],
    ),
  );
}
