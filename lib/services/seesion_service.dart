import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticket_cine/models/movie_response.dart';
import 'package:ticket_cine/models/session_response.dart';

class SessionService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  //static const String _localUrl = 'http://localhost:3000';
  static const String _localUrl = 'http://192.168.1.8:3000';
  //static const String _localUrl = 'http://192.168.0.102:3000';
  static const String onlineUrl = 'https://cinema-api-chi.vercel.app';
  final String _apiKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwM2RjYTJlNWVlMWJjZWEzZDc0ZWI5YTYyNjRhYjdlYiIsIm5iZiI6MTY5NTEzMTI5OS43ODgsInN1YiI6IjY1MDlhNmEzZmEyN2Y0MDEwYzRjMDIxYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.IchWLNeqrFklFPYRTE4v-E0eOh-xG7OA3Ry_Bpa9rRI';

  Logger log = Logger();
  Future<List<Movie>> fetchNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/now_playing?language=en-US&page=1'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      log.d("film ${response.body}");
      return MovieResponse.fromJson(json.decode(response.body)).results;
    } else {
      log.e('Erreur de chargement des films: ${response.statusCode}');
      throw Exception('Failed to load movies');
    }
  }

  Future<SessionResponse> getAllSeances() async {
    final response = await http.get(Uri.parse('$onlineUrl/seances'));

    if (response.statusCode == 200) {
      log.d("Les seances ${response.body}");
      return SessionResponse.fromJson(json.decode(response.body));
    } else {
      log.e('Erreur de chargement des seances: ${response.statusCode}');
      throw Exception('Échec de chargement des séances');
    }
  }

  // Récupérer une séance par ID
  /* Future<SessionResponse> getSeanceById(String id) async {
    final response = await http.get(Uri.parse('$_localUrl/seances/$id'));

    if (response.statusCode == 200) {
      return SessionResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec de chargement de la séance');
    }
  } */

  Future<Session> getSeanceById(String id) async {
    final response = await http.get(Uri.parse('$onlineUrl/seances/$id'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      log.d("Les seances ${jsonResponse}");
      return Session.fromJson(jsonResponse);
    } else {
      log.e('Erreur de chargement des seances: ${response.statusCode}');
      throw Exception('Failed to load seance');
    }
  }

  // Récupérer les séances par film
  Future<SessionResponse> getSeancesByFilm(String filmId) async {
    final response = await http.get(
      Uri.parse('$onlineUrl/seances/film/$filmId'),
    );

    if (response.statusCode == 200) {
      log.d("Les seances ${response.body}");
      return SessionResponse.fromJson(json.decode(response.body));
    } else {
      log.e('Erreur de chargement des seances: ${response.statusCode}');
      throw Exception('Échec de chargement des séances pour ce film');
    }
  }

  // Récupérer les séances par date
  Future<SessionResponse> getSeancesByDate(DateTime date) async {
    // Format de date YYYY-MM-DD
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await http.get(
      Uri.parse('$onlineUrl/seances/date/$dateString'),
    );

    if (response.statusCode == 200) {
      return SessionResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec de chargement des séances pour cette date');
    }
  }

  // Créer une nouvelle séance
  Future<SessionResponse> createSeance(Map<String, dynamic> seanceData) async {
    final response = await http.post(
      Uri.parse('$onlineUrl/seances'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(seanceData),
    );

    if (response.statusCode == 200) {
      log.d("Les seances ${response.body}");
      return SessionResponse.fromJson(json.decode(response.body));
    } else {
      log.e('Erreur de chargement des seances: ${response.statusCode}');
      throw Exception('Échec de création de la séance');
    }
  }

  // Mettre à jour une séance
  Future<SessionResponse> updateSeance(
    String id,
    Map<String, dynamic> seanceData,
  ) async {
    final response = await http.put(
      Uri.parse('$onlineUrl/seances/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(seanceData),
    );

    if (response.statusCode == 200) {
      log.d("Les seances ${response.body}");
      return SessionResponse.fromJson(json.decode(response.body));
    } else {
      log.e('Erreur de chargement des seances: ${response.statusCode}');
      throw Exception('Échec de mise à jour de la séance');
    }
  }

  // Mettre à jour le nombre de places disponibles
  Future<SessionResponse> updatePlacesDisponibles(
    String id,
    int placesDisponibles,
  ) async {
    final response = await http.patch(
      Uri.parse('$onlineUrl/seances/$id/places'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'placesDisponibles': placesDisponibles}),
    );

    if (response.statusCode == 200) {
      log.d("Les seances ${response.body}");
      return SessionResponse.fromJson(json.decode(response.body));
    } else {
      log.e('Erreur de chargement des seances: ${response.statusCode}');
      throw Exception('Échec de mise à jour des places disponibles');
    }
  }

  // Supprimer une séance
  Future<Map<String, dynamic>> deleteSeance(String id) async {
    final response = await http.delete(Uri.parse('$onlineUrl/seances/$id'));

    if (response.statusCode == 200) {
      log.d("Les seances ${response.body}");
      return json.decode(response.body);
    } else {
      log.e('Erreur de chargement des seances: ${response.statusCode}');
      throw Exception('Échec de suppression de la séance');
    }
  }
}
