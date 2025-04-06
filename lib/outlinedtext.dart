import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color strokeColor;
  final Color textColor;

  const OutlinedText({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.strokeColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroke text
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: strokeColor,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                color: strokeColor,
              ),
              Shadow(
                offset: Offset(-1.0, 1.0),
                color: strokeColor,
              ),
              Shadow(
                offset: Offset(1.0, -1.0),
                color: strokeColor,
              ),
              Shadow(
                offset: Offset(-1.0, -1.0),
                color: strokeColor,
              ),
            ],
          ),
        ),
        // Actual text
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}