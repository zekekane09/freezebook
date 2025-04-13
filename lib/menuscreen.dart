import 'dart:convert'; // Import for JSON decoding

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freezebook/api_config.dart'; // Ensure this is your actual API service
import 'package:freezebook/pusoy13game.dart';
import 'package:freezebook/utils/sharedpreferencesextension.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'game/num_player_indicator.dart'; // Import http for API calls

class CreateGameScreen extends StatefulWidget {
  @override
  _CreateGameScreenState createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final TextEditingController gameNameController = TextEditingController();
  late Future<List<Map<String, dynamic>>> futureGames;
  bool isLoading = true;
  bool hasError = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    // ApiService.getNumberOfPlayerInRoom(30);
    _loadGames();
  }
  Future<void> _loadGames() async {
    try {
      futureGames = ApiService.getGames() ;
      setState(() {
      }); // Trigger a rebuild to show the games
    } catch (e) {
      // Handle any errors that occur during the fetch
      print("Error loading games: $e");
    }
  }

  @override
  void dispose() {
    // Restore the system UI when leaving the screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    gameNameController.dispose(); // Dispose of the controller
    super.dispose();
  }
  Future<void> _joingame(int games_id) async {
    // int currentPlayers = await ApiService.getPlayerInRoom(games_id);
    // String response = await ApiService.joinGame(games_id,games_id);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) =>  Pusoy13Game()),
    // );
    try {
      // Fetch the current number of players in the room
      // int currentPlayers = await ApiService.getPlayerInRoom(games_id);
      //
      // // Determine the player name based on the current number of players
      // String playerName;
      // if (currentPlayers == 0) {
      //   playerName = "Player 1"; // First player
      // } else if (currentPlayers == 1) {
      //   playerName = "Player 2"; // Second player
      // } else if (currentPlayers == 2) {
      //   playerName = "Player 3"; // Third player
      // } else if (currentPlayers == 3) {
      //   playerName = "Player 4"; // Fourth player
      // } else {
      //   // If the game is full, you might want to handle this case
      //   Fluttertoast.showToast(
      //     msg: "The game is full. You cannot join.",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 5,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0,
      //   );
      //   return; // Exit the function if the game is full
      // }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? playerId = prefs.getStringKey(SharedPreferencesKeys.playerId);
      String? username = prefs.getStringKey(SharedPreferencesKeys.playerId);
      print("PLAYER ID: $playerId");
      // Join the game with the determined player name
      String response = await ApiService.joinGame(playerId!, games_id);
      print("Join Game Response: $response");

      // Navigate to the game screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Pusoy13Game(username: username)),
      );
    } catch (e) {
      print("Error joining game: $e");
      Fluttertoast.showToast(
        msg: "Failed to join game: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  Future<void> _createNewGame() async {
    if (gameNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a game name')),
      );
      return;
    }
    // String response = await ApiService.createGame(gameNameController.text);
    // print("Game ID: $response");
    // Fluttertoast.showToast(
    //   msg: "Successfully created game: $response",
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.BOTTOM,
    //   timeInSecForIosWeb: 5,
    //   backgroundColor: Colors.white,
    //   textColor: Colors.black,
    //   fontSize: 16.0,
    // );
    Navigator.of(context).pop(); // Close the dialog after creating the game
  }

  Future<void> _showCreateGameDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Game'),
          content: TextField(
            controller: gameNameController,
            decoration: InputDecoration(
              labelText: "Game Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Create'),
              onPressed: () {
                _createNewGame();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _showJoinGameDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const
          Text('Game List'),
          content: SingleChildScrollView(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureGames,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No games available."));
                } else {
                  final games = snapshot.data!;
                  return Wrap(
                    children: games.map((game) {
                      return GestureDetector(
                        onTap: () {
                          _joingame(game["id"]);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4.0,
                                offset: const Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  game["game_name"] ?? "Unknown Game",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                              // const SizedBox(width: 8.0), // Space between name and status
                              Text(game["status"] ?? "Unknown Status"),
                              SizedBox(width: 10,),
                              // Assuming you have a key for player count, replace 'player_count' with the actual key
                        GamePlayerIndicator(
                          currentPlayers: game["_players_of_games"], // Use the fetched player count
                        )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create or Join Game"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _showCreateGameDialog,
                child: Text("Create New Game"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showJoinGameDialog,
                child: Text("Join Game"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
