import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_app/components/trash_photos_grid.dart';
import 'package:gallery_app/service/trash_photo_service.dart';

class TrashContent extends StatefulWidget {
  final int userId;
  const TrashContent({super.key, required this.userId});

  @override
  State<TrashContent> createState() => _TrashContentState();
}

class _TrashContentState extends State<TrashContent> {
  bool _isFabVisible = true;
  List<dynamic> _trashPhotos = [];
  bool _isLoading = true;
  bool _isHavePhoto = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchTrashPhotos();
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

  Future<void> _fetchTrashPhotos() async {
    try {
      final photos = await getTrashPhotos(widget.userId);
      setState(() {
        _trashPhotos = photos;
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
                    onRefresh: _fetchTrashPhotos,
                    child: ListView(
                      children: const [
                       Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            'There is no photo in trash',
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
                    onRefresh: _fetchTrashPhotos,
                    child: ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "Photo will be deleted after 7 days",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TrashPhotosGrid(
                          photos: _trashPhotos,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
