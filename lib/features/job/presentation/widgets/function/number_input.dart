import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

Widget buildNumberInput({required String initialValue}) {
  return FadeInUp(
    child: TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: initialValue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
