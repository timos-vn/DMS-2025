import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../custom_lib/view_only_image.dart';
import '../../../../../themes/colors.dart';
import 'optimized_image_widget.dart';

class ImageAttachmentSection extends StatelessWidget {
  final List<File> imageFiles;
  final bool isLoading;
  final VoidCallback onAddImage;
  final Function(int) onRemoveImage;
  final Function(int, File) onImageTap;

  const ImageAttachmentSection({
    Key? key,
    required this.imageFiles,
    required this.isLoading,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        _buildImageContainer(context),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
      child: Text(
        'Đính kèm hình ảnh',
        style: TextStyle(color: subColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            _buildAddImageButton(),
            const SizedBox(height: 16),
            _buildImageList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: onAddImage,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 15, top: 8, bottom: 8),
        height: 40,
        width: double.infinity,
        color: Colors.amber.withOpacity(0.4),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ảnh của bạn',
              style: TextStyle(color: Colors.black, fontSize: 13),
            ),
            Icon(Icons.add_a_photo_outlined, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList() {
    if (imageFiles.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Hãy chọn thêm hình của bạn từ thư viện ảnh hoặc camera',
            style: TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: imageFiles.length,
          itemBuilder: (context, index) {
            return _buildImageItem(index);
          },
        ),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Stack(
        children: [
          Hero(
            tag: index,
            child: OptimizedImageWidget(
              imageFile: imageFiles[index],
              onTap: () => onImageTap(index, imageFiles[index]),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: () => onRemoveImage(index),
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(.7),
                ),
                child: const Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void openImageFullScreen(BuildContext context, int indexOfImage, File fileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperViewOnly(
          titleGallery: "Zoom Image",
          galleryItemsFile: fileImage,
          viewNetWorkImage: false,
          backgroundDecoration: const BoxDecoration(
            color: Colors.white,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
