import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_app/components/grouped_photos.dart';
import 'package:gallery_app/screen/home/content/add_photo/new_photo.dart';
import 'package:gallery_app/service/photo_service.dart';

class HomeContent extends StatefulWidget {
  final int userId;
  const HomeContent({super.key, required this.userId});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isFabVisible = true;
  final Map<String, List<dynamic>> _groupedPhotos = {};
  bool _isLoading = true;
  bool _isHavePhoto = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    getPhoto();
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

  Future<void> getPhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final groupedPhotos = await getPhotos(widget.userId);
      setState(() {
        _groupedPhotos.clear();
        _groupedPhotos.addAll(groupedPhotos);
        _isLoading = false;
      });
    } catch (e) {
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
            : RefreshIndicator(
                onRefresh: getPhoto,
                child: _isHavePhoto
                    ? ListView(
                        controller: _scrollController,
                        children: [
                          GroupedPhotosWidget(
                            groupedPhotos: _groupedPhotos,
                            fetchPhotos: getPhoto,
                          ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 200.0),
                              child: Text(
                                "You don't have any photos",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
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
                  await getPhoto();
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
