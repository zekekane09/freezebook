import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController; // Declare the VideoPlayerController
  bool isFullScreen = false;
  bool isInitialized = false; // Track initialization state

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));

    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
      );
      setState(() {
        isInitialized = true; // Mark as initialized
      });
    } catch (e) {
      // Handle error (e.g., show a message to the user)
      print("Error initializing video player: $e");
    }
  }

  @override
  void dispose() {
    // Dispose of the ChewieController and VideoPlayerController
    _chewieController.dispose();
    _videoPlayerController.dispose(); // Dispose of the VideoPlayerController
    super.dispose();
  }

  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
      if (isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            if (isInitialized) // Check if initialized before using _chewieController
              Chewie(
                controller: _chewieController,
              )
            else
              CircularProgressIndicator(), // Show a loading indicator while initializing
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: Icon(
                  isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: toggleFullScreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}