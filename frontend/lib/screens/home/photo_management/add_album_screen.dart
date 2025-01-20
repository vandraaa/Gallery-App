import 'package:flutter/material.dart';
import 'package:gallery_app/components/alert.dart';
import 'package:gallery_app/components/custom_input_field.dart';
import 'package:gallery_app/components/custom_elevated_button.dart';
import 'package:gallery_app/components/photos_dialog.dart';
import 'package:gallery_app/services/album_photo_service.dart';
import 'package:gallery_app/services/photo_service.dart';

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

    try {
      final response = await createAlbum(
        context: context,
        userId: widget.userId,
        title: _titleController.text,
        description: _descController.text,
        selectedPhotoIds: _selectedPhotoIds,
      );

      showAlert(context, response['message'], true);
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
      final response = await getPhotoToAlbum(widget.userId);
      print(response);
      showPhotosDialog(
        context: context,
        photos: response,
        selectedPhotoIds: _selectedPhotoIds,
        toggleSelectPhoto: _toggleSelectPhoto,
        onSave: () {
          setState(() {});
        },
      );

      setState(() {
        _isLoadingPhotos = false;
      });
    } catch (e) {
      showAlert(context, e.toString(), false);
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
                  CustomInputField(
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
                  CustomInputField(
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
                  CustomElevatedButton(
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
                  CustomElevatedButton(
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
