import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../themes/colors.dart';



// to view image in full screen
class GalleryImageViewWrapperViewOnly extends StatefulWidget {
  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final int? initialIndex;
  final PageController pageController;
  final File? galleryItemsFile;
  final Axis scrollDirection;
  final String? titleGallery;
  final int? indexTag;
  final String? galleryItemsNetWork;
  final bool viewNetWorkImage;

  GalleryImageViewWrapperViewOnly({
    Key? key,
    this.loadingBuilder,
    this.titleGallery,
    this.backgroundDecoration,
    this.initialIndex,
    this.galleryItemsFile,
    this.scrollDirection = Axis.horizontal,this.indexTag, this.galleryItemsNetWork,required this.viewNetWorkImage
  })  : pageController = PageController(initialPage: initialIndex ?? 0),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GalleryImageViewWrapperLocalState();
  }
}

class _GalleryImageViewWrapperLocalState extends State<GalleryImageViewWrapperViewOnly> {
  final minScale = PhotoViewComputedScale.contained * 0.8;
  final maxScale = PhotoViewComputedScale.covered * 8;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: Container(
              decoration: widget.backgroundDecoration,
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: widget.viewNetWorkImage == true ? _buildImageNetWork : _buildImageFile,
                itemCount: 1,
                loadingBuilder: widget.loadingBuilder,
                backgroundDecoration: widget.backgroundDecoration,
                pageController: widget.pageController,
                scrollDirection: widget.scrollDirection,
              ),
            ),
          ),
        ],
      ),
    );
  }

// build image with zooming
  PhotoViewGalleryPageOptions _buildImageNetWork(BuildContext context, int index) {
    return PhotoViewGalleryPageOptions.customChild(
      child:
      Image.network( widget.galleryItemsNetWork!,
        // cacheHeight: 150,cacheWidth: 150,
        fit: BoxFit.contain
      ),
      initialScale: PhotoViewComputedScale.contained,
      minScale: minScale,
      maxScale: maxScale,
      heroAttributes: PhotoViewHeroAttributes(tag: "#${widget.indexTag}-$index"),
    );
  }

  // build image with zooming
  PhotoViewGalleryPageOptions _buildImageFile (BuildContext context, int index) {
    return PhotoViewGalleryPageOptions.customChild(
      child: Image.file(
        widget.galleryItemsFile!,fit: BoxFit.contain),
      initialScale: PhotoViewComputedScale.contained,
      minScale: minScale,
      maxScale: maxScale,
      heroAttributes: PhotoViewHeroAttributes(tag: "#${widget.indexTag}-$index"),
    );
  }

  buildAppBar(){
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.of(context).pop(),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.titleGallery.toString(),
                style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.search,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }
}
