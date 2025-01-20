import 'package:flutter/material.dart';
import 'package:gallery_app/components/detail_photo_view.dart';
import 'package:gallery_app/constant/utils.dart';
import 'package:gallery_app/components/confirm_popup_center.dart';
import 'package:gallery_app/services/trash_photo_service.dart';

class TrashDetailScreen extends StatefulWidget {
  final String photoUrl;
  final String? description;
  final String createdAt;
  final int userId;
  final int id;
  final bool isFavorite;
  final String filename;
  final String size;

  const TrashDetailScreen({
    super.key,
    required this.photoUrl,
    required this.description,
    required this.createdAt,
    required this.userId,
    required this.id,
    required this.isFavorite,
    required this.filename,
    required this.size,
  });

  @override
  _TrashDetailScreenState createState() => _TrashDetailScreenState();
}

class _TrashDetailScreenState extends State<TrashDetailScreen> {
  bool _isLoading = false;
  bool _isLoadingDelete = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _restorePhoto() async {
    setState(() {
      _isLoading = true;
    });

    await restorePhoto(context, widget.id.toString(), widget.userId.toString());

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deletePhoto() async {
    setState(() {
      _isLoadingDelete = true;
    });

    await deletePhoto(context, widget.id.toString(), widget.userId.toString());

    setState(() {
      _isLoadingDelete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Photo Detail",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        DetailPhotoView(
                      photoUrl: widget.photoUrl,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return child;
                    },
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.photoUrl,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Loading image...",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: 'Poppins'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.description != null)
              Text(
                "Photo Description: ${widget.description}",
                style: const TextStyle(
                  fontSize: 15.5,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              const Text(
                "No description available",
                style: TextStyle(
                  fontSize: 14.5,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            Text(
              formatDate2(widget.createdAt),
              style: const TextStyle(
                fontSize: 14.5,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 86, 85, 85),
              ),
            ),
            Text(
              formatTime(widget.createdAt),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Filename: ${widget.filename}",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Text(
              "Size: ${widget.size}",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _restorePhoto,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Icon(
                      Icons.restore_from_trash,
                      color: Colors.white,
                      size: 18,
                    ),
              label: Text(
                _isLoading ? 'Loading...' : 'Restore',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                iconColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton.icon(
              onPressed: _isLoadingDelete
                  ? null
                  : () => confirmPopupCenter(
                      context,
                      'Are you sure',
                      'Photos will be permanently deleted and cnn\'t be restored',
                      'Delete',
                      _deletePhoto),
              icon: _isLoadingDelete
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 18,
                    ),
              label: Text(
                _isLoadingDelete ? 'Deleting...' : 'Delete Permanently',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                iconColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
