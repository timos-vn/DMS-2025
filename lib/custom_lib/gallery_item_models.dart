import 'dart:io';

class GalleryItemModelNetWork {
  GalleryItemModelNetWork({required this.id, required this.imageUrl});
// id image (image url) to use in hero animation
  final String id;
  // image url
  final String imageUrl;
}


class GalleryItemModelFile {
  GalleryItemModelFile({required this.id, required this.imageUrl});
// id image (image url) to use in hero animation
  final String id;
  // image url
  final File imageUrl;
}
