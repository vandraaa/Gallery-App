import 'package:flutter/material.dart';
import 'package:gallery_app/alert/alert.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screen/home/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:photo_view/photo_view.dart';

class TrashDetailScreen extends StatefulWidget {
  final String photoUrl;
  final String description;
  final String createdAt;
  final int userId;
  final int id;
  final bool isFavorite;
  final String filename;
  final String size;

  const TrashDetailScreen({
    super.key,
    required this.photoUrl,
    required this.description,
    required this.createdAt,
    required this.userId,
    required this.id,
    required this.isFavorite,
    required this.filename,
    required this.size,
  });

  @override
  _TrashDetailScreenState createState() => _TrashDetailScreenState();
}

class _TrashDetailScreenState extends State<TrashDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _restorePhoto() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.patch(Uri.parse(
        '$baseUrl/photos/trash?id=${widget.id}&userId=${widget.userId}'));
    final responseData = json.decode(response.body)['message'];
    try {
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen()),
        );
        showAlert(context, responseData, true);
      } else {
        showAlert(context, responseData, false);
      }
    } catch (e) {
      showAlert(context, e.toString(), false);
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
    return DateFormat('HH:mm:ss').format(parsedDate);
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : _restorePhoto,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Icon(
                      Icons.restore_from_trash,
                      color: Colors.white,
                      size: 18,
                    ),
              label: Text(
                _isLoading ? 'Loading...' : 'Restore',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                iconColor: Colors.grey,
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
