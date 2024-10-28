import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

Widget buildTextInput({
  required String hintText,
  required IconData icon,
  String? defaultValue,
}) {
  return FadeInUp(
    child: TextField(
      controller: TextEditingController(text: defaultValue),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}