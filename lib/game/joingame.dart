import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> joinGame(String gameId, String playerId) async {
  DocumentReference gameRef = FirebaseFirestore.instance.collection('games').doc(gameId);
  await gameRef.update({
    'players': FieldValue.arrayUnion([playerId]),
  });
}