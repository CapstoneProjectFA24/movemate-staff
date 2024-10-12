import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  final String title;
  final bool isActive;

  TabItem({required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFFFF4500) : Color(0xFFFF7F50),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
