import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddTaskButton extends StatelessWidget {
  final VoidCallback onPressed;

  AddTaskButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FadeInUp(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(16),
            backgroundColor: Colors.green,
          ),
          onPressed: onPressed,
          child: FaIcon(
            FontAwesomeIcons.plus,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
