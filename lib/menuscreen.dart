import 'dart:convert'; // Import for JSON decoding

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freezebook/api_config.dart'; // Ensure this is your actual API service
import 'package:http/http.dart' as http; // Import http for API calls

class CreateGameScreen extends StatefulWidget {
  @override
  _CreateGameScreenState createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final TextEditingController gameNameController = TextEditingController();
  Future<List<Map<String, dynamic>>>? futureGames;
  int _players = 0;
  bool isLoading = true;
  bool hasError = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    _fetchPlayers();
    ApiService.getNumberOfPlayerInRoom();
  }
  Future<void> _loadGames() async {
    try {
      futureGames = ApiService.getGames() as Future<List<Map<String, dynamic>>>?;
      setState(() {}); // Trigger a rebuild to show the games
    } catch (e) {
      // Handle any errors that occur during the fetch
      print("Error loading games: $e");
    }
  }
  void _fetchPlayers() async {
    try {
      int fetchedPlayers = await ApiService.getNumberOfPlayerInRoom();
      if (mounted) {
        setState(() {
          _players = fetchedPlayers;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching players: $e");
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }
  }
  @override
  void dispose() {
    // Restore the system UI when leaving the screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    gameNameController.dispose(); // Dispose of the controller
    super.dispose();
  }
  Future<void> _joingame(int Gameid) async {
    String response = await ApiService.joinGame(8,Gameid);
  }
  Future<void> _createNewGame() async {
    if (gameNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a game name')),
      );
      return;
    }
    String response = await ApiService.createGame(gameNameController.text);
    print("Game ID: $response");
    Fluttertoast.showToast(
      msg: "Successfully created game: $response",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
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
          title: const Text('Game List'),
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
                                offset: Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  game["game_name"] ?? "Unknown Game",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8.0), // Space between name and status
                              Text(game["status"] ?? "Unknown Status"),
                              Text(game[_players])
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
