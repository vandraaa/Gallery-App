import 'package:flutter/material.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screen/home/content/detail_photo/detail_photo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DetailAlbumScreen extends StatefulWidget {
  final String albumId;

  const DetailAlbumScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  State<DetailAlbumScreen> createState() => _DetailAlbumScreenState();
}

class _DetailAlbumScreenState extends State<DetailAlbumScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _album = {};

  Future<void> _fetchAlbum() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${baseUrl}/album/photo/${widget.albumId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _album = responseData['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String createdAt) {
    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('EEEE, dd MMMM yyyy').format(parsedDate);
  }

  String _formatTime(String createdAt) {
    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('HH:mm').format(parsedDate);
  }

  @override
  void initState() {
    super.initState();
    _fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Album Detail",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _album['title'] ?? 'No title available',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                    Text(
                      _album['description'] ?? 'No description available',
                      style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created at: ${_formatDate(_album['createdAt'])} at ${_formatTime(_album['createdAt'])}',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Poppins'),
                    ),
                    Text(
                      'Total Photos: ${_album['_count']?['photos'] ?? 0}',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 16),
                    _album['photos'] != null && _album['photos'].isNotEmpty
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _album['photos'].length,
                            itemBuilder: (context, index) {
                              final photo = _album['photos'][index];
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          PhotoDetailScreen(
                                        photoUrl: photo['url'],
                                        description: photo['description'],
                                        createdAt: photo['createdAt'],
                                        userId: photo['userId'],
                                        id: photo['photoId'],
                                        isFavorite: photo['isFavorite'],
                                        filename: photo['filename'],
                                        size: photo['size'],
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return child;
                                      },
                                    ),
                                  );

                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await _fetchAlbum();
                                },
                                child: Card(
                                  elevation: 2,
                                  child: Image.network(
                                    photo['url'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          )
                        : const Text('No photos available.'),
                  ],
                ),
              ),
            ),
    );
  }
}
