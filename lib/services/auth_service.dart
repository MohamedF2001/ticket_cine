import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_cine/models/user_model.dart';

class AuthService {
  //static const String baseUrl = 'http://localhost:3000';
  // ip a rabtech
  //static const String baseUrl = 'http://192.168.1.8:3000';
  static const String onlineUrl = 'https://cinema-api-chi.vercel.app';
  // ip chez moi
  //static const String baseUrl = 'http://192.168.0.102:3000';
  Logger log = Logger();

  Future<UserModel?> login(
    String nom,
    String prenom,
    String numero,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$onlineUrl/login'),
      body: {
        'nom': nom,
        'prenom': prenom,
        'numero': numero,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        log.d("TOKEN: ${data['token']}");
        log.d("USER: ${data['user']}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return UserModel.fromJson(data['user']);
      }
    }
    return null;
  }

  Future<UserModel?> register(
    String nom,
    String prenom,
    String numero,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$onlineUrl/register'),
      body: {
        'nom': nom,
        'prenom': prenom,
        'numero': numero,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        log.d("USER: ${data['user']}");
        log.d("TOKEN: ${data['token']}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return UserModel.fromJson(data['user']);
      }
    }
    return null;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return; // Aucun token => déjà déconnecté

    final response = await http.get(
      Uri.parse('$onlineUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await prefs.remove('token');
      log.d('Déconnexion réussie');
    } else {
      throw Exception('Erreur lors de la déconnexion : ${response.statusCode}');
    }
  }


  /*Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.remove('token');
    await prefs.clear(); // pour tout supprimer
  }*/

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    log.d("GET TOKEN: $token");
    return token;
  }

  Future<UserModel?> getUser() async {
    final token = await getToken();

    // Si le token est null ou vide, retourner null
    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse('$onlineUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    // Vérifier si la réponse est valide
    print("Response: ${response.body}");
    print("Status Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        log.d("GET USER: ${data['user']}");
        return UserModel.fromJson(data['user']);
      }
    }

    return null;
  }
}
