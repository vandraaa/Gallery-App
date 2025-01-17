import 'package:flutter/material.dart';
import 'package:gallery_app/screen/home/content/detail_photo/detail_photo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class GroupedPhotosWidget extends StatelessWidget {
  final Map<String, List<dynamic>> groupedPhotos;
  final Function fetchPhotos;

  const GroupedPhotosWidget({
    Key? key,
    required this.groupedPhotos,
    required this.fetchPhotos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> photoWidgets = [];
    for (var date in groupedPhotos.keys) {
      photoWidgets.add(const SizedBox(height: 16));

      photoWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ));

      var photos = groupedPhotos[date]!;
      photoWidgets.add(GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
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
                  pageBuilder: (context, animation, secondaryAnimation) => PhotoDetailScreen(
                    photoUrl: photo['url'],
                    description: photo['description'],
                    createdAt: photo['createdAt'],
                    userId: photo['userId'],
                    id: photo['photoId'],
                    isFavorite: photo['isFavorite'],
                    filename: photo['filename'],
                    size: photo['size'],
                    albumId: null,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return child;
                  },
                ),
              );

              fetchPhotos();
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
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ));
    }
    return Column(
      children: photoWidgets,
    );
  }
}
  