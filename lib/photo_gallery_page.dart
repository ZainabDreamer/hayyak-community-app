// By : Lubna 
// Design in Flutter : Zainab Alaujami
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenGalleryPage extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final int initialIndex;

  const FullScreenGalleryPage({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenGalleryPage> createState() => _FullScreenGalleryPageState();
}

class _FullScreenGalleryPageState extends State<FullScreenGalleryPage> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, fit: BoxFit.contain);
    } else if (imagePath.startsWith('/')) {
      return Image.file(File(imagePath), fit: BoxFit.contain);
    } else {
      return Image.memory(base64Decode(imagePath), fit: BoxFit.contain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Center(child: _buildImage(image['image'])),
              Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'BY : @${image['username']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
