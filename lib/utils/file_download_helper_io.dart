import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<bool> downloadFile(Uint8List bytes, String fileName) async {
  try {
    // Windows / Linux / macOS
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final directory = await getDownloadsDirectory();

      if (directory != null) {
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);

        debugPrint('File saved to: ${file.path}');
        return true;
      }

      return false;
    }

    // Android
    if (Platform.isAndroid) {
      final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );

      final directory = Directory(downloadPath);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('$downloadPath/$fileName');
      await file.writeAsBytes(bytes);

      debugPrint('QR saved to Downloads: ${file.path}');
      return true;
    }

    // iOS
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      debugPrint('File saved to: ${file.path}');
      return true;
    }

    return false;
  } catch (e, stackTrace) {
    debugPrint('Error saving file: $e');
    debugPrint('$stackTrace');
    return false;
  }
}
