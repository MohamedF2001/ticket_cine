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
    print("RESERVATION JSON: $json");
    
    Session seanceObj;
    if (json['seanceId'] is Map<String, dynamic>) {
      seanceObj = Session.fromJson(json['seanceId'] as Map<String, dynamic>);
    } else if (json['seanceId'] is Map) {
      seanceObj = Session.fromJson(Map<String, dynamic>.from(json['seanceId']));
    } else if (json['seance'] is Map<String, dynamic>) {
      seanceObj = Session.fromJson(json['seance'] as Map<String, dynamic>);
    } else if (json['seance'] is Map) {
      seanceObj = Session.fromJson(Map<String, dynamic>.from(json['seance']));
    } else {
      seanceObj = Session(
        id: json['seanceId']?.toString() ?? '',
        filmId: 0,
        film: 'Film',
        imgFilm: '',
        horaire: DateTime.now(),
        date: DateTime.now(),
        salle: '',
        typeSeance: '',
        prix: 0,
        placesDisponibles: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        v: 0,
      );
    }

    UserModel userObj;
    if (json['userId'] is Map<String, dynamic>) {
      userObj = UserModel.fromJson(json['userId'] as Map<String, dynamic>);
    } else if (json['userId'] is Map) {
      userObj = UserModel.fromJson(Map<String, dynamic>.from(json['userId']));
    } else if (json['user'] is Map<String, dynamic>) {
      userObj = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json['user'] is Map) {
      userObj = UserModel.fromJson(Map<String, dynamic>.from(json['user']));
    } else {
      userObj = UserModel(
        id: json['userId']?.toString() ?? '',
        nom: '',
        prenom: '',
        numero: '',
      );
    }

    return Reservation(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      seance: seanceObj,
      user: userObj,
      numeroSiege: json['numeroSiege']?.toString() ?? '',
      prixTotal: (json['prixTotal'] is int)
          ? (json['prixTotal'] as int).toDouble()
          : (json['prixTotal'] is double ? json['prixTotal'] : double.tryParse(json['prixTotal']?.toString() ?? '0') ?? 0.0),
      statut: json['statut']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now() : DateTime.now(),
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