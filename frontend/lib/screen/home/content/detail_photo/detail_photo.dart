import 'package:flutter/material.dart';
import 'package:gallery_app/alert/alert.dart';
import 'package:gallery_app/alert/confirmPopupCenter.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screen/home/content/detail_album/detail_album_screen.dart';
import 'package:gallery_app/screen/home/home_screen.dart';
import 'package:gallery_app/screen/home/service/download_photo.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:photo_view/photo_view.dart';

class PhotoDetailScreen extends StatefulWidget {
  final String photoUrl;
  final String? description;
  final String createdAt;
  final int userId;
  final int id;
  final bool isFavorite;
  final String filename;
  final String size;
  final int? albumId;

  const PhotoDetailScreen({
    super.key,
    required this.photoUrl,
    required this.description,
    required this.createdAt,
    required this.userId,
    required this.id,
    required this.isFavorite,
    required this.filename,
    required this.size,
    required this.albumId,
  });

  @override
  _PhotoDetailScreenState createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late bool _isFavorite;
  bool _loadingFecthingAlbum = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _fetchFavoriteStatus();
  }

  Future<void> _fetchFavoriteStatus() async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/photos/detail?id=${widget.id}&userId=${widget.userId}'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _isFavorite = responseData['data']['isFavorite'];
        });
      } else {
        showAlert(context, 'Failed to load favorite status', false);
      }
    } catch (e) {
      showAlert(context, e.toString(), false);
    }
  }

  Future<void> _toggleFavorite() async {
    final response = await http.patch(Uri.parse(
        '$baseUrl/photos/favorite?id=${widget.id}&userId=${widget.userId}'));
    final responseData = json.decode(response.body)['message'];
    print(responseData);

    try {
      if (response.statusCode == 200) {
        setState(() {
          _isFavorite = !_isFavorite;
        });

        showAlert(context, responseData, true);
      } else {
        showAlert(context, responseData, false);
      }
    } catch (e) {
      showAlert(context, e.toString(), false);
    } finally {
      _fetchFavoriteStatus();
    }
  }

  Future<void> _addToTrash() async {
    final response = await http.patch(Uri.parse(
        '$baseUrl/photos/trash?id=${widget.id}&userId=${widget.userId}'));
    final responseData = json.decode(response.body)['message'];
    try {
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen(initialIndex: 0)),
        );
        showAlert(context, responseData, true);
      } else {
        showAlert(context, responseData, false);
      }
    } catch (e) {
      showAlert(context, e.toString(), false);
    }
  }

  Future<void> _removePhotoFromAlbum() async {
    final response = await http.delete(Uri.parse(
      '${baseUrl}/album/remove?id=${widget.albumId}&photoId=${widget.id}',
    ));
    final responseData = json.decode(response.body)['message'];
    try {
      if (response.statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailAlbumScreen(albumId: widget.albumId.toString()),
            ));
        showAlert(context, responseData, true);
      } else {
        showAlert(context, responseData, false);
      }
    } catch (e) {
      print(e);
      showAlert(context, e.toString(), false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAlbums() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/album/${widget.userId}'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body)['data'] as List;
        return responseData.cast<Map<String, dynamic>>();
      } else {
        showAlert(context, 'Failed to load albums', false);
        return [];
      }
    } catch (e) {
      showAlert(context, e.toString(), false);
      return [];
    } finally {
      setState(() {
        _loadingFecthingAlbum = false;
      });
    }
  }

  Future<void> _addToAlbum(int albumId) async {
    final url = Uri.parse('${baseUrl}/album/add');
    final body = json.encode({
      "photoId": widget.id,
      "albumId": albumId,
    });
    final headers = {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    try {
      final response = await http.patch(url, headers: headers, body: body);
      final responseData = json.decode(response.body)['message'];
      if (response.statusCode == 200) {
        showAlert(context, responseData, true);
      } else {
        showAlert(context, responseData, false);
      }
    } catch (e) {
      print(e);
      showAlert(context, 'Failed to add photo to album', false);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Photo Detail",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.white,
            onPressed: () {
              confirmPopupCenter(
                  context,
                  'Want to delete this photo?',
                  'Photos will be moved to the trash and will be deleted within 7 days.',
                  'Delete Photo',
                  _addToTrash);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PhotoViewScreen(
                      photoUrl: widget.photoUrl,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return child;
                    },
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.photoUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.description != null && widget.description!.isNotEmpty)
              Text(
                "Photo Description: ${widget.description}",
                style: const TextStyle(
                  fontSize: 15.5,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              const Text(
                "No description available",
                style: TextStyle(
                  fontSize: 14.5,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            Text(
              '${_formatDate(widget.createdAt)} at ${_formatTime(widget.createdAt)}',
              style: const TextStyle(
                fontSize: 14.5,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 86, 85, 85),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns text to the left
                  children: [
                    Text(
                      "Filename: ${widget.filename}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "Size: ${widget.size}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.blue),
                  onPressed: () {
                    confirmPopupCenter(
                      context,
                      'Download',
                      'Are you sure you want to download this photo?',
                      'Download Photo',
                      () => downloadPhoto(
                          context, widget.photoUrl, widget.filename),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.white : Colors.red,
                size: 18,
              ),
              label: Text(
                _isFavorite ? 'Added to favorite' : 'Add to favorite',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: _isFavorite ? Colors.white : Colors.red,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFavorite ? Colors.red : Colors.transparent,
                iconColor: _isFavorite ? Colors.white : Colors.red,
                side: const BorderSide(color: Colors.red, width: 2.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                if (widget.albumId != null) {
                  confirmPopupCenter(
                    context,
                    'Remove from Album',
                    'Are you sure you want to remove this photo from the album?',
                    'Remove Photo',
                    _removePhotoFromAlbum,
                  );
                } else {
                  List<Map<String, dynamic>> albums = await _fetchAlbums();
                  if (albums.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Select Album',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500)),
                          content: _loadingFecthingAlbum
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: albums.length,
                                    itemBuilder: (context, index) {
                                      final album = albums[index];
                                      final photo = album['photos'].isNotEmpty
                                          ? album['photos'][0]
                                          : null;
                                      final totalPhotos =
                                          album['_count']['photos'];

                                      return ListTile(
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 2),
                                        leading: photo != null
                                            ? Image.network(
                                                photo['url'],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              )
                                            : Icon(Icons.photo_album, size: 50),
                                        title: Text(
                                          album['title'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Total Photos: $totalPhotos',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        onTap: () {
                                          _addToAlbum(album['albumId']);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                                ),
                        );
                      },
                    );
                  } else {
                    showAlert(context, 'No albums available', false);
                  }
                }
              },
              icon: Icon(
                widget.albumId != null
                    ? Icons.delete_forever_outlined
                    : Icons.add_photo_alternate_outlined,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                widget.albumId != null ? 'Remove from album' : 'Add to album',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.albumId != null ? Colors.red : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PhotoViewScreen extends StatelessWidget {
  final String photoUrl;

  const PhotoViewScreen({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoView(
        imageProvider: NetworkImage(photoUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}
