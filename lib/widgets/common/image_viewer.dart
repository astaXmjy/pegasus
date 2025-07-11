import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../core/constants/app_colors.dart';
import 'dart:io';

class ImageViewer extends StatelessWidget {
  final String imagePath;
  final String? heroTag;

  const ImageViewer({
    Key? key,
    required this.imagePath,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _shareImage(context),
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () => _downloadImage(context),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: _getImageProvider(),
        heroAttributes:
            heroTag != null ? PhotoViewHeroAttributes(tag: heroTag!) : null,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }

  void _shareImage(BuildContext context) {
    // TODO: Implement image sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image sharing coming soon!')),
    );
  }

  void _downloadImage(BuildContext context) {
    // TODO: Implement image download to gallery
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image download coming soon!')),
    );
  }

  static void show(BuildContext context, String imagePath, {String? heroTag}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          imagePath: imagePath,
          heroTag: heroTag,
        ),
      ),
    );
  }
}
