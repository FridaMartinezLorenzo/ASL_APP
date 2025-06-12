import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:asl_app/themes/app_colors.dart';
import 'package:asl_app/themes/app_text_styles.dart';

class SpecialGestureCard extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final String videoPath; // nuevo

  const SpecialGestureCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.videoPath,
  });

  @override
  State<SpecialGestureCard> createState() => _SpecialGestureCardState();
}

class _SpecialGestureCardState extends State<SpecialGestureCard> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 180,
      child: PageView(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          // Video
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _isVideoInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 50,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: AppTextStyles.heading.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            _buildCarousel(),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
