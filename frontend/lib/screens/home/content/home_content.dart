import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_app/components/grouped_photos.dart';
import 'package:gallery_app/screens/home/photo_management/new_photo.dart';
import 'package:gallery_app/services/photo_service.dart';

class HomeContent extends StatefulWidget {
  final int userId;
  const HomeContent({super.key, required this.userId});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  Map<String, List<dynamic>> _groupedPhotos = {};
  bool _isLoading = true;
  bool _isHavePhoto = true;

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
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    }
  }

  Future<void> _fetchPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final groupedPhotos = await getPhotos(widget.userId);
      setState(() {
        _groupedPhotos.clear();
        _groupedPhotos = groupedPhotos;
        _isLoading = false;
        _isHavePhoto = groupedPhotos.isNotEmpty;
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
                    onRefresh: _fetchPhotos,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              "You don't have any photos.",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchPhotos,
                    child: ListView(
                      primary: false,
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        GroupedPhotosWidget(
                          groupedPhotos: _groupedPhotos,
                          fetchPhotos: _fetchPhotos,
                        ),
                      ],
                    ),
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
                        AddPhotoScreen(userId: widget.userId),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return child;
                    },
                  ),
                );
                if (result == true) {
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
}
