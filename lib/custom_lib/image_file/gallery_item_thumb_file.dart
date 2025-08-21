import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../gallery_item_models.dart';

// to show image in Row
class GalleryItemThumbFile extends StatelessWidget {

  final int tag;

  const GalleryItemThumbFile({Key? key,required this.tag,required this.galleryItemModelFile, this.onTap,})
      : super(key: key);

  final GalleryItemModelFile galleryItemModelFile;

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: "${galleryItemModelFile.id}-$tag",
        child: Image.file(
          galleryItemModelFile.imageUrl,
          height: 100.0,
          cacheHeight: 150,cacheWidth: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
