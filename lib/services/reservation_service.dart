import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ticket_cine/models/reservation.dart';
import 'auth_service.dart';
import 'package:logger/logger.dart';

class ReservationService {
  //static const String _localUrl = 'http://localhost:3000'; // Remplacez par votre URL
  // ip a rabtech
  static const String _localUrl = 'http://192.168.1.8:3000';
  static const String onlineUrl = 'https://cinema-api-chi.vercel.app';
  // ip chez moi
  //static const String _localUrl = 'http://192.168.0.102:3000';
  final AuthService _authService = AuthService();
  Logger log = Logger();

  Future<Reservationne> createReservation({
    required String seanceId,
    required String userId,
    required int prixTotal,
    required String numeroSiege,
    String statut = 'confirmée',
  }) async {
    try {
      // Récupérer le token JWT
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Préparer le corps de la requête
      final requestBody = json.encode({
        'seanceId': seanceId,
        'userId': userId,
        'prixTotal': prixTotal,
        'numeroSiege': numeroSiege,
        'statut': statut,
      });

      // Envoyer la requête POST
      final response = await http.post(
        Uri.parse('$onlineUrl/reservations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      // Traiter la réponse
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body)as Map<String, dynamic>;
        log.d("Les réservation ${responseData['reservation']}");
        return Reservationne.fromJson(responseData['reservation']);
      } else {
        log.e('Échec de la création de réservation: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Échec de la création de réservation: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      log.e("Erreur lors de la création de réservation: $e");
      throw Exception('Erreur lors de la création de réservation: $e');
    }
  }

  Future<ReservationResponse> getReservations() async {
    try {
      //final token = await _authService.getToken();
      final response = await http.get(Uri.parse('$onlineUrl/reservations'));

      if (response.statusCode == 200) {
        return ReservationResponse.fromJson(json.decode(response.body));
      } else {
        log.e('Erreur de chargement des reservations: ${response.body} ${response.statusCode}');
        throw Exception('Erreur de chargement des reservations: ${response.body} ${response.statusCode}');
      }
    } catch (e) {
      log.e('Erreur de chargement des reservations: $e');
      throw Exception('Erreur de chargement des reservations: $e');
    }
  }

  Future<ReservationResponse> getReservationsByUser(String userId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$onlineUrl/reservations/user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        log.d('Reservations du User ${response.body} ${response.statusCode}');
        return ReservationResponse.fromJson(json.decode(response.body));
      } else {
        log.e('Erreur de chargement des reservations du user: ${response.body} ${response.statusCode}');
        throw Exception('Erreur de chargement des reservations: ${response.body}');
      }
    } catch (e) {
      log.e('Erreur de chargement des reservations: $e');
      throw Exception('Erreur de chargement des reservations: $e');
    }
  }

  Future<Reservation> getReservationById(String reservationId) async {
    try {
      final response = await http.get(
        Uri.parse('$onlineUrl/reservations/$reservationId'),
        // Tu peux ajouter le token ici si nécessaire :
        // headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log.d("Les réservations ${data['reservation']}");
        return Reservation.fromJson(data['reservation']);
      } else {
        log.e('Erreur lors de la récupération de la réservation : ${response.body}');
        throw Exception(
          'Erreur lors de la récupération de la réservation : ${response.body}',
        );
      }
    } catch (e) {
      log.e('Erreur lors de la récupération de la réservation : $e');
      throw Exception('Erreur lors de la récupération de la réservation : $e');
    }
  }

  Future<Reservation> updateReservation({
    required String reservationId,
    int? nombrePlaces,
    int? prixTotal,
    String? statut,
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await http.put(
        Uri.parse('$onlineUrl/reservations/$reservationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          if (nombrePlaces != null) 'nombrePlaces': nombrePlaces,
          if (prixTotal != null) 'prixTotal': prixTotal,
          if (statut != null) 'statut': statut,
        }),
      );

      if (response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body)['reservation']);
      } else {
        throw Exception('Failed to update reservation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update reservation: $e');
    }
  }

  Future<void> deleteReservation(String reservationId) async {
    try {
      //final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('$onlineUrl/reservations/$reservationId'),
        //headers: {
        //  'Authorization': 'Bearer $token',
        //},
      );

      if (response.statusCode != 200) {
        log.e('Erreur lors de la suppression de la réservation : ${response.body}');
        throw Exception('Failed to delete reservation: ${response.body}');
      }
    } catch (e) {
      log.e('Erreur lors de la suppression de la réservation : $e');
      throw Exception('Failed to delete reservation: $e');
    }
  }

  Future<bool> canModifyReservation(String reservationId) async {
    try {
      //final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$onlineUrl/reservations/$reservationId/check'),
        //headers: {
        //  'Authorization': 'Bearer $token',
        //},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['canModify'];
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getReservedSeats(String seanceId) async {
    final response = await http.get(
      Uri.parse('$onlineUrl/reservations/seance/$seanceId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      log.d("Les réservations ${data}");
      return data.cast<String>();
    } else {
      throw Exception('Erreur lors du chargement des sièges réservés');
    }
  }

  Future<bool> checkExistingReservation({
    required String userId,
    required String seanceId,
  }) async {
    try {
      final reservationResponse = await getReservationsByUser(userId);

      // Vérifiez si la réponse contient des réservations
      if (reservationResponse.reservations.isEmpty) {
        return false;
      }

      return reservationResponse.reservations.any(
        (r) => r.seance.id == seanceId,
      );
    } catch (e) {
      // Log l'erreur et considère qu'il n'y a pas de réservation existante
      debugPrint('Error checking existing reservation: $e');
      return false;
    }
  }
}
