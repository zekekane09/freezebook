import 'package:flutter/material.dart';



class progress extends StatelessWidget {
  const progress({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Animated LinearProgressIndicator'),
        ),
        body: Center(
          child: ProgressIndicatorWidget(),
        ),
      ),
    );
  }
}

class ProgressIndicatorWidget extends StatefulWidget {
  const ProgressIndicatorWidget({super.key});

  @override
  _ProgressIndicatorWidgetState createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _progressValue = 1.0; // Start from full (1.0)

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Total duration for the animation
      vsync: this,
    );

    // Define the animation from 1.0 (full) to 0.0 (empty)
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _progressValue = _animation.value; // Update the progress value
        });
      });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          value: _progressValue, // Use the animated progress value
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        SizedBox(height: 20),
        Text(
          '${(_progressValue * 100).toStringAsFixed(0)}%', // Display percentage
          style: TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}