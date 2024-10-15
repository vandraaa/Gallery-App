import 'package:flutter/material.dart';
import 'package:gallery_app/alert/alert.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screen/home/content/detail_photo/detail_photo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';

class DetailAlbumScreen extends StatefulWidget {
  final String albumId;

  const DetailAlbumScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  State<DetailAlbumScreen> createState() => _DetailAlbumScreenState();
}

class _DetailAlbumScreenState extends State<DetailAlbumScreen> {
  bool _isLoading = false;
  bool _isEditingTitle = false;
  bool _isEditingDescription = false;
  Map<String, dynamic> _album = {};

  bool _isFabVisible = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _focusNodeDescription = FocusNode();

  final ScrollController _scrollController = ScrollController();

  Future<void> _fetchAlbum() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${baseUrl}/album/photo/${widget.albumId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _album = responseData['data'];
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

    final url = Uri.parse('${baseUrl}/album/update/${widget.albumId}');
    final body = json.encode({
      'title': _titleController.text,
      'description': _descriptionController.text,
    });

    try {
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        showAlert(context, responseData['message'], true);

        setState(() {
          _isEditingTitle = false;
          _isEditingDescription = false;
        });
      } else {
        final responseData = json.decode(response.body);

        showAlert(context, responseData['message'], false);
      }
    } catch (e) {
      print(e);
      showAlert(context, 'Failed to update album', false);
    } finally {
      _fetchAlbum();

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
    return DateFormat('HH:mm').format(parsedDate);
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
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons.image);
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
                                          child: Text(
                                            _album['title'] ??
                                                'No title available',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                            ),
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
                          'Album created at: ${_formatDate(_album['createdAt'])} at ${_formatTime(_album['createdAt'])}',
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey,
                              fontFamily: 'Poppins'),
                        ),
                        Text(
                          '${_album['_count']?['photos'] ?? 0} photos',
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
                                        MaterialPageRoute(
                                          builder: (context) =>
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
                                        fit: BoxFit.cover,
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
              onPressed: () {},
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
