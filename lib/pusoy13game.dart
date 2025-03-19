import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api_config.dart';
import 'arrangeScreen.dart';
import 'homepage.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky).then((_) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      runApp(const Pusoy13Game());
    });
  });
}

class Pusoy13Game extends StatefulWidget {
  const Pusoy13Game({super.key});

  @override
  _Pusoy13GameState createState() => _Pusoy13GameState();
}

class _Pusoy13GameState extends State<Pusoy13Game> {
  List<String> deck = [];
  List<List<String>> players = [[], [], [], []];
  bool isDealing = false;
  late AnimationController _controller;
  List<Animation<Offset>> _positionAnimations = [];
  List<Animation<double>> _rotationAnimations = [];
  final int _totalCards = 52;
  bool _isAnimating = false;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _fetchCards();
    setState(() {
      isDealing = true;
    });
  }

  void _fetchCards() async {
    try {
      List<String> fetchedDeck = await ApiService.getCards();
      if (mounted) {
        setState(() {
          deck = fetchedDeck;
          isLoading = false;
        });
        _dealCardsWithAnimation();  // Once cards are fetched, deal them
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

  Future<void> _dealCardsWithAnimation() async {
    List<List<String>> tempPlayers = [[], [], [], []];

    // Deal cards to players
    for (int i = 0; i < 13; i++) {
      for (int j = 0; j < 4; j++) {
        if (deck.isNotEmpty) {
          tempPlayers[j].add(deck.removeAt(0));
        }
      }
    }

    // Update the state once after dealing all cards
    setState(() {
      players = tempPlayers;
      isDealing = false;
    });
  }

  List<String> _generateDeck() {
    List<String> suits = ['\u2660', '\u2665', '\u2666', '\u2663'];
    List<String> ranks = [
      '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'
    ];
    return [
      for (var suit in suits)
        for (var rank in ranks) '$rank$suit'
    ];
  }

  Widget _buildPlayerHand(int index) {
    return Column(
      children: [
        _buildCardRow(index, 0, 3), // Top row with 3 cards
        _buildCardRow(index, 3, 8), // Middle row with 5 cards
        _buildCardRow(index, 8, 13), // Bottom row with 5 cards
      ],
    );
  }

  Widget _buildCardRow(int playerIndex, int start, int end) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start, (index) {
        int cardIndex = start + index;
        if (cardIndex < players[playerIndex].length) {
          final card = players[playerIndex][cardIndex];
          return _buildCard(card, playerIndex, cardIndex);
        } else {
          return Container(); // Empty space for cards that don't exist
        }
      }),
    );
  }

  Widget _buildCard(String card, int playerIndex, int cardIndex) {
    // Only allow dragging if the player is Player 1
    bool isPlayerOne = playerIndex == 0;

    return isPlayerOne
        ? Draggable<String>(
      data: card,
      feedback: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // No rounded corners
        ),
        child: Container(
          width: 35, // Set the width of the card
          height: 40, // Set the height of the card
          child: Text(card,
              style: TextStyle(fontSize: 16)), // Increase font size
        ),
      ),
      childWhenDragging: Container(), // Hide the card when dragging
      child: DragTarget<String>(
        onAccept: (data) {
          setState(() {
            // Find the index of the dragged card
            int draggedIndex = players[playerIndex].indexOf(data);
            // Swap the cards
            String temp = players[playerIndex][draggedIndex];
            players[playerIndex][draggedIndex] =
            players[playerIndex][cardIndex];
            players[playerIndex][cardIndex] = temp;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // No rounded corners
            ),
            elevation: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: .3),
                // Add a black border
                borderRadius: BorderRadius.zero, // No rounded corners
              ),
              width: 35, // Set the width of the card
              height: 40, // Set the height of the card
              child: Text(card,
                  style: TextStyle(fontSize: 16)), // Increase font size
            ),
          );
        },
      ),
    )
        : Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // No rounded corners
      ),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: .3),
          // Add a black border
          borderRadius: BorderRadius.zero, // No rounded corners
        ),
        width: 35, // Set the width of the card
        height: 40, // Set the height of the card
        child: Text(card,
            style: TextStyle(fontSize: 16)), // Increase font size
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/gamebg.png'), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            // Check if cards are loading
            if (isLoading)
              Center(child: CircularProgressIndicator()),

            // Player 1 (Top)
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
                          MaterialPageRoute(builder: (context) => Homepage(username: "username")),
                        );
                      }),
                ],
              ),
            ),
            // Player 2 (Bottom)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 100,
              child: Column(
                children: [
                  Text(
                    "Player 2",
                    style: TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                  Container(
                    height: 144,
                    child: _buildPlayerHand(1),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 210,
              left: MediaQuery.of(context).size.width / 2 - 100,
              child: Column(
                children: [
                  Text(
                    "Player 1",
                    style: TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                  Container(
                    height: 300,
                    child: _buildPlayerHand(0),
                  ),
                ],
              ),
            ),
            // Player 3 (Left)
            Positioned(
              left: 20,
              top: MediaQuery.of(context).size.height / 2 - 100,
              child: Column(
                children: [
                  Text(
                    "Player 3",
                    style: TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                  Container(
                    height: 144,
                    child: _buildPlayerHand(2),
                  ),
                ],
              ),
            ),
            // Player 4 (Right)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).size.height / 2 - 100,
              child: Column(
                children: [
                  Text(
                    "Player 4",
                    style: TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                  Container(
                    height: 144,
                    child: _buildPlayerHand(3),
                  ),
                ],
              ),
            ),
            // Card back image in the center
            Center(
                heightFactor: 100,
                child: Container(
                  width: 40,
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/card_back.png'),
                          fit: BoxFit.cover)
                  ),
                )
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _initializeGame,
            child: Text('Restart Game'),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: StartDialog(playerCards: players[0]),
                  );
                },
              );
            },
            child: Text('Start'),
          ),
        ],
      ),
    );
  }
}
