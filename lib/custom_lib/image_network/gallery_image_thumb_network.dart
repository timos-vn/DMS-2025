import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../gallery_item_models.dart';

// to show image in Row
class GalleryItemThumbNetWork extends StatelessWidget {

  final int tag;

  const GalleryItemThumbNetWork({Key? key,required this.tag, required this.galleryItemModelNetWork, this.onTap, })
      : super(key: key);

  final GalleryItemModelNetWork galleryItemModelNetWork;

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: "${galleryItemModelNetWork.id}-$tag",
        child: Image.network(
          galleryItemModelNetWork.imageUrl,
          height: 100.0,
          cacheHeight: 150,cacheWidth: 150,
          fit: BoxFit.cover,
        ),
      )
    );
  }
}
