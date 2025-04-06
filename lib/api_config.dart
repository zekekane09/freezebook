import 'dart:convert';
import 'package:freezebook/data/baseresponse.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static const String apiKey = '8679b9a37d18e8e2cfa09055467f06ae';
  static const String baseUrls = 'https://api.themoviedb.org/';
  static const String popularMovies = '$baseUrls/movie/popular?api_key=$apiKey';
}

class ApiService {
  static const String baseUrl = "https://x8ki-letl-twmt.n7.xano.io";
  static Future<List<Map<String, dynamic>>> getGames() async {
    final url = "$baseUrl/api:oMkvQ-3B/games";
    final body = jsonEncode({});
    print("🔹 [GET GAMES] Sending Request: $url");
    print("🔹 Headers: { Content-Type: application/json }");
    print("🔹 Body: $body");
    final response = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );
    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> gamesList = responseData['games'];
        print("🔹 Response Data: $responseData");

        List<Map<String, dynamic>> games = gamesList.map((game) {
          return {
            "id": game["id"],
            "game_name": game["game_name"] ?? "Unknown Game",
            "status": game["status"] ?? "Unknown Status",
            "deck": game["deck"] ?? 0,
            "_players_of_games": game["_players_of_games"] ?? 0,
          };
        }).toList();
        return games; // Return the list of games on success
      } else {
        throw Exception("ddddddssss to load games: ${response.body}");
      }
    } catch (e) {
      print("🔹 Error: $e");
      throw Exception("Failed to load games: $e");
    }
  }
  /// Creates a new game
  static Future<String> createGame(String gameName) async {
    final url = "$baseUrl/api:oMkvQ-3B/games";
    final body = jsonEncode({"game_name": gameName});

    print("🔹 [CREATE GAME] Sending Request: $url");
    print("🔹 Headers: { Content-Type: application/json }");
    print("🔹 Body: $body");

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("🔹 Response Status: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData["game_name"];
    } else {
      throw Exception("Failed to create game: ${response.body}");
    }
  }
  static Future<String> joinGame(String playerId, int gameId) async {
    final url = "$baseUrl/api:oMkvQ-3B/players/$playerId";
    final body = jsonEncode({"games_id": gameId});

    print("🔹 [JOIN GAME] Sending Request: $url");
    print("🔹 Headers: { Content-Type: application/json }");
    print("🔹 Body: $body");

    final response = await http.patch(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("🔹 Response Status: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if "game_name" exists in the response
      if (responseData.containsKey("game_name")) {
        return responseData["game_name"];
      } else {
        // Handle the case where "game_name" does not exist
        return "Game joined successfully, but no name was provided."; // or return a default value
      }
    } else {
      throw Exception("Failed to join game: ${response.body}");
    }
  }
  // static Future<int> getPlayerInRoom(int games_id) async {
  //
  //   final url = "$baseUrl/api:oMkvQ-3B/game/fetch_players";
  //   final body = jsonEncode({"games_id": games_id});
  //   print("🔹 [NUMBER OF PLAYER IN ROOM] Sending Request: $url");
  //   print("🔹 Headers: { Content-Type: application/json }");
  //   print("🔹 Body: $body");
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: body,
  //     );
  //
  //     print("🔹 Response Status: ${response.statusCode}");
  //     print("🔹 Response Body: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //
  //       // Check if the "Players" key exists and return the list of players
  //       if (jsonResponse.containsKey("Players")) {
  //         final List<dynamic> players = jsonResponse["Players"];
  //         final int numberOfPlayers = players.length; // Get the number of players
  //         print("Number of players: $numberOfPlayers");
  //
  //         return numberOfPlayers;
  //       } else {
  //         throw Exception("Response does not contain 'Players' key");
  //       }
  //     } else {
  //       throw Exception("Failed to fetch players: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     print("❌ Error fetching players: $e");
  //     throw Exception("Error fetching players: $e");
  //   }
  // }

  /// Fetch shuffled deck of cards
  static Future<List<String>> getCards() async {
    final url = "$baseUrl/api:oMkvQ-3B/game/shuffle_and_deal";
    final body = jsonEncode({"games_id": 31});

    print("🔹 [GET CARDS] Sending Request: $url");
    print("🔹 Headers: { Content-Type: application/json }");
    print("🔹 Body: $body");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("🔹 Response Status: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        return List<String>.from(jsonResponse["deck"]);
      } else {
        throw Exception("Failed to fetch shuffled deck: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching deck: $e");
      throw Exception("Error fetching shuffled deck");
    }
  }
  // https://x8ki-letl-twmt.n7.xano.io/api:oMkvQ-3B/players/login
  /// Creates a new user
  static Future<BaseResponse> createUser(User user) async {
    // https://x8ki-letl-twmt.n7.xano.io/api:oMkvQ-3B/players
    // https://x8ki-letl-twmt.n7.xano.io/api:oMkvQ-3B/players
    final url = "$baseUrl/api:oMkvQ-3B/players";
    // final url = "$baseUrl/api:ktP3aUwj/auth/signup";
    final body = jsonEncode(user.toJson());
    print("🔹 [CREATE USER] Sending Request: $url");
    print("🔹 Headers: { Content-Type: application/json }");
    print("🔹 Body: $body");

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("🔹 Response Status: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userData = responseData["user"];
      int playerId = userData["id"];
      String username = userData["username"];
      // String authToken = responseData["authToken"];
      await _saveAuthToken(
          // authToken,
          "$playerId",username);
      return BaseResponse(
        code: "SUCCESS",
        message: "User created successfully.",
        payload: "authToken",
      );
    } else {
      return BaseResponse(
        code: responseData["code"] ?? "UNKNOWN_ERROR",
        message: responseData["message"] ?? "An unknown error occurred.",
        payload: responseData["payload"],
      );
    }
  }
  static Future<BaseResponse> login(String email,String password) async {
    // https://x8ki-letl-twmt.n7.xano.io/api:oMkvQ-3B/players/login
    final url = "$baseUrl/api:oMkvQ-3B/players/login";
    // final url = "$baseUrl/api:ktP3aUwj/auth/signup";
    final body = jsonEncode({"email": email,"password": password});
    print("🔹 [CREATE USER] Sending Request: $url");
    print("🔹 Headers: { Content-Type: application/json }");
    print("🔹 Body: $body");

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("🔹 Response Status: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userData = responseData["user"];
      int playerId = userData["id"];
      String username = userData["username"];
      // String authToken = responseData["authToken"];
      await _saveAuthToken(
          // authToken,
          "$playerId",username);
      return BaseResponse(
        code: "SUCCESS",
        message: "User created successfully.",
        payload: "authToken",
      );
    } else {
      return BaseResponse(
        code: responseData["code"] ?? "UNKNOWN_ERROR",
        message: responseData["message"] ?? "An unknown error occurred.",
        payload: responseData["payload"],
      );
    }
  }
  /// Saves auth token in SharedPreferences
  static Future<void> _saveAuthToken(
      // String authToken,
      String playerId,String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     // await prefs.setString('authToken', authToken);
    await prefs.setString('playerId', playerId);
    await prefs.setString('username', username);
    // print("🔹 Auth token saved: $token");
    // print("🔹 AuthToken saved: $authToken");
    print("🔹 PlayerId saved: $playerId");
    print("🔹 Username saved: $username");
  }

  /// Retrieves auth token from SharedPreferences
  static Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }
}

/// User Model
class User {
  final String fullname;
  final String email;
  final String password;
  final String birthday;
  final String username;
  final String platform;
  final String fcm_token;

  User({
    required this.fullname,
    required this.password,
    required this.email,
    required this.birthday,
    required this.username,
    required this.fcm_token,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'password': password,
      'birthday': birthday,
      'username': username,
      'fcm_token': fcm_token,
      'platform': platform,
    };
  }
}
