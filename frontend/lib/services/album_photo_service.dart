import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gallery_app/screens/home/photo_management/detail_album_screen.dart';
import 'package:http/http.dart' as http;
import 'package:gallery_app/constant/constant.dart';

Future<Map<String, dynamic>> createAlbum({
  required BuildContext context,
  required int userId,
  required String title,
  required String description,
  required List<int> selectedPhotoIds,
}) async {
  final url = Uri.parse('$baseUrl/album/create');
  final headers = {
    "Access-Control-Allow-Origin": "*",
    'Content-Type': 'application/json',
    'Accept': '*/*',
  };
  final body = json.encode({
    "userId": userId,
    "title": title,
    "description": description,
    "photos": selectedPhotoIds,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DetailAlbumScreen(
                albumId: responseData['data']['albumId'].toString(),
                userId: userId)),
      );
      return responseData;
    } else {
      final errorResponse = json.decode(response.body);
      throw Exception(errorResponse['message']);
    }
  } catch (e) {
    throw Exception("Failed to create album: $e");
  }
}

Future<List<dynamic>> getAlbums(int userId) async {
  final url = Uri.parse('$baseUrl/album/$userId');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      return decodedJson['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load albums');
    }
  } catch (e) {
    throw Exception('Failed to load albums: $e');
  }
}
