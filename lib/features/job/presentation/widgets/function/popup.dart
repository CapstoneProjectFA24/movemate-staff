import 'package:flutter/material.dart';

Widget buildDropdown({required List<String> items, required IconData icon}) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      suffixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    value: items.first,
    items: items
        .map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ))
        .toList(),
    onChanged: (value) {},
  );
}
