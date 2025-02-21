// import 'package:cloud_firestore/cloud_firestore.dart';
//
//
// @override
// void initState() {
//   super.initState();
//   _initializeGame();
//   if (gameId.isNotEmpty) {
//     _listenToGame(gameId);
//   }
// }
// void listenToGame(String gameId) {
//   FirebaseFirestore.instance.collection('games').doc(gameId).snapshots().listen((snapshot) {
//     if (snapshot.exists) {
//       // Update your game state based on the snapshot data
//     }
//   });
// }