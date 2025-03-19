import 'package:flutter/material.dart';

class StartDialog extends StatefulWidget {
  final List<String> playerCards;

  StartDialog({required this.playerCards});

  @override
  _StartDialogState createState() => _StartDialogState();
}

class _StartDialogState extends State<StartDialog> {
  late List<String> arrangedCards;

  @override
  void initState() {
    super.initState();
    arrangedCards = List.from(widget.playerCards); // Copy initial cards
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true, // Allow back navigation
      child: Stack(children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                child: _buildPlayerHand(),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(arrangedCards),
            child: Text('Finish'),
          ),
        )
      ]),
    );
  }

  Widget _buildPlayerHand() {
    return Column(
      children: [
        _buildCardRow(0, 3),
        _buildCardRow(3, 8),
        _buildCardRow(8, 13),
      ],
    );
  }

  Widget _buildCardRow(int start, int end) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(end - start, (index) {
          int cardIndex = start + index;
          if (cardIndex < arrangedCards.length) {
            final card = arrangedCards[cardIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              // Adjust spacing
              child: _buildDraggableCard(card, cardIndex),
            );
          } else {
            return Container();
          }
        }),
      ),
    );
  }

  Widget _buildDraggableCard(String card, int index) {
    return Draggable<String>(
      data: card,
      feedback: _cardWidget(card, isDragging: true),
      childWhenDragging: Opacity(opacity: 0.0, child: _cardWidget(card)),
      child: DragTarget<String>(
        onAccept: (draggedCard) {
          setState(() {
            int fromIndex = arrangedCards.indexOf(draggedCard);
            arrangedCards[fromIndex] = arrangedCards[index];
            arrangedCards[index] = draggedCard;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return _cardWidget(card);
        },
      ),
    );
  }

  Widget _cardWidget(String card, {bool isDragging = false}) {
    return Card(
      elevation: isDragging ? 8 : 3,
      child: Container(
        width: 55,
        // Adjusted width to fit better
        height: 75,
        // Adjusted height to fit better
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          card,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
