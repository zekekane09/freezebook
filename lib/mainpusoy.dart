import 'package:flutter/material.dart';
import 'cardmodel.dart';


class PusoyGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pusoy Game',
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameLogic gameLogic = GameLogic();
  int currentPlayerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pusoy Game')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gameLogic.getPlayerHand(currentPlayerIndex).length,
              itemBuilder: (context, index) {
                final card = gameLogic.getPlayerHand(currentPlayerIndex)[index];
                return Draggable<CardModel>(
                  data: card,
                  child: CardWidget(card: card),
                  feedback: CardWidget(card: card, isDragging: true),
                  childWhenDragging: Container(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;
  final bool isDragging;

  const CardWidget({Key? key, required this.card, this.isDragging = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(4.0),
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
    color: isDragging ? Colors.blue : Colors.white,
    border: Border.all(color: Colors.black
    ),
      borderRadius: BorderRadius.circular(8.0),
    ),
      child: Text(
        '${card.rank} of ${card.suit}',
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}