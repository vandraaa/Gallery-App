import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gallery_app/components/alert.dart';
import 'package:gallery_app/screens/home/home_screen.dart';
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

Future<Map<String, dynamic>> getAlbumById(String albumId) async {
  final url = Uri.parse('$baseUrl/album/photo/$albumId');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'];
    } else {
      throw Exception('Failed to load album');
    }
  } catch (e) {
    throw Exception('Failed to load album: $e');
  }
}

Future<void> updateAlbum(String albumId, BuildContext context, String title,
    String description) async {
  final url = Uri.parse('$baseUrl/album/update/$albumId');
  final body = json.encode({
    'title': title,
    'description': description,
  });

  try {
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      showAlert(context, responseData['message'], true);
    } else {
      final responseData = json.decode(response.body);

      showAlert(context, responseData['message'], false);
    }
  } catch (e) {
    print(e);
    showAlert(context, 'Failed to update album', false);
  }
}

Future<void> addPhotoToAlbum(
    String albumId, BuildContext context, List<int> _selectedPhotoIds) async {
  try {
    final body =
        json.encode({'albumId': albumId, 'photoIds': _selectedPhotoIds});
    final headers = {'Content-type': 'application/json'};

    final response = await http.post(Uri.parse('$baseUrl/album/add-multiple'),
        body: body, headers: headers);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final message = responseData['message'];
      showAlert(context, message, true);
    } else {
      final responseData = json.decode(response.body);
      final message = responseData['message'];
      showAlert(context, message, false);
    }
  } catch (e) {
    print(e);
    showAlert(context, 'Failed to add photos to album', false);
  }
}

Future<void> deleteAlbum(String albumId, BuildContext context) async {
  try {
    final response =
        await http.delete(Uri.parse('$baseUrl/album/delete?id=$albumId'));
    final responseData = json.decode(response.body);
    final message = responseData['message'];

    if (response.statusCode == 200) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(initialIndex: 1),
          ));
      showAlert(context, message, true);
    } else {
      showAlert(context, message, false);
    }
  } catch (e) {
    print(e);
    showAlert(context, 'Failed to delete album', false);
  }
}
