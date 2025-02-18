import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freezebook/videoplayer.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class TikTokCloneApp extends StatefulWidget {
  @override
  _TikTokCloneAppState createState() => _TikTokCloneAppState();
}

class _TikTokCloneAppState extends State<TikTokCloneApp> {
  List<String> videoPaths = [];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    requestPermissions();
    fetchVideos();
  }

  Future<void> requestPermissions() async {
    // Check current permission status
    var status = await Permission.storage.status;
    print("Storage permission status: $status");

    if (status.isGranted) {
      // Permissions already granted, proceed to fetch videos
      fetchVideos();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Request permission
      if (await Permission.storage.request().isGranted) {
        // Permissions granted, proceed to fetch videos
        fetchVideos();
      } else {
        // Handle the case where permissions are denied
        print("Storage permission denied");
        // Open app settings to allow the user to grant permission manually
        openAppSettings();
      }
    }
  }
  Future<List<String>> fetchVideosFromLocalStorage() async {
    List<String> videoPaths = [];
    List<FileSystemEntity> _files = [];
    String _directoryPath = '/storage/emulated/0/DCIM/Camera';
    // Access the public DCIM/Camera directory
    Directory directory = Directory('/storage/emulated/0/DCIM/Camera');

    if (await directory.exists()) {
      List<FileSystemEntity> files = directory.listSync(recursive: true);
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp4')) {
          videoPaths.add(file.path);
        }
      }
    } else {
      print("Directory does not exist: ${directory.path}");
    }
    print("directory $directory");
    print("asdasdas $videoPaths");
    return videoPaths;

  }

  Future<void> fetchVideos() async {
    List<String> paths = await fetchVideosFromLocalStorage();
    setState(() {
      videoPaths = paths;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videoPaths.length,
        itemBuilder: (context, index) {
          return VideoPlayerWidget(videoPath: videoPaths[index]);
        },
      ),
    );
  }
}