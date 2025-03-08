import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gallery_app/components/alert.dart';
import 'package:gallery_app/constant/utils.dart';
import 'package:gallery_app/screens/home/photo_management/detail_photo.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gallery_app/constant/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

Future<Map<String, List<dynamic>>> getPhotos(int userId) async {
  final Map<String, List<dynamic>> groupedPhotos = {};

  final response = await http.get(Uri.parse('$baseUrl/photos?id=$userId'));

  try {
    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      _groupPhotos(decodedJson['data'], groupedPhotos);
    } else {
      throw Exception('Failed to load photos');
    }
  } catch (error) {
    print(error);
  }

  return groupedPhotos;
}

Future<List<dynamic>> getPhotoToAlbum(int userId) async {
  final response = await http.get(Uri.parse('$baseUrl/photos?id=$userId'));

  try {
    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      return decodedJson['data'];
    } else {
      throw Exception('Failed to load photos');
    }
  } catch (error) {
    print(error);
  }

  return [];
}

void _groupPhotos(
    List<dynamic> photos, Map<String, List<dynamic>> groupedPhotos) {
  for (var photo in photos) {
    String formattedDate = formatDate(photo['createdAt']);
    if (groupedPhotos[formattedDate] == null) {
      groupedPhotos[formattedDate] = [];
    }
    groupedPhotos[formattedDate]!.add(photo);
  }
}

Future<void> sharePhoto(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_image.jpg');
      await file.writeAsBytes(response.bodyBytes);

      await Share.shareXFiles([XFile(file.path)], text: "Check out this photo!");
    } else {
      print("Gagal mengunduh gambar");
    }
  } catch (e) {
    print("Error saat berbagi gambar: $e");
  }
}

Future<void> uploadPhoto(
  BuildContext context,
  XFile file,
  String description,
  int userId,
) async {
  try {
    final url = Uri.parse('$baseUrl/photos/upload');

    var request = http.MultipartRequest('POST', url);

    request.fields['userId'] = userId.toString();
    request.fields['description'] = description;
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      File(file.path).readAsBytesSync(),
      filename: path.basename(file.path),
    ));

    request.headers.addAll({
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
    });

    var response = await request.send();

    if (response.statusCode == 201) {
      var responseBody = await http.Response.fromStream(response);
      var jsonResponse = json.decode(responseBody.body);
      showAlert(context, jsonResponse['message'], true);

      var photoUrl = jsonResponse['data']['url'];
      var description = jsonResponse['data']['description'];
      var createdAt = jsonResponse['data']['createdAt'];
      var userId = jsonResponse['data']['userId'];
      var id = jsonResponse['data']['photoId'];
      var isFavorite = jsonResponse['data']['isFavorite'];
      var filename = jsonResponse['data']['filename'];
      var size = jsonResponse['data']['size'];
      var albumId = jsonResponse['data']['albumId'];

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PhotoDetailScreen(
                photoUrl: photoUrl,
                description: description,
                createdAt: createdAt,
                userId: userId,
                id: id,
                isFavorite: isFavorite,
                filename: filename,
                size: size,
                albumId: albumId)),
      );
    } else {
      var responseBody = await http.Response.fromStream(response);
      var jsonResponse = json.decode(responseBody.body);
      print('Error: ${jsonResponse['message']}');
      showAlert(context, jsonResponse['message'], false);
    }
  } catch (e) {
    print('Exception: $e');
    showAlert(context, 'An error occurred. Please try again.', false);
  }
}

Future<bool> fetchFavoriteStatus(int photoId, int userId) async {
  final response = await http
      .get(Uri.parse('$baseUrl/photos/detail?id=$photoId&userId=$userId'));
  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    return responseData['data']['isFavorite'] ?? false;
  } else {
    throw Exception('Failed to load favorite status');
  }
}

Future<String> toggleFavorite(int photoId, int userId) async {
  final response = await http
      .patch(Uri.parse('$baseUrl/photos/favorite?id=$photoId&userId=$userId'));
  if (response.statusCode == 200) {
    return json.decode(response.body)['message'];
  } else {
    throw Exception(json.decode(response.body)['message']);
  }
}

Future<String> addToTrash(int photoId, int userId) async {
  final response = await http
      .patch(Uri.parse('$baseUrl/photos/trash?id=$photoId&userId=$userId'));
  if (response.statusCode == 200) {
    return json.decode(response.body)['message'];
  } else {
    throw Exception(json.decode(response.body)['message']);
  }
}

Future<String> removePhotoFromAlbum(int albumId, int photoId) async {
  final response = await http
      .delete(Uri.parse('$baseUrl/album/remove?id=$albumId&photoId=$photoId'));
  if (response.statusCode == 200) {
    return json.decode(response.body)['message'];
  } else {
    throw Exception(json.decode(response.body)['message']);
  }
}

Future<List<Map<String, dynamic>>> fetchAlbums(int userId) async {
  final response = await http.get(Uri.parse('$baseUrl/album/$userId'));
  if (response.statusCode == 200) {
    final responseData = json.decode(response.body)['data'] as List;
    return responseData.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load albums');
  }
}

Future<String> addToAlbum(int photoId, int albumId) async {
  final url = Uri.parse('$baseUrl/album/add');
  final body = json.encode({"photoId": photoId, "albumId": albumId});
  final headers = {
    "Access-Control-Allow-Origin": "*",
    'Content-Type': 'application/json',
    'Accept': '*/*',
  };
  final response = await http.patch(url, headers: headers, body: body);
  if (response.statusCode == 200) {
    return json.decode(response.body)['message'];
  } else {
    throw Exception(json.decode(response.body)['message']);
  }
}
