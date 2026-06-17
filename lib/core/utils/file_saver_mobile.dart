import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> saveFile(List<int> bytes, String fileName, String mimeType) async {
  // Get the external storage directory (Downloads folder) if available,
  // otherwise fall back to the temporary directory.
  Directory? directory;
  try {
    // On Android, getExternalStorageDirectory points to primary external storage.
    directory = await getExternalStorageDirectory();
  } catch (_) {
    // ignore errors and fallback.
  }
  directory ??= await getTemporaryDirectory();

  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);
  // No explicit return needed; file is saved.
}
