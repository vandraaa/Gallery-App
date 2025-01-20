import 'package:flutter/material.dart';
import 'package:gallery_app/components/alert.dart';
import 'package:gallery_app/components/confirm_popup_center.dart';
import 'package:gallery_app/components/photos_dialog.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/constant/utils.dart';
import 'package:gallery_app/screens/home/photo_management/detail_photo.dart';
import 'package:gallery_app/services/album_photo_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:shimmer/shimmer.dart';

class DetailAlbumScreen extends StatefulWidget {
  final String albumId;
  final int userId;

  const DetailAlbumScreen(
      {Key? key, required this.albumId, required this.userId})
      : super(key: key);

  @override
  State<DetailAlbumScreen> createState() => _DetailAlbumScreenState();
}

class _DetailAlbumScreenState extends State<DetailAlbumScreen> {
  bool _isLoading = false;
  bool _isEditingTitle = false;
  bool _isEditingDescription = false;
  Map<String, dynamic> _album = {};

  bool _isFabVisible = true;
  bool _isLoadingDelete = false;

  List<int> _selectedPhotoIds = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _focusNodeDescription = FocusNode();

  final ScrollController _scrollController = ScrollController();

  Future<void> _fetchAlbum() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await getAlbumById(widget.albumId);

      if (response.isNotEmpty) {
        setState(() {
          _album = response;
          _titleController.text = _album['title'] ?? '';
          _descriptionController.text = _album['description'] ?? '';
          _isLoading = false;
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

  Future<void> _updateAlbum() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await updateAlbum(widget.albumId, context, _titleController.text,
          _descriptionController.text);
    } catch (e) {
      print(e);
    } finally {
      _fetchAlbum();

      setState(() {
        _isLoading = false;
        _isEditingTitle = false;
        _isEditingDescription = false;
      });
    }
  }

  Future<void> _fetchPhotosAndShowDialog() async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/album/photos/${widget.albumId}?userId=${widget.userId}'));

      if (response.statusCode == 200) {
        final List<dynamic> addPhotoAlbum = json.decode(response.body)['data'];

        showPhotosDialog(
          context: context,
          photos: addPhotoAlbum,
          selectedPhotoIds: _selectedPhotoIds,
          toggleSelectPhoto: _toggleSelectPhoto,
          onSave: () {
            _addPhotoToAlbum();
          },
        );
      } else {
        showAlert(context, "Failed to fetch photos", false);
      }
    } catch (e) {
      showAlert(context, "Error fetching photos: $e", false);
    }
  }

  void _toggleSelectPhoto(int photoId) {
    setState(() {
      if (_selectedPhotoIds.contains(photoId)) {
        _selectedPhotoIds.remove(photoId);
      } else {
        _selectedPhotoIds.add(photoId);
      }
    });
  }

  Future<void> _addPhotoToAlbum() async {
    if (_selectedPhotoIds.isEmpty) {
      showAlert(context, 'Please select at least one photo', false);
      return;
    }

    try {
      await addPhotoToAlbum(widget.albumId, context, _selectedPhotoIds);
      _fetchAlbum();
      setState(() {
        _selectedPhotoIds = [];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteAlbum() async {
    setState(() {
      _isLoadingDelete = true;
    });

    await deleteAlbum(widget.albumId, context);
    setState(() {
      _isLoadingDelete = false;
    });
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

  @override
  void initState() {
    super.initState();
    _fetchAlbum();
    _scrollController.addListener(_scrollListener);

    _focusNodeDescription.addListener(() {
      if (!_focusNodeDescription.hasFocus) {
        setState(() {
          _isEditingDescription = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Album Detail",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _isEditingTitle = false;
              _isEditingDescription = false;
            });
          },
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _album['photos'] != null && _album['photos'].isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        height: 300,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            _album['photos'][0]['url'],
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (context, child, progress) {
                                              if (progress == null) {
                                                return child;
                                              } else {
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    color: Colors.grey[300],
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 200,
                                        width: double.infinity,
                                        alignment: Alignment.bottomCenter,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _album['title'] ??
                                                        'No title available',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                  Text(
                                                    '${_album['_count']?['photos'] ?? 0} photos',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: _isLoadingDelete
                                                    ? null
                                                    : () {
                                                        confirmPopupCenter(
                                                          context,
                                                          'Want to delete this album?',
                                                          'The album will be permanently deleted and can\'t be recovered.',
                                                          'Delete',
                                                          _deleteAlbum,
                                                        );
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  shape: const CircleBorder(),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                ),
                                                child: _isLoadingDelete
                                                    ? const SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                          strokeWidth: 2.0,
                                                        ),
                                                      )
                                                    : const Icon(Icons.delete,
                                                        color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              )
                            : const Text('No photos available.'),
                        const SizedBox(height: 8),
                        _isEditingTitle
                            ? TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Edit Title',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: () {
                                      _updateAlbum();
                                      setState(() {
                                        _isEditingTitle = false;
                                      });
                                    },
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditingTitle = true;
                                  });
                                },
                                child: Text(
                                  _album['title'] ?? 'No title available',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                        _isEditingTitle
                            ? const SizedBox(height: 8)
                            : const SizedBox(),
                        _isEditingDescription
                            ? TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Edit Description',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: () {
                                      _updateAlbum();
                                      setState(() {
                                        _isEditingDescription = false;
                                      });
                                    },
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditingDescription = true;
                                  });
                                },
                                child: Text(
                                  _album['description'] ??
                                      'No description available',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 8),
                        Text(
                          'Album created at: ${formatDate2(_album['createdAt'])} at ${formatTime(_album['createdAt'])}',
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey,
                              fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 16),
                        _album['photos'] != null && _album['photos'].isNotEmpty
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: _album['photos'].length,
                                itemBuilder: (context, index) {
                                  final photo = _album['photos'][index];
                                  return GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              PhotoDetailScreen(
                                            photoUrl: photo['url'],
                                            description: photo['description'],
                                            createdAt: photo['createdAt'],
                                            userId: photo['userId'],
                                            id: photo['photoId'],
                                            isFavorite: photo['isFavorite'],
                                            filename: photo['filename'],
                                            size: photo['size'],
                                            albumId: _album['albumId'],
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return child;
                                          },
                                        ),
                                      );
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      await _fetchAlbum();
                                    },
                                    child: Card(
                                      elevation: 2,
                                      child: Image.network(
                                        photo['url'],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) {
                                            return child;
                                          } else {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                color: Colors.grey[300],
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Text('No photos available.'),
                      ],
                    ),
                  ),
                )),
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2196F3),
              onPressed: () async {
                _fetchPhotosAndShowDialog();
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
