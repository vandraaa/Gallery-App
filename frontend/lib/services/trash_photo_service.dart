import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gallery_app/components/alert.dart';
import 'package:gallery_app/screens/home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:gallery_app/constant/constant.dart';

Future<List<dynamic>> getTrashPhotos(int userId) async {
  final url = Uri.parse('$baseUrl/photos/trash?id=$userId');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      return decodedJson['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load trash photos');
    }
  } catch (e) {
    throw Exception('Failed to load trash photos: $e');
  }
}

Future<void> restorePhoto(context, String id, String userId) async {
  final response = await http
      .patch(Uri.parse('$baseUrl/photos/trash?id=$id&userId=$userId'));
  final responseData = json.decode(response.body)['message'];
  try {
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const HomeScreen(initialIndex: 3)),
      );
      showAlert(context, responseData, true);
    } else {
      showAlert(context, responseData, false);
    }
  } catch (e) {
    showAlert(context, 'Failed to restore photo', false);
  }
}

Future<void> deletePhoto(context, String id, String userId) async {
  final url = '$baseUrl/photos/delete?id=$id&userId=$userId';
  try {
    final response = await http.delete(Uri.parse(url));
    final responseData = json.decode(response.body)['message'];
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const HomeScreen(initialIndex: 3)),
      );
      showAlert(context, responseData, true);
    } else {
      showAlert(context, responseData, false);
    }
  } catch (e) {
    showAlert(context, 'Failed to delete photo', false);
  }
}
