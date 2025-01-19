import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gallery_app/screen/home/content/detail_trash/detail_trash.dart';
import 'package:shimmer/shimmer.dart';

class TrashPhotosGrid extends StatelessWidget {
  final List<dynamic> photos;

  const TrashPhotosGrid({
    Key? key,
    required this.photos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        var photo = photos[index];

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    TrashDetailScreen(
                  photoUrl: photo['url'],
                  description: photo['description'],
                  createdAt: photo['createdAt'],
                  userId: photo['userId'],
                  id: photo['photoId'],
                  isFavorite: photo['isFavorite'],
                  filename: photo['filename'],
                  size: photo['size'],
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return child;
                },
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: photo['url'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.white,
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        );
      },
    );
  }
}
