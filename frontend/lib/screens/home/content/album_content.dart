import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_app/screens/home/photo_management/add_album_screen.dart';
import 'package:gallery_app/screens/home/photo_management/detail_album_screen.dart';
import 'package:gallery_app/services/album_photo_service.dart';
import 'package:shimmer/shimmer.dart';

class AlbumContent extends StatefulWidget {
  final userId;

  const AlbumContent({super.key, required this.userId});

  @override
  State<AlbumContent> createState() => _AlbumContentState();
}

class _AlbumContentState extends State<AlbumContent> {
  bool _isFabVisible = true;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _albums = [];

  @override
  void initState() {
    super.initState();
    _getAlbum();
    _scrollController.addListener(_scrollListener);
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

  Future<void> _getAlbum() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await getAlbums(widget.userId);
      setState(() {
        _albums = response;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _albums.isEmpty
              ? RefreshIndicator(
                  onRefresh: _getAlbum,
                  child: ListView(
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            'No albums available.',
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
                  onRefresh: _getAlbum,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _albums.length,
                      itemBuilder: (context, index) {
                        final album = _albums[index];
                        final photo = album['photos'].isNotEmpty
                            ? album['photos'][0]
                            : {'url': 'https://via.placeholder.com/150'};

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        DetailAlbumScreen(
                                  albumId: album['albumId'].toString(),
                                  userId: widget.userId,
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return child;
                                },
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: photo['url'],
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      color: Colors.white,
                                      height: double.infinity,
                                      width: double.infinity,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.40),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          album['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.0,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          album['_count']['photos'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.0,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2196F3),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAlbumScreen(
                      userId: widget.userId,
                    ),
                  ),
                );

                if (result == true) {
                  await _getAlbum();
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
