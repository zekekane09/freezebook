// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// StreamBuilder<DocumentSnapshot>(
// stream: FirebaseFirestore.instance.collection('games').doc(gameId).snapshots(),
// builder: (context, snapshot) {
// if (snapshot.hasData) {
// var gameData = snapshot.data.data();
// // Build your UI based on gameData
// }
// return CircularProgressIndicator();
// },
// );