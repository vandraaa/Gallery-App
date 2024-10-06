import 'package:flutter/material.dart';
import 'package:gallery_app/alert/alert.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;

class AddPhotoScreen extends StatefulWidget {
  final int userId;

  const AddPhotoScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddPhotoScreenState createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void _onPhotoAdded() {
    Navigator.pop(context, true);
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = pickedFile;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _selectedImage = pickedFile;
    });
  }

  Future<void> _uploadPhoto(XFile file) async {
    if (_selectedImage == null) {
      return showAlert(context, 'Please select an image', false);
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(baseUrl + '/photos/upload');

      var request = http.MultipartRequest('POST', url);

      request.fields['userId'] = widget.userId.toString();
      request.fields['description'] = _descriptionController.text;
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        File(file.path).readAsBytesSync(),
        filename: path.basename(file.path),
      ));

      request.headers.addAll({
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
      });

      var response = await request.send();

      if (response.statusCode == 201) {
        var responseBody = await http.Response.fromStream(response);
        var jsonResponse = json.decode(responseBody.body);
        showAlert(context, jsonResponse['message'], true);

        setState(() {
          _selectedImage = null;
          _descriptionController.clear();
        });
      } else {
        var responseBody = await http.Response.fromStream(response);
        var jsonResponse = json.decode(responseBody.body);
        print('Error: ${jsonResponse['message']}');
        showAlert(context, jsonResponse['message'], false);
      }
    } catch (e) {
      print('Exception: $e'); // Tambahkan ini
      showAlert(context, 'An error occurred. Please try again.', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            "Add Photo",
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _selectedImage != null
                    ? Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 25),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Description (Optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _uploadPhoto(_selectedImage!);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.lightBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: const StadiumBorder(),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : const Text(
                                    "Submit Photo",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                    ),
                                  ),
                          ),
                        ],
                      )
                    : const Text(
                        'No Image Selected',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(
                        'Camera',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text(
                        'Gallery',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
