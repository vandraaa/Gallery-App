import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_app/components/favorite_photos_grid.dart';
import 'package:gallery_app/services/favorite_photo_service.dart';

class FavoriteContent extends StatefulWidget {
  final int userId;
  const FavoriteContent({super.key, required this.userId});

  @override
  State<FavoriteContent> createState() => _FavoriteContentState();
}

class _FavoriteContentState extends State<FavoriteContent> {
  List<dynamic> _favoritePhotos = [];
  bool _isLoading = true;
  bool _isHavePhoto = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoritePhotos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchFavoritePhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photos = await getFavoritePhotos(widget.userId);
      setState(() {
        _favoritePhotos = photos;
        _isLoading = false;
        _isHavePhoto = photos.isNotEmpty;
      });
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
        _isHavePhoto = false;
      });
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
                ? RefreshIndicator(
                    onRefresh: _fetchFavoritePhotos,
                    child: ListView(
                      children: const [
                       Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            'You don\'t have favorite photo.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchFavoritePhotos,
                    child: ListView(
                      children: [
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
                        FavoritePhotosGrid(
                          photos: _favoritePhotos,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
