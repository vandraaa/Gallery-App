import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

void showPhotosDialog({
  required BuildContext context,
  required List<dynamic> photos,
  required List<int> selectedPhotoIds,
  required Function(int photoId) toggleSelectPhoto,
  required VoidCallback onSave,
}) {
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
                          physics: const BouncingScrollPhysics(),
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
                                  toggleSelectPhoto(photoId);
                                });
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: selectedPhotoIds.contains(photoId)
                                            ? Colors.blueAccent
                                            : Colors.transparent,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        photo['url'],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) {
                                            return child; // Gambar sudah selesai dimuat
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
                                  ),
                                  if (selectedPhotoIds.contains(photoId))
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
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onSave();
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
