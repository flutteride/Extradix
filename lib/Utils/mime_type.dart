//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:mime/mime.dart';

bool isImage(String path) {
  final mimeType = lookupMimeType(path);

  return mimeType!.startsWith('image/');
}

bool isVideo(String path) {
  final mimeType = lookupMimeType(path);

  return mimeType!.startsWith('video/') ||
      mimeType.contains('mp4') ||
      mimeType.contains('video');
}
