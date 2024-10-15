import 'package:flutter/material.dart';
import 'package:gallery_app/alert/alert.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screen/home/content/album_content.dart';
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
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  bool _isLoading = false;

  Future<void> _createAlbum() async {
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
      "photos": []
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        showAlert(context, responseData['message'], true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AlbumContent(userId: widget.userId)),
        );
      } else {
        final responseData = json.decode(response.body);
        showAlert(context, responseData['message'], false);
      }
    } catch (e) {
      print(e);
      showAlert(context, e.toString(), false);
    } finally {
      setState(() {
        _isLoading = false;
        _titleController.clear();
        _descController.clear();
      });
    }
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Album Name',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.5,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Album Name',
                    labelText: 'Album Name',
                    filled: true,
                    fillColor: Color.fromARGB(255, 232, 234, 234),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter album name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20.0),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Description (optional)',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.5,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Description',
                    labelText: 'Description',
                    filled: true,
                    fillColor: Color.fromARGB(255, 232, 234, 234),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      FocusScope.of(context).unfocus();
                    }
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
                          "Create Album",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
