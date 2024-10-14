import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_app/screen/home/content/add_album/add_album_screen.dart';
import 'package:gallery_app/screen/home/content/detail_album/detail_album_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gallery_app/constant/constant.dart';

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

    final url = Uri.parse(baseUrl + "/album/${widget.userId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        setState(() {
          _albums = decodedJson['data'];
        });
      }
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      print(album['albumId']);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailAlbumScreen(
                            albumId: album['albumId'].toString(),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      child: Stack(
                        children: [
                          ClipRRect(
                            child: Image.network(
                              photo['url'],
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
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
                  setState(() {
                    _isLoading = true;
                  });
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
