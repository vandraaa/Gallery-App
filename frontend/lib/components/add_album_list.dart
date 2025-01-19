import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Future<void> showAddAlbumDialog({
  required BuildContext context,
  required List<Map<String, dynamic>> albums,
  required Function(int albumId) onAlbumSelected,
  required bool isLoading,
}) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Select Album',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        content: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    final photo = album['photos'].isNotEmpty
                        ? album['photos'][0]
                        : null;
                    final totalPhotos = album['_count']['photos'];

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 2),
                      leading: photo != null
                          ? Image.network(
                              photo['url'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.white,
                                    ),
                                  );
                                }
                              },
                            )
                          : const Icon(Icons.photo_album, size: 50),
                      title: Text(
                        album['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Total Photos: $totalPhotos',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () {
                        onAlbumSelected(album['albumId']);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
      );
    },
  );
}
