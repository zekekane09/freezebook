import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createGame() async {
  DocumentReference gameRef = await FirebaseFirestore.instance.collection('games').add({
    'status': 'waiting',
    'players': [],
  });
  // Store the game ID for future reference
}