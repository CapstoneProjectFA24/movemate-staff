import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

Widget buildImageRow() {
  return FadeInUp(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        return Image.network(
          'https://storage.googleapis.com/a1aa/image/fr8IOuyYEtSRL6pe1D8C4nfX1Y4XqeSNpv5dkagcNrd8rQhOB.jpg',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }),
    ),
  );
}
