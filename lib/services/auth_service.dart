import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_cine/models/user_model.dart';

class AuthService {
  static const String onlineUrl = 'https://cinema-api-chi.vercel.app';
  final Logger log = Logger();

  Future<UserModel?> login(
    String nom,
    String prenom,
    String numero,
    String password,
  ) async {
    try {
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
        if (data['success'] == true) {
          log.d("LOGIN SUCCESS - TOKEN: ${data['token']}");
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          return UserModel.fromJson(data['user']);
        }
      }
      log.w("LOGIN FAILED - STATUS: ${response.statusCode}");
    } catch (e) {
      log.e("LOGIN ERROR: $e");
    }
    return null;
  }

  Future<UserModel?> register(
    String nom,
    String prenom,
    String numero,
    String password,
  ) async {
    try {
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
        if (data['success'] == true) {
          log.d("REGISTER SUCCESS - TOKEN: ${data['token']}");
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          return UserModel.fromJson(data['user']);
        }
      }
      log.w("REGISTER FAILED - STATUS: ${response.statusCode}");
    } catch (e) {
      log.e("REGISTER ERROR: $e");
    }
    return null;
  }

  Future<void> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        await http.get(
          Uri.parse('$onlineUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      }
      await prefs.remove('token');
      log.d('DECONNEXION REUSSIE');
    } catch (e) {
      log.e("LOGOUT ERROR: $e");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<UserModel?> getUser() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.get(
        Uri.parse('$onlineUrl/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['user']);
        }
      }
    } catch (e) {
      log.e("GET USER ERROR: $e");
    }
    return null;
  }
}
