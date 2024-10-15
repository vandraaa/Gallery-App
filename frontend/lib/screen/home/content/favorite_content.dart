import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_app/screen/home/content/detail_photo/detail_photo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gallery_app/constant/constant.dart';

class FavoriteContent extends StatefulWidget {
  final int userId;
  const FavoriteContent({super.key, required this.userId});

  @override
  State<FavoriteContent> createState() => _FavoriteContentState();
}

class _FavoriteContentState extends State<FavoriteContent> {
  bool _isFabVisible = true;
  List<dynamic> _favoritePhotos = [];
  bool _isLoading = true;
  bool _isHavePhoto = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchFavoritePhotos();
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

  Future<void> _fetchFavoritePhotos() async {
    final response = await http.get(
        Uri.parse('$baseUrl/photos/favorite?id=${widget.userId}'));

    try {
      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        setState(() {
          _favoritePhotos = decodedJson['data'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isHavePhoto
              ? const Center(
                  child: Text(
                    "You don't have favorite photos",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView(
                  controller: _scrollController,
                  children: _buildFavoritePhotos(),
                ),
    ));
  }

  List<Widget> _buildFavoritePhotos() {
    List<Widget> photoWidgets = [];

    photoWidgets.add(
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "Your Favorite Photo",
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

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
          itemCount: _favoritePhotos.length,
          itemBuilder: (context, index) {
            var photo = _favoritePhotos[index];
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
                      albumId: null,
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
                await _fetchFavoritePhotos();
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

    return photoWidgets;
  }
}
