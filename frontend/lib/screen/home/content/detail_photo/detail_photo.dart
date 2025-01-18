import 'package:flutter/material.dart';
import 'package:gallery_app/components/alert.dart';
import 'package:gallery_app/components/confirm_popup_center.dart';
import 'package:gallery_app/components/detail_photo_view.dart';
import 'package:gallery_app/constant/utils.dart';
import 'package:gallery_app/screen/home/content/detail_album/detail_album_screen.dart';
import 'package:gallery_app/screen/home/home_screen.dart';
import 'package:gallery_app/service/photo_service.dart';
// import 'package:gallery_app/screen/home/service/download_photo.dart';

class PhotoDetailScreen extends StatefulWidget {
  final String photoUrl;
  final String? description;
  final String createdAt;
  final int userId;
  final int id;
  final bool isFavorite;
  final String filename;
  final String size;
  final int? albumId;

  const PhotoDetailScreen({
    super.key,
    required this.photoUrl,
    required this.description,
    required this.createdAt,
    required this.userId,
    required this.id,
    required this.isFavorite,
    required this.filename,
    required this.size,
    required this.albumId,
  });

  @override
  _PhotoDetailScreenState createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late bool _isFavorite;
  bool _loadingFecthingAlbum = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _fetchFavoriteStatus();
  }

  Future<void> _fetchFavoriteStatus() async {
    try {
      final bool isFavorite =
          await fetchFavoriteStatus(widget.id, widget.userId);
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      showAlert(
          context, 'Failed to load favorite status: ${e.toString()}', false);
    }
  }

  Future<void> _handleToggleFavorite() async {
    try {
      final message = await toggleFavorite(widget.id, widget.userId);
      setState(() {
        _isFavorite = !_isFavorite;
      });
      showAlert(context, message, true);
    } catch (e) {
      showAlert(context, e.toString(), false);
    }
  }

  Future<void> _handleAddToTrash() async {
    try {
      final message = await addToTrash(widget.id, widget.userId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(initialIndex: 0),
        ),
      );
      showAlert(context, message, true);
    } catch (e) {
      showAlert(context, e.toString(), false);
    }
  }

  Future<void> _handleRemovePhotoFromAlbum() async {
    try {
      final message = await removePhotoFromAlbum(widget.albumId!, widget.id);
      showAlert(context, message, true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailAlbumScreen(
            albumId: widget.albumId.toString(),
            userId: widget.userId,
          ),
        ),
      );
    } catch (e) {
      showAlert(context, e.toString(), false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAlbums() async {
    setState(() {
      _loadingFecthingAlbum = true;
    });
    try {
      final response = await fetchAlbums(widget.userId);
      return response;
    } catch (e) {
      showAlert(context, e.toString(), false);
      return [];
    } finally {
      setState(() {
        _loadingFecthingAlbum = false;
      });
    }
  }

  Future<void> _addToAlbum(int albumId) async {
    try {
      final message = await addToAlbum(widget.id, albumId);
      showAlert(context, message, true);
    } catch (e) {
      showAlert(context, e.toString(), false);
    }
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
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _handleToggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.white,
            onPressed: () {
              confirmPopupCenter(
                  context,
                  'Want to delete this photo?',
                  'Photos will be moved to the trash and will be deleted within 7 days.',
                  'Delete Photo', () {
                _handleAddToTrash();
              });
            },
          ),
        ],
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
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.description != null && widget.description!.isNotEmpty)
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
              '${formatDate2(widget.createdAt)} at ${formatTime(widget.createdAt)}',
              style: const TextStyle(
                fontSize: 14.5,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 86, 85, 85),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns text to the left
                  children: [
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
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.blue),
                  onPressed: () {
                    confirmPopupCenter(
                      context,
                      'Download',
                      'Are you sure you want to download this photo?',
                      'Download Photo',
                      () => downloadPhoto(
                          context, widget.photoUrl, widget.filename),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _handleToggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.white : Colors.red,
                size: 18,
              ),
              label: Text(
                _isFavorite ? 'Added to favorite' : 'Add to favorite',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: _isFavorite ? Colors.white : Colors.red,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFavorite ? Colors.red : Colors.transparent,
                iconColor: _isFavorite ? Colors.white : Colors.red,
                side: const BorderSide(color: Colors.red, width: 2.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                if (widget.albumId != null) {
                  confirmPopupCenter(
                    context,
                    'Remove from Album',
                    'Are you sure you want to remove this photo from the album?',
                    'Remove Photo',
                    _handleRemovePhotoFromAlbum,
                  );
                } else {
                  List<Map<String, dynamic>> albums = await _fetchAlbums();
                  if (albums.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Select Album',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500)),
                          content: _loadingFecthingAlbum
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
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
                                      final totalPhotos =
                                          album['_count']['photos'];

                                      return ListTile(
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 2),
                                        leading: photo != null
                                            ? Image.network(
                                                photo['url'],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              )
                                            : Icon(Icons.photo_album, size: 50),
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
                                          _addToAlbum(album['albumId']);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                                ),
                        );
                      },
                    );
                  } else {
                    showAlert(context, 'No albums available', false);
                  }
                }
              },
              icon: Icon(
                widget.albumId != null
                    ? Icons.delete_forever_outlined
                    : Icons.add_photo_alternate_outlined,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                widget.albumId != null ? 'Remove from album' : 'Add to album',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.albumId != null ? Colors.red : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
