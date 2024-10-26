import 'package:flutter/material.dart';

  Widget buildAddParticipantButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.add, color: Colors.grey),
    );
  }

  
  