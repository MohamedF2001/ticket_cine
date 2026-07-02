import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticket_cine/models/session_response.dart';

class SessionService {
  static const String onlineUrl = 'https://cinema-api-chi.vercel.app';
  final Logger log = Logger();

  Future<SessionResponse> getAllSeances() async {
    try {
      final response = await http.get(Uri.parse('$onlineUrl/seances'));
      if (response.statusCode == 200) {
        return SessionResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load seances: ${response.statusCode}');
      }
    } catch (e) {
      log.e("GET ALL SEANCES ERROR: $e");
      rethrow;
    }
  }

  Future<Session> getSeanceById(String id) async {
    try {
      final response = await http.get(Uri.parse('$onlineUrl/seances/$id'));
      if (response.statusCode == 200) {
        return Session.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load seance: ${response.statusCode}');
      }
    } catch (e) {
      log.e("GET SEANCE BY ID ERROR: $e");
      rethrow;
    }
  }

  Future<SessionResponse> getSeancesByFilm(String filmId) async {
    try {
      final response = await http.get(Uri.parse('$onlineUrl/seances/film/$filmId'));
      if (response.statusCode == 200) {
        return SessionResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load seances for film: ${response.statusCode}');
      }
    } catch (e) {
      log.e("GET SEANCES BY FILM ERROR: $e");
      rethrow;
    }
  }

  Future<SessionResponse> getSeancesByDate(DateTime date) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await http.get(Uri.parse('$onlineUrl/seances/date/$dateString'));
      if (response.statusCode == 200) {
        return SessionResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load seances for date: ${response.statusCode}');
      }
    } catch (e) {
      log.e("GET SEANCES BY DATE ERROR: $e");
      rethrow;
    }
  }

  Future<SessionResponse> createSeance(Map<String, dynamic> seanceData) async {
    try {
      final response = await http.post(
        Uri.parse('$onlineUrl/seances'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(seanceData),
      );
      if (response.statusCode == 200) {
        return SessionResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create seance: ${response.statusCode}');
      }
    } catch (e) {
      log.e("CREATE SEANCE ERROR: $e");
      rethrow;
    }
  }

  Future<SessionResponse> updateSeance(String id, Map<String, dynamic> seanceData) async {
    try {
      final response = await http.put(
        Uri.parse('$onlineUrl/seances/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(seanceData),
      );
      if (response.statusCode == 200) {
        return SessionResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update seance: ${response.statusCode}');
      }
    } catch (e) {
      log.e("UPDATE SEANCE ERROR: $e");
      rethrow;
    }
  }

  Future<SessionResponse> updatePlacesDisponibles(String id, int placesDisponibles) async {
    try {
      final response = await http.patch(
        Uri.parse('$onlineUrl/seances/$id/places'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'placesDisponibles': placesDisponibles}),
      );
      if (response.statusCode == 200) {
        return SessionResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update places: ${response.statusCode}');
      }
    } catch (e) {
      log.e("UPDATE PLACES ERROR: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteSeance(String id) async {
    try {
      final response = await http.delete(Uri.parse('$onlineUrl/seances/$id'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete seance: ${response.statusCode}');
      }
    } catch (e) {
      log.e("DELETE SEANCE ERROR: $e");
      rethrow;
    }
  }
}
