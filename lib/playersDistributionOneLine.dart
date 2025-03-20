import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'arrangeScreen.dart';
import 'homepage.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky).then((_) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      runApp(const PlayersDistributionOneLine());
    });
  });
}

class PlayersDistributionOneLine extends StatefulWidget {
  const PlayersDistributionOneLine({super.key});

  @override
  _PlayersDistributionOneLine createState() => _PlayersDistributionOneLine();
}

class _PlayersDistributionOneLine extends State<PlayersDistributionOneLine>
    with TickerProviderStateMixin {
  List<String> deck = [];
  List<List<String>> players = [[], [], [], []];
  late AnimationController _controller;
  List<Animation<Offset>> _positionAnimations = [];
  List<Animation<double>> _rotationAnimations = [];
  final int _totalCards = 52;
  bool _isAnimating = false;
  bool _showDealtCards = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

  }

  void _initializeGame() {
    deck = _generateDeck();
    deck.shuffle(Random());
    _initializeAnimations();
    _triggerDealAnimation();
  }

  void _initializeAnimations() {
    _positionAnimations.clear();
    _rotationAnimations.clear();

    for (int i = 0; i < _totalCards; i++) {
      final endOffset = _calculateEndOffset(i);
      final rotation = _calculateCardRotation(i);

      _positionAnimations.add(
          Tween<Offset>(
            begin: const Offset(0, 0),
            end: endOffset,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(i / _totalCards, (i + 1) / _totalCards,
                  curve: Curves.easeOut),
            ),
          ));


          _rotationAnimations.add(
          Tween<double>(begin: 0.0, end: rotation).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
              i / _totalCards, (i + 1) / _totalCards, curve: Curves.easeOut),
        ),
      ));
    }
  }

  Offset _calculateEndOffset(int index) {
    final playerIndex = index % 4;
    final cardPosition = index ~/ 4;
    final screenSize = MediaQuery
        .of(context)
        .size;

    switch (playerIndex) {
      case 0: // Player 1 (Bottom)
        return Offset(
          (cardPosition - 6.5) * 35 / screenSize.width,
          0.7 - (cardPosition / 13) * 0.2,
        );
      case 1: // Player 2 (Top)
        return Offset(
          (cardPosition - 6.5) * 35 / screenSize.width,
          -0.7 + (cardPosition / 13) * 0.2,
        );
      case 2: // Player 3 (Left)
        return Offset(
          -0.7 + (cardPosition / 13) * 0.2,
          (cardPosition - 6.5) * 25 / screenSize.height,
        );
      case 3: // Player 4 (Right)
        return Offset(
          0.7 - (cardPosition / 13) * 0.2,
          (cardPosition - 6.5) * 25 / screenSize.height,
        );
      default:
        return Offset.zero;
    }
  }

  double _calculateCardRotation(int index) => index % 2 == 0 ? -0.1 : 0.1;

  void _triggerDealAnimation() {
    if (!_isAnimating) {
      setState(() {
        _isAnimating = true;
        _showDealtCards = false;
        players = [[], [], [], []];
      });

      _controller.forward(from: 0.0).whenComplete(() {
        setState(() {
          _isAnimating = false;
          _showDealtCards = true;
          // Distribute cards to players
          for (int i = 0; i < 52; i++) {
            players[i % 4].add(deck[i]);
          }
        });
      });
    }
  }

  List<String> _generateDeck() =>
      [
        for (var suit in ['\u2660', '\u2665', '\u2666', '\u2663'])
          for (var rank in [
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            'J',
            'Q',
            'K',
            'A'
          ])
            '$rank$suit'
      ];

  Widget _buildPlayerHand(int index) =>
      Column(
        children: [
          _buildCardRow(index, 0, 3),
          _buildCardRow(index, 3, 8),
          _buildCardRow(index, 8, 13),
        ],
      );

  Widget _buildCardRow(int playerIndex, int start, int end) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(end - start, (index) {
          final cardIndex = start + index;
          return cardIndex < players[playerIndex].length
              ? _buildCard(
              players[playerIndex][cardIndex], playerIndex, cardIndex)
              : const SizedBox(width: 35, height: 40);
        }),
      );

  Widget _buildCard(String card, int playerIndex, int cardIndex) {
    final isPlayerOne = playerIndex == 0;

    return isPlayerOne
        ? _buildDraggableCard(card, playerIndex, cardIndex)
        : _buildStaticCard(card);
  }

  Widget _buildDraggableCard(String card, int playerIndex, int cardIndex) =>
      Draggable<String>(
        data: card,
        feedback: _cardWidget(card),
        childWhenDragging: const SizedBox(),
        child: DragTarget<String>(
          onAccept: (data) =>
              setState(() {
                final draggedIndex = players[playerIndex].indexOf(data);
                final temp = players[playerIndex][draggedIndex];
                players[playerIndex][draggedIndex] =
                players[playerIndex][cardIndex];
                players[playerIndex][cardIndex] = temp;
              }),
          builder: (context, _, __) => _cardWidget(card),
        ),
      );

  Widget _buildStaticCard(String card) => _cardWidget(card);

  Widget _cardWidget(String card) =>
      Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 3,
          child: Container(
            width: 35,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.3),
            ),
          ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/gamebg.png'),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            // Animation Layer
            if (_isAnimating)
              ...List.generate(_totalCards, (index) =>
                  SlideTransition(
                    position: _positionAnimations[index],
                    child: Transform.rotate(
                      angle: _rotationAnimations[index].value,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Container(
                          width: 50,
                          height: 70,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/card_back.png'),
                                  fit: BoxFit.cover)),
                        ),
                      ),
                    ),
                  ),
              ),
                  // Player Hands
                  if (_showDealtCards) ...[
              _playerWidget(0, Alignment.bottomCenter),
              _playerWidget(1, Alignment.topCenter),
              _playerWidget(2, Alignment.centerLeft),
              _playerWidget(3, Alignment.centerRight),
            ],

            // Back Button
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Image.asset('assets/images/game_back.webp',
                    width: 40, height: 40),
                onPressed: () =>
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) =>
                      const Homepage(
                          // username: "username"
                      )),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _triggerDealAnimation,
            child: const Icon(Icons.play_arrow),
            tooltip: "Deal Cards",
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _initializeGame,
            child: const Text('Restart Game'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () =>
                showDialog(
                  context: context,
                  builder: (_) =>
                      Dialog(child: StartDialog(playerCards: players[0])),
                ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Widget _playerWidget(int index, Alignment alignment) =>
      Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Player ${index + 1}",
                  style: const TextStyle(color: Colors.amber, fontSize: 20)),
              Container(
                  height: index == 0 ? 300 : 144,
                  child: _buildPlayerHand(index)),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}