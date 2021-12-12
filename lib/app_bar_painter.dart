import 'package:flutter/material.dart';

class AppBarPainter extends CustomPainter {
  final Offset center;
  final double radius, containerHeight;
  final BuildContext context;

  final Color color;
  late double statusBarHeight, screenWidth;

  AppBarPainter({
    required this.context,
    required this.containerHeight,
    required this.center,
    required this.radius,
    required this.color,
  }) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePainter = Paint();
    circlePainter.color = color;

    canvas.clipRect(
        Rect.fromLTWH(0, 0, screenWidth, containerHeight + statusBarHeight));

    canvas.drawCircle(center, radius, circlePainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
