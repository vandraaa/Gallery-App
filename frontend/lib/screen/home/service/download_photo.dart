import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:gallery_app/alert/alert.dart';

Future<void> downloadPhoto(
    BuildContext context, String url, String fileName) async {
  try {
    FileDownloader.downloadFile(
      url: url,
      name: fileName,
      onProgress: (fileName, progress) {
        print('FILE $fileName HAS PROGRESS $progress');
      },
      onDownloadCompleted: (path) {
        print('Download completed: $path');
        showAlert(context, 'File successfully downloaded', true);
      },
      onDownloadError: (error) {
        print('Download error: $error');
        showAlert(context, 'Failed to download file', false);
      },
    );
  } catch (e) {
    print(e);
    showAlert(context, 'Failed to download file', false);
  }
}
