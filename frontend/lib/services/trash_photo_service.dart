import 'dart:convert';
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
