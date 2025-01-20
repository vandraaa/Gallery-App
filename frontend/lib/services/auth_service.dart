import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gallery_app/components/alert.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> isExpired(String token) async {
    if (token.isEmpty) {
      return true;
    }

    try {
      final expiryDate = Jwt.getExpiryDate(token);
      if (expiryDate != null) {
        return expiryDate.isBefore(DateTime.now());
      }
      return true;
    } catch (e) {
      print("Error decoding token: $e");
      return true;
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final decodedToken = Jwt.parseJwt(token);
    print(decodedToken);
    return decodedToken;
  }
}

Future<void> signIn(BuildContext context, String email, String password) async {
  final url = Uri.parse('$baseUrl/users/login');
  final headers = {
    "Access-Control-Allow-Origin": "*",
    'Content-Type': 'application/json',
    'Accept': '*/*',
  };
  final body = json.encode({"email": email, "password": password});

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      await AuthService().saveToken(responseData['token']);
      await AuthService().getUserData();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const HomeScreen(initialIndex: 0)),
      );

      showAlert(context, responseData['message'], true);
    } else {
      final responseData = json.decode(response.body)['message'];
      showAlert(context, responseData, false);
    }
  } catch (e) {
    print('Error: ${e.toString()}');
    showAlert(context, e.toString(), false);
  }
}

Future<void> signUpUser(
    BuildContext context, String name, String email, String password) async {
  final url = Uri.parse('$baseUrl/users');
  final headers = {
    "Access-Control-Allow-Origin": "*",
    'Content-Type': 'application/json',
    'Accept': '*/*',
  };
  final body =
      json.encode({"name": name, "email": email, "password": password});

  try {
    final response = await http.post(url, headers: headers, body: body);
    final responseData = json.decode(response.body)['message'];

    if (response.statusCode == 201) {
      showAlert(context, responseData, true);
    } else {
      showAlert(context, responseData, false);
    }
  } catch (e) {
    print('Error: ${e.toString()}');
    showAlert(context, e.toString(), false);
  }
}
