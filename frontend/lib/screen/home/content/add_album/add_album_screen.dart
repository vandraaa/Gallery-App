import 'package:flutter/material.dart';
import 'package:gallery_app/alert/alert.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screen/home/content/detail_album/detail_album_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAlbumScreen extends StatefulWidget {
  final int userId;
  const AddAlbumScreen({super.key, required this.userId});

  @override
  State<AddAlbumScreen> createState() => _AddAlbumContent();
}

class _AddAlbumContent extends State<AddAlbumScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingPhotos = false;
  List<int> _selectedPhotoIds = [];

  Future<void> _createAlbum() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${baseUrl}/album/create');
    final headers = {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    final body = json.encode({
      "userId": widget.userId,
      "title": _titleController.text,
      "description": _descController.text,
      "photos": _selectedPhotoIds
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        showAlert(context, responseData['message'], true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DetailAlbumScreen(albumId: responseData['data']['albumId'].toString())),
        );
      } else {
        final responseData = json.decode(response.body);
        showAlert(context, responseData['message'], false);
      }
    } catch (e) {
      showAlert(context, e.toString(), false);
    } finally {
      setState(() {
        _isLoading = false;
        _titleController.clear();
        _descController.clear();
        _selectedPhotoIds.clear();
      });
    }
  }

  Future<void> _fetchPhotosAndShowDialog() async {
    setState(() {
      _isLoadingPhotos = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/photos?id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> photos = json.decode(response.body)['data'];

        setState(() {
          _isLoadingPhotos = false;
        });

        _showPhotosDialog(photos);
      } else {
        showAlert(context, "Failed to fetch photos", false);
        setState(() {
          _isLoadingPhotos = false;
        });
      }
    } catch (e) {
      showAlert(context, "Error fetching photos: $e", false);
      setState(() {
        _isLoadingPhotos = false;
      });
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

  void _showPhotosDialog(List<dynamic> photos) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Photos',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  photos.isEmpty
                      ? const Text('No photos found.')
                      : SizedBox(
                          height: 300,
                          width: double.maxFinite,
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: photos.length,
                            itemBuilder: (context, index) {
                              final photo = photos[index];
                              final int photoId = photo['photoId'];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _toggleSelectPhoto(photoId);
                                  });
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: _selectedPhotoIds
                                                  .contains(photoId)
                                              ? Colors.blueAccent
                                              : Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          photo['url'],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    if (_selectedPhotoIds.contains(photoId))
                                      Positioned(
                                        bottom: 8.0,
                                        right: 8.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedPhotoIds = [];
                    });
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14.5,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color.fromARGB(255, 232, 234, 234),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildElevatedButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
    Color? backgroundColor,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor ?? Colors.blueAccent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: const StadiumBorder(),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.0,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Create New Album",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blueAccent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField(
                    controller: _titleController,
                    labelText: 'Album Name',
                    hintText: 'Enter Album Name',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter album name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  _buildInputField(
                    controller: _descController,
                    labelText: 'Description (optional)',
                    hintText: 'Enter Description',
                  ),
                  const SizedBox(height: 20.0),
                  if (_selectedPhotoIds.isNotEmpty)
                    Text(
                      'Selected Photos: ${_selectedPhotoIds.length}',
                      textAlign: TextAlign.left, 
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  const SizedBox(height: 10.0),
                  _buildElevatedButton(
                    text: 'Select Photos',
                    isLoading: _isLoadingPhotos,
                    backgroundColor: Colors.cyan,
                    icon: Icons.photo_library,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        FocusScope.of(context).unfocus();
                        _fetchPhotosAndShowDialog();
                      }
                    },
                  ),
                  const SizedBox(height: 20.0),
                  _buildElevatedButton(
                    text: 'Create Album',
                    isLoading: _isLoading,
                    backgroundColor: Colors.blueAccent,
                    icon: Icons.cloud_upload,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        FocusScope.of(context).unfocus();
                        _createAlbum();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
