import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewerPopup extends StatefulWidget {
  final List<File> imageFiles;
  final Function(int index) onDelete;

  const ImageViewerPopup({
    Key? key,
    required this.imageFiles,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ImageViewerPopup> createState() => _ImageViewerPopupState();
}

class _ImageViewerPopupState extends State<ImageViewerPopup> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _deleteCurrentImage() {
    if (widget.imageFiles.isNotEmpty) {
      widget.onDelete(currentIndex);

      if (currentIndex >= widget.imageFiles.length && currentIndex > 0) {
        currentIndex--;
      }

      if (mounted) {
        setState(() {});
      }

      if (widget.imageFiles.isEmpty) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.black.withOpacity(0.95),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: size.width * 0.8,
        height: size.height * 0.7,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: widget.imageFiles.isEmpty
                  ? const Center(
                child: Text("Không có ảnh", style: TextStyle(color: Colors.white)),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageFiles.length,
                  onPageChanged: (index) => setState(() => currentIndex = index),
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      child: Image.file(
                        widget.imageFiles[index],
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (widget.imageFiles.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${currentIndex + 1}/${widget.imageFiles.length}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _deleteCurrentImage,
                    icon: const Icon(Icons.delete),
                    label: const Text("Xoá"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
