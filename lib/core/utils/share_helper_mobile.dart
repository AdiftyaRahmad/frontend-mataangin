import 'package:share_plus/share_plus.dart';

/// Shares a single file located at [filePath] using the native share sheet.
///
/// The optional [mimeType] and [text] parameters are passed to the underlying
/// Share API when supported. This implementation is used on mobile platforms
/// (Android/iOS) via conditional import from `share_helper.dart`.
Future<void> shareFile(String filePath, {String? mimeType, String? text}) async {
  // Convert the file path to an XFile, which is required by the newer API.
  final xFile = XFile(filePath, mimeType: mimeType);
  // ignore: deprecated_member_use
  await Share.shareXFiles([xFile], text: text);
}