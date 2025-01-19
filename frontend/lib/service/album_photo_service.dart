import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gallery_app/constant/constant.dart';

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