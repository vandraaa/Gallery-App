import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_app/screen/home/content/add_photo/new_photo.dart';
import 'package:gallery_app/screen/home/content/detail_photo/detail_photo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gallery_app/constant/constant.dart';
import 'package:intl/intl.dart';

class HomeContent extends StatefulWidget {
  final int userId;
  const HomeContent({super.key, required this.userId});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isFabVisible = true;
  Map<String, List<dynamic>> _groupedPhotos = {};
  bool _isLoading = true;
  bool _isHavePhoto = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchPhotos();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    }
  }

  Future<void> _fetchPhotos() async {
    _groupedPhotos.clear();

    final response = await http
        .get(Uri.parse(baseUrl + '/photos?id=' + widget.userId.toString()));

    try {
      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        _groupPhotos(decodedJson['data']);
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isHavePhoto = false;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  void _groupPhotos(List<dynamic> photos) {
    for (var photo in photos) {
      String formattedDate = _formatDate(photo['createdAt']);
      if (_groupedPhotos[formattedDate] == null) {
        _groupedPhotos[formattedDate] = [];
      }
      _groupedPhotos[formattedDate]!.add(photo);
    }
  }

  String _formatDate(String createdAt) {
    DateTime dateTime = DateTime.parse(createdAt);
    DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return 'Yesterday';
    } else if (dateTime.isBefore(now.subtract(Duration(days: 7))) &&
        dateTime.isAfter(now.subtract(Duration(days: 14)))) {
      return 'Last 7 days';
    } else {
      return DateFormat('dd MMMM yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : !_isHavePhoto
                ? Center(
                    child: Text(
                      "You don't have any photos",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView(
                    controller: _scrollController,
                    children: _buildGroupedPhotos(),
                  ),
      ),
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AddPhotoScreen(
                      userId: widget.userId,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return child;
                    },
                  ),
                );

                if (result == true) {
                  setState(() {
                    _isLoading = true;
                  });
                  await _fetchPhotos(); 
                }
              },
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24.0,
              ),
            )
          : null,
    );
  }

  List<Widget> _buildGroupedPhotos() {
    List<Widget> photoWidgets = [];
    for (var date in _groupedPhotos.keys) {
      photoWidgets.add(
        SizedBox(height: 16),
      );

      photoWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      var photos = _groupedPhotos[date]!;
      photoWidgets.add(
        GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              var photo = photos[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
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
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    ),
                  );

                  setState(() {
                    _isLoading = true;
                  });
                  await _fetchPhotos();
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(photo['url']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      );
    }
    return photoWidgets;
  }
}
