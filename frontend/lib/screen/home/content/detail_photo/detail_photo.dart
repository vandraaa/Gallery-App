import 'package:flutter/material.dart';
import 'package:gallery_app/alert/alert.dart';
import 'package:gallery_app/alert/confirmPopupCenter.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screen/home/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:photo_view/photo_view.dart';

class PhotoDetailScreen extends StatefulWidget {
  final String photoUrl;
  final String description;
  final String createdAt;
  final int userId;
  final int id;
  final bool isFavorite;
  final String filename;
  final String size;

  const PhotoDetailScreen({
    Key? key,
    required this.photoUrl,
    required this.description,
    required this.createdAt,
    required this.userId,
    required this.id,
    required this.isFavorite,
    required this.filename,
    required this.size,
  }) : super(key: key);

  @override
  _PhotoDetailScreenState createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _fetchFavoriteStatus();
  }

  Future<void> _fetchFavoriteStatus() async {
    try {
      final response = await http.get(Uri.parse(
          '${baseUrl}/photos/detail?id=${widget.id}&userId=${widget.userId}'));
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
        '${baseUrl}/photos/favorite?id=${widget.id}&userId=${widget.userId}'));
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
        '${baseUrl}/photos/trash?id=${widget.id}&userId=${widget.userId}'));
    final responseData = json.decode(response.body)['message'];
    try {
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        showAlert(context, responseData, true);
      } else {
        showAlert(context, responseData, false);
      }
    } catch (e) {
      showAlert(context, e.toString(), false);
    }
  }

  String _formatDate(String createdAt) {
    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('EEEE, dd MMMM yyyy').format(parsedDate);
  }

  String _formatTime(String createdAt) {
    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('HH:mm:ss').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Photo Detail",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            color: Colors.white,
            onPressed: () {
              confirmPopupCenter(
                  context,
                  'Want to delete this photo?',
                  'Photos will be moved to the trash and will be deleted within 30 days.',
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
            SizedBox(height: 16),
            if (widget.description.isNotEmpty)
              Text(
                "Photo Description: ${widget.description}",
                style: const TextStyle(
                  fontSize: 15.5,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(
              _formatDate(widget.createdAt),
              style: const TextStyle(
                fontSize: 14.5,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 86, 85, 85),
              ),
            ),
            Text(
              _formatTime(widget.createdAt),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
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
            SizedBox(height: 16),
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
                side: BorderSide(color: Colors.red, width: 2.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoViewScreen extends StatelessWidget {
  final String photoUrl;

  const PhotoViewScreen({Key? key, required this.photoUrl}) : super(key: key);

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
