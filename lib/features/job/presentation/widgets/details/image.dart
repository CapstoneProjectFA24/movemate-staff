import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  final String imageUrl;

  ImageContainer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // overflow: BoxOverflow.hidden,
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFF4D97),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}