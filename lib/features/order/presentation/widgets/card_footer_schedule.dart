import 'package:flutter/material.dart';

  Widget buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tạo lịch hẹn', style: TextStyle(color: Colors.white)),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.orange[700],
            child:
                Text('+', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
        ],
      ),
    );
  }
