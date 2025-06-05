import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/models/user_model.dart';

class Reservationne {
  final String id;
  final String seanceId;  // Changé de Session à String
  final String userId;    // Changé de UserModel à String
  final String numeroSiege;
  final double prixTotal;
  final String statut;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservationne({
    required this.id,
    required this.seanceId,  // Maintenant une String
    required this.userId,    // Maintenant une String
    required this.numeroSiege,
    required this.prixTotal,
    required this.statut,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservationne.fromJson(Map<String, dynamic> json) {
    return Reservationne(
      id: json['_id'],
      seanceId: json['seanceId'],  // Directement la String
      userId: json['userId'],      // Directement la String
      numeroSiege: json['numeroSiege'] ?? '',
      prixTotal: (json['prixTotal'] is int)
          ? (json['prixTotal'] as int).toDouble()
          : json['prixTotal'] ?? 0.0,
      statut: json['statut'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seanceId': seanceId,  // Envoie juste l'ID
      'userId': userId,      // Envoie juste l'ID
      'numeroSiege': numeroSiege,
      'prixTotal': prixTotal,
      'statut': statut,
    };
  }
}

class Reservation {
  final String id;
  final Session seance;
  final UserModel user;
  final String numeroSiege;
  final double prixTotal;
  final String statut;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservation({
    required this.id,
    required this.seance,
    required this.user,
    required this.numeroSiege,
    required this.prixTotal,
    required this.statut,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    print("RESERVATION JSON: $json"); // ← Ajout de debug
    return Reservation(
      id: json['_id'],
      //seance: Session.fromJson(json['seanceId']),
      seance: Session.fromJson(json['seanceId']),
      user: UserModel.fromJson(json['userId']),
      numeroSiege: json['numeroSiege'] ?? '',
      prixTotal:
          (json['prixTotal'] is int)
              ? (json['prixTotal'] as int).toDouble()
              : json['prixTotal'] ?? 0.0,
      statut: json['statut'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seanceId': seance.toJson(),
      'userId': user.toJson(),
      'numeroSiege': numeroSiege,
      'prixTotal': prixTotal,
      'statut': statut,
    };
  }
}

class ReservationResponse {
  final bool success;
  final List<Reservation> reservations;

  ReservationResponse({required this.success, required this.reservations});

  factory ReservationResponse.fromJson(Map<String, dynamic> json) {
    return ReservationResponse(
      success: json['success'] ?? false,
      reservations:
          (json['reservations'] as List? ?? [])
              .map((item) => Reservation.fromJson(item))
              .toList(),
    );
  }
}


/* class ReservationResponse {
  final bool success;
  final List<Reservation> reservations;

  ReservationResponse({required this.success, required this.reservations});

  factory ReservationResponse.fromJson(Map<String, dynamic> json) {
    return ReservationResponse(
      success: json['success'] ?? false,
      reservations:
          (json['reservations'] as List?)
              ?.map((item) => Reservation.fromJson(item))
              .toList() ??
          [],
    );
  }
}
 */