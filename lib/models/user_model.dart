class UserModel {
  final String id;
  final String nom;
  final String prenom;
  final String numero;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.numero,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("USER JSON: $json"); // ← Ajout de debug
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      nom: json['nom'] ?? 'NOM MANQUANT',
      prenom: json['prenom'] ?? 'PRENOM MANQUANT',
      numero: json['numero'] ?? 'NUMERO MANQUANT',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom, 'prenom': prenom, 'numero': numero};
  }
}
