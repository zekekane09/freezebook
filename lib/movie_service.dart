import 'package:freezebook/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'package:logger/logger.dart';

class MovieService {
  final LoggingHttpClient _httpClient;

  MovieService() : _httpClient = LoggingHttpClient(http.Client());

  Future<List<Movie>> fetchPopularMovies() async {
    final response = await _httpClient.get(Constants.popularMovies);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList(); // Map to Movie model
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<String> fetchVideoUrl(String movieId) async {
    final response = await _httpClient.get('https://api.example.com/videos/$movieId'); // Replace with your video API
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['videoUrl']; // Adjust based on your API response structure
    } else {
      throw Exception('Failed to load video URL');
    }
  }
}

class LoggingHttpClient {
  final http.Client _client;
  final Logger _logger;

  LoggingHttpClient(this._client) : _logger = Logger();

  Future<http.Response> get(String url) async {
    _logger.d('httprequest: GET Request: $url');
    final response = await _client.get(Uri.parse(url));
    _logger.d('httprequest: Response: ${response.statusCode} ${response.body}');
    return response;
  }

  Future<http.Response> post(String url, {Map<String, String>? headers, Object? body}) async {
    _logger.d('httprequest: POST Request: $url');
    _logger.d('httprequest: Request Body: ${body != null ? body.toString() : 'null'}');
    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    _logger.d('httprequest: Response: ${response.statusCode} ${response.body}');
    return response;
  }

// You can add more methods (PUT, DELETE, etc.) similarly
}