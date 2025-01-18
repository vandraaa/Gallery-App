import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';

class DetailPhotoView extends StatelessWidget {
  final String photoUrl;

  const DetailPhotoView({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoView(
        imageProvider: NetworkImage(photoUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}