import 'dart:math';
import 'package:flutter/material.dart';

Color getRandomColor() {
  final random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(151), // R
    random.nextInt(151), // G
    random.nextInt(151), // B
  );
}
