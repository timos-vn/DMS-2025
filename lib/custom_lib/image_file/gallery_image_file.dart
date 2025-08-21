import 'dart:io';
import 'package:dms/custom_lib/gallery_image_view_local.dart';
import 'package:flutter/material.dart';

import '../gallery_item_models.dart';
import 'gallery_item_thumb_file.dart';
import '../get_empty_widget.dart';

class GalleryImageLocalFile extends StatefulWidget {
  final List<File> imageUrls;
  final String? titleGallery;
  final int numOfShowImages;

  const GalleryImageLocalFile(
      {Key? key,
        required this.imageUrls,
        this.titleGallery,
        this.numOfShowImages = 3,})
      : assert(numOfShowImages <= imageUrls.length),
        super(key: key);
  @override
  State<GalleryImageLocalFile> createState() => _GalleryImageState();
}

class _GalleryImageState extends State<GalleryImageLocalFile> {
  List<GalleryItemModelFile> galleryItems = <GalleryItemModelFile>[];
  List<GalleryItemModelNetWork> galleryItemNetWork = <GalleryItemModelNetWork>[];
  @override
  void initState() {
    buildItemsList(widget.imageUrls);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: galleryItems.isEmpty
            ? getEmptyWidget()
            : GridView.builder(
            primary: false,
            itemCount: galleryItems.length > 3
                ? widget.numOfShowImages
                : galleryItems.length,
            padding: const EdgeInsets.all(0),
            semanticChildCount: 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 0, crossAxisSpacing: 5),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  // if have less than 4 image w build GalleryItemThumbnail
                  // if have mor than 4 build image number 3 with number for other images
                  child: index < galleryItems.length - 1 &&
                      index == widget.numOfShowImages - 1
                      ? buildImageNumbers(index)
                      : GalleryItemThumbFile(
                    onTap: () {
                      openImageFullScreen(index);
                    }, galleryItemModelFile: galleryItems[index], tag: index,
                  ));
            }));
  }

// build image with number for other images
  Widget buildImageNumbers(int index) {
    return GestureDetector(
      onTap: () {
        openImageFullScreen(index);
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.expand,
        children: <Widget>[
          GalleryItemThumbFile(
            galleryItemModelFile: galleryItems[index],tag: index,
          ),
          Container(
            color: Colors.black.withOpacity(.7),
            child: Center(
              child: Text(
                "+${galleryItems.length - index}",
                style: const TextStyle(color: Colors.white, fontSize: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

// to open gallery image in full screen
  void openImageFullScreen(final int indexOfImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperLocal(
          titleGallery: "Zoom Image",
          viewNetWorkImage: true,
          backgroundDecoration: const BoxDecoration(
            color: Colors.white,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal,
          galleryItemsNetWork:  const [],
          galleryItemsFile:galleryItems,
        ),
      ),
    );
  }

// clear and build list
  buildItemsList(List<File> items) {
    galleryItems.clear();
    for (var item in items) {
      galleryItems.add(
        GalleryItemModelFile(id: "item", imageUrl: item),
      );
    }
  }
}
