import 'dart:math';

import 'package:flutter/material.dart';

import '../api_config.dart';
import '../homepage.dart';

class DistributeCard extends StatefulWidget {
  @override
  _CardDistributionState createState() => _CardDistributionState();
}

class _CardDistributionState extends State<DistributeCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Animation<Offset>> _positionAnimations = [];
  List<Animation<double>> _rotationAnimations = [];
  List<String> _deck = [];
  bool isLoading = true;
  bool hasError = false;
  bool _isAnimating = false;
  final int _totalCards = 52; // Total number of cards
  final int _numberOfPlayers = 4; // Number of players

  @override
  void initState() {
    super.initState();
    // _deck = _generateDeck();
    // _deck.shuffle(Random());
    // Generate deck of cards
   _fetchCards();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    // Initialize animations for all cards
    _initializeAnimations();
    _controller.addListener(() => setState(() {}));
  }
  void _fetchCards() async {
    try {
      List<String> fetchedDeck = await ApiService.getCards();
      if (mounted) {
        setState(() {
          _deck = fetchedDeck;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching deck: $e");
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }
  }

  void _initializeAnimations() {

    for (int i = 0; i < _totalCards; i++) {
      Offset endOffset = _calculateEndOffset(i);
      double rotation = _calculateCardRotation(i);

      _positionAnimations.add(
        Tween<Offset>(
          begin: Offset.zero,
          end: endOffset,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(i / _totalCards, (i + 1) / _totalCards,
                curve: Curves.easeOut),
          ),
        ),
      );

      _rotationAnimations.add(
        Tween<double>(begin: 0.0, end: rotation).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(i / _totalCards, (i + 1) / _totalCards,
                curve: Curves.easeOut),
          ),
        ),
      );
    }
  }

  Offset _calculateEndOffset(int index) {
    int playerIndex = index % _numberOfPlayers; // Determine which player receives the card
    int cardPosition = index ~/ _numberOfPlayers; // Determine the card's position in the round-robin distribution

    // Player-specific positioning
    switch (playerIndex) {
      case 0:
        return _calculatePlayerOffset(cardPosition, 1);
      case 1:
        return _calculatePlayerOffset(cardPosition, 2);
      case 2:
        return _calculatePlayerOffset(cardPosition, 3);
      case 3:
        return _calculatePlayerOffset(cardPosition, 4);
      default:
        return Offset.zero; // Fallback
    }
  }
  List<String> _generateDeck() {
    List<String> suits = ['\u2660', '\u2665', '\u2666', '\u2663'];
    List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    return [
      for (var suit in suits)
        for (var rank in ranks) '$rank$suit'
    ];
  }
  Offset _calculatePlayerOffset(int cardPosition, int playerNumber) {
    double xOffset;
    double yOffset;

    switch (playerNumber) {
      case 1:
        if (cardPosition < 3) {
          xOffset = 0.55 * (cardPosition + 8); // First three cards
          yOffset = -0.5;
        } else if (cardPosition < 8) {
          xOffset = 0.55 * (cardPosition + 4); // Next five cards
          yOffset = 0.1;
        } else {
          xOffset = 0.55 * (cardPosition - 1); // Remaining cards
          yOffset = 0.6;
        }
        break;
      case 2:
        if (cardPosition < 3) {
          xOffset = -5.5 + (cardPosition + 1.0) * 0.5; // First three cards
          yOffset = -0.5;
        } else if (cardPosition < 8) {
          xOffset = -5.5 + (cardPosition - 3) * 0.5; // Next five cards
          yOffset = 0.1;
        } else {
          xOffset = -5.5 + (cardPosition - 8) * 0.5; // Remaining cards
          yOffset = 0.6;
        }
        break;
      case 3:
        if (cardPosition < 3) {
          xOffset = -0.5 + (cardPosition + 0.0) * 0.5; // First three cards
          yOffset = -2.0;
        } else if (cardPosition < 8) {
          xOffset = (cardPosition - 5) * 0.5; // Next five cards
          yOffset = -1.5;
        } else {
          xOffset = (cardPosition - 10) * 0.5; // Remaining cards
          yOffset = -1.1;
        }
        break;
      case 4:
        if (cardPosition < 3) {
          xOffset = -0.5 + (cardPosition + 0.0) * 0.5; // First three cards
          yOffset = 1.0;
        } else if (cardPosition < 8) {
          xOffset = (cardPosition - 5) * 0.5; // Next five cards
          yOffset = 1.5;
        } else {
          xOffset = (cardPosition - 10) * 0.5; // Remaining cards
          yOffset = 2.0;
        }
        break;
      default:
        xOffset = 0.0; // Fallback
        yOffset = 0.0; // Fallback
        break;
    }

    return Offset(xOffset, yOffset);
  }

  double _calculateCardRotation(int index) {
    // No rotation for portrait cards
    return 0.0; // All cards remain in portrait orientation
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
    double cardWidth = MediaQuery.of(context).size.width * 0.06; // 6% of screen width
    double cardHeight = MediaQuery.of(context).size.height * 0.17; // 17% of screen height
    return Scaffold(
      body: Stack(
        children: [isLoading
            ? Center(child: CircularProgressIndicator())
            : hasError
            ? Center(child: Text("Error loading deck."))
            : _deck.isEmpty
            ? Center(child: Text("Deck is empty!"))
            : ListView.builder(
          itemCount: _deck.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(_deck[index]));
          },
        ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(_totalCards, (index) {
                return SlideTransition(
                  position: _positionAnimations[index],
                  child: Transform.rotate(
                    angle: _rotationAnimations[index].value * 3.1416 * 2,
                    child: Card(
                      shape: RoundedRectangleBorder(),
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          // image: DecorationImage(
                          //   image: index % _numberOfPlayers < 3
                          //       ? AssetImage('assets/images/card_back.png') // Show card back for first three cards
                          //       : AssetImage('assets/images/card_back.png'), // Placeholder for card face image
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        child: index % _numberOfPlayers < 3
                            ? Container() // Empty container for card back
                            : Center(
                          child: Positioned(
                            top: 1,
                              left: 1,
                              child: Text(
                            _deck[index], // Display the card from the deck
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ) ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
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
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _triggerAnimation,
        child: Icon(Icons.play_arrow),
        tooltip: "Deal Cards",
      ),
    );
  }


}
