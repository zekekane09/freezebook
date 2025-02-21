import 'cardmodel.dart';

class GameLogic {
  List<CardModel> deck = [];
  List<List<CardModel>> playerHands = [];

  GameLogic() {
    _initializeDeck();
    _dealCards();
  }

  void _initializeDeck() {
    // Initialize a standard deck of cards
    const suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    const ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];

    for (var suit in suits) {
      for (var rank in ranks) {
        deck.add(CardModel(suit, rank));
      }
    }
    deck.shuffle();
  }

  void _dealCards() {
    // Deal cards to players (e.g., 13 cards each for 4 players)
    for (int i = 0; i < 4; i++) {
      playerHands.add(deck.sublist(i * 13, (i + 1) * 13));
    }
  }

  List<CardModel> getPlayerHand(int playerIndex) {
    return playerHands[playerIndex];
  }
}

