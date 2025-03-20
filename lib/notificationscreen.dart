import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'homepage.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky).then((_) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      runApp( CardDistribution());
    });
  });
}
class CardDistribution extends StatefulWidget {
  @override
  _CardDistributionState createState() => _CardDistributionState();
}

class _CardDistributionState extends State<CardDistribution>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Animation<Offset>> _positionAnimations = [];
  List<Animation<double>> _rotationAnimations = [];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds:20),
    );

    // Initialize animations for 13 cards
    for (int i = 0; i < 13; i++) {
      Offset endOffset;

      // Set offsets based on the index
      if (i < 3) {
        endOffset = Offset(-0.45* (i + 8), -0.9); // First two cards
      } else if (i < 8) {
        endOffset = Offset(-0.45* (i + 4),- 0.4); // Next five cards
      } else {
        endOffset = Offset(-0.45* (i - 1) , 0.1); // Remaining cards
      }

      _positionAnimations.add(
        Tween<Offset>(
          begin: Offset.zero,
          end: endOffset,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(i / 13, (i + 1) / 13, curve: Curves.easeOut),
          ),
        ),
      );

      _rotationAnimations.add(
        Tween<double>(begin: 0.0, end: 0.5).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(i / 13, (i + 1) / 13, curve: Curves.easeOut),
          ),
        ),
      );
    }

    _controller.addListener(() => setState(() {}));
  }

  void _triggerAnimation() {
    if (!_isAnimating) {
      setState(() => _isAnimating = true);
      _controller.forward(from: 0.0).whenComplete(() {
        setState(() => _isAnimating = false);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Column(
              children: [
                IconButton(
                    icon: Image.asset('assets/images/game_back.webp', width: 40, height: 40),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Homepage(
                            // username: "username"
                        )),
                      );
                    }),
              ],
            ),
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(13, (index) {
                return SlideTransition(
                  position: _positionAnimations[index],
                  child: RotationTransition(
                    turns: _rotationAnimations[index],
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        width: 40.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/card_back.png'), // Background image
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _triggerAnimation,
        child: Icon(Icons.play_arrow),
        tooltip: "Distribute Cards",
      ),
    );
  }
}