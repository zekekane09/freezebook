// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
// import 'dart:async';
//
// class Pusoy13Game extends StatefulWidget {
//   const Pusoy13Game({super.key});
//
//   @override
//   _Pusoy13GameState createState() => _Pusoy13GameState();
// }
//
// class _Pusoy13GameState extends State<Pusoy13Game> {
//   List<String> deck = [];
//   List<List<String>> players = [[], [], [], []];
//   bool isDealing = false;
//   String gameId = ''; // Store the game ID
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeGame();
//   }
//
//   void _initializeGame() {
//     deck = _generateDeck();
//     deck.shuffle();
//     for (int i = 0; i < 4; i++) {
//       players[i] = [];
//     }
//     setState(() {
//       isDealing = true;
//     });
//     _dealCardsWithAnimation();
//   }
//
//   Future<void> _dealCardsWithAnimation() async {
//     for (int i = 0; i < 13; i++) {
//       for (int j = 0; j < 4; j++) {
//         if (deck.isNotEmpty) {
//           setState(() {
//             players[j].add(deck.removeAt(0));
//           });
//           await Future.delayed(Duration(milliseconds: 200));
//         }
//       }
//     }
//     setState(() {
//       isDealing = false;
//     });
//     // Update Firestore with the players' hands
//     await firestore.collection('games').doc(gameId).update({
//       'hands': players,
//     });
//   }
//
//   List<String> _generateDeck() {
//     List<String> suits = [':spades:', ':hearts:', ':diamonds:', ':clubs:'];
//     List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
//     return [for (var suit in suits) for (var rank in ranks) '$rank$suit'];
//   }
//
//   Widget _buildPlayerHand(int index) {
//     return DragAndDropLists(
//       children: [
//         DragAndDropList(
//           children: players[index].map((card) {
//             return DragAndDropItem(
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(card, style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//             );
//           }).toList(),
//           header: Text('Player ${index + 1}'),
//         ),
//       ],
//       onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
//         setState(() {
//           final item = players[oldListIndex].removeAt(oldItemIndex);
//           players[newListIndex].insert(newItemIndex, item);
//         });
//       },
//       onListReorder: (int oldListIndex, int newListIndex) {
//         // Handle list reordering if needed
//       },
//     );
//   }
//
//   void _createGame() async {
//     DocumentReference gameRef = await firestore.collection('games').add({
//       'status': 'waiting',
//       'hands': [[], [], [], []], // Initialize empty hands for 4 players
//     });
//     setState(() {
//       gameId = gameRef.id; // Store the game ID
//     });
//   }
//
//   void _joinGame(String gameId) {
//     // Logic to join an existing game
//     // You can implement a dialog to enter the game ID
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Pusoy 13')),
//       body: Stack(
//         children: [
//           // Player 1 (Top)
//           Positioned(
//             top: 50,
//             left: MediaQuery.of(context).size.width / 2 - 100,
//             child: SizedBox(
//               width: 200,
//               child: _buildPlayerHand(0),
//             ),
//           ),
//           // Player 2 (Bottom)
//           Positioned(
//             bottom: 50,
//             left: MediaQuery.of(context).size.width / 2 - 100,
//             child: SizedBox(
//               width: 200,
//               child: _buildPlayerHand(1),
//             ),
//           ),
//           // Player 3 (Left)
//           Positioned(
//             left: 20,
//             top: MediaQuery.of(context).size.height / 2 - 100,
//             child: SizedBox(
//               width: 100,
//               child: _buildPlayerHand(2),
//             ),
//           ),
//           // Player 4 (Right)
//           Positioned(
//             right: 20,
//             top: MediaQuery.of(context).size.height / 2 - 100,
//             child: SizedBox(
//               width: 100,
//               child: _buildPlayerHand(3),
//             ),
//           ),
//           // Card back image in the center
//           Positioned(
//             left: MediaQuery.of(context).size.width / 2 - 30,
//             top: MediaQuery.of(context).size.height / 2 - 30,
//             child: Image.asset('assets/card_back.png', width: 60, height: 90),
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               // Handle game state submission
//               print("Players' hands: $players");
//             },
//             child: Text('Submit'),
//           ),
//           ElevatedButton(
//             onPressed: _createGame,
//             child: Text('Create Game'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Implement join game logic
//               // _joinGame(gameId); // Replace with actual game ID input
//             },
//             child: Text('Join Game'),
//           ),
//         ],
//       ),
//     );
//   }
// }