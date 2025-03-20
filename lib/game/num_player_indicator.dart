import 'package:flutter/material.dart';

class GamePlayerIndicator extends StatelessWidget {
  final int currentPlayers;
  final int maxPlayers;

  const GamePlayerIndicator({
    Key? key,
    required this.currentPlayers,
    this.maxPlayers = 4, // Default max players
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the progress
    double progress = currentPlayers / maxPlayers;
    Color progressColor = currentPlayers >= maxPlayers ? Colors.blue : Colors.grey;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Circular progress indicator
        SizedBox(
          width: 30, // Set the size of the circle
          height: 30,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        // Player count text
        Text(
          '$currentPlayers',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}