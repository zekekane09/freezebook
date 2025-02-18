import 'dart:async';
import 'dart:io'; // For File

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _imagePaths = []; // List to store image paths

  @override
  void initState() {
    super.initState();
    fetchVideosFromLocalStorage(); // Fetch images when the widget is initialized
  }

  Future<void> fetchVideosFromLocalStorage() async {
    List<String> imagePaths = [];
    String _directoryPath = '/storage/emulated/0/DCIM/Camera';
    Directory directory = Directory(_directoryPath);

    if (await directory.exists()) {
      List<FileSystemEntity> files = directory.listSync(recursive: true);
      for (var file in files) {
        if (file is File &&
            (file.path.endsWith('.jpeg') || file.path.endsWith('.jpg'))) {
          imagePaths.add(file.path);
        }
      }
    } else {
      print("Directory does not exist: ${directory.path}");
    }

    setState(() {
      _imagePaths = imagePaths; // Update the state with the fetched image paths
    });
  }

  void _showFullscreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullscreenImageViewer(
          imagePaths: _imagePaths,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Profile and Create Post
          SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.account_circle, size: 45),
                onPressed: () {},
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextButton(
                    onPressed: () {},
                    child: Text("What's on your mind?",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.account_box, color: Color(0xFF7eb022), size: 30),
            ],
          ),

          Divider(color: Colors.grey),
          // Image Carousel
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.23,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    if (index == 0) SizedBox(width: 10),
                    // Add SizedBox before the first item
                    GestureDetector(
                      onTap: () => _showFullscreenImage(index),
                      // Show fullscreen on tap
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            margin: EdgeInsets.only(right: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              image: DecorationImage(
                                image: FileImage(File(_imagePaths[index])),
                                // Display the image
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5, // Adjust the position as needed
                            left: 5, // Adjust the position as needed
                            child: CircleAvatar(
                              radius: 15,
                              // Size of the user icon
                              backgroundColor: Colors.white,
                              // Background color of the circle
                              child: Icon(
                                Icons.account_circle, // User icon
                                size: 25, // Size of the icon
                                color: Colors.black, // Color of the icon
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Divider(color: Colors.grey),
          // Post
          Container(
            padding: EdgeInsets.all(13),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Axie Infinity MarketPlace",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text("NOUPHIA",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              SizedBox(width: 20),
                              Text("17m",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.more_vert, color: Colors.white),
                    Icon(Icons.menu, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FullscreenImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullscreenImageViewer(
      {super.key, required this.imagePaths, required this.initialIndex});

  @override
  _FullscreenImageViewerState createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with SingleTickerProviderStateMixin {

  late PageController _pageController;
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentIndex = 0;
  final int _displayDuration = 10; // Duration to display each image in seconds
  bool _isPaused = false; // To track if the timer is paused
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;


    // Initialize AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _displayDuration),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          // This will update the UI with the current animation value
        });
      });

    // Start the animation for the first image
    _animationController.forward();

    // Start the timer
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_isPaused) {
        if (_animationController.isCompleted) {
          // Move to the next image
          _currentIndex++;
          if (_currentIndex >= widget.imagePaths.length) {
            // If at the end of the list, stop the timer and go back
            _timer.cancel();
            Navigator.pop(context);
          } else {
            // Update the page controller to the next image
            _pageController.animateToPage(
              _currentIndex,
              duration: Duration(milliseconds: 300), // Animation duration
              curve: Curves.easeInOut, // Animation curve
            );
            // Reset and start the animation for the new image
            _animationController.reset();
            _animationController.forward();
          }
        } else {
          // Update the animation progress
          _animationController.forward();
        }
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true; // Set paused state
      _animationController.stop(); // Stop the animation
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false; // Set resumed state
      _animationController.forward(); // Resume the animation
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when disposing
    _pageController.dispose();
    _animationController.dispose(); // Dispose the animation controller
    _commentController.dispose(); // Dispose the comment controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView for images
          GestureDetector(
            onLongPressStart: (_) => _pauseTimer(), // Pause on long press
            onLongPressEnd: (_) => _resumeTimer(), // Resume on release
            onHorizontalDragStart: (_) => _pauseTimer(), // Pause on drag start
            onHorizontalDragEnd: (_) => _resumeTimer(), // Resume on drag end
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index; // Update current index on page change
                  _animationController
                      .reset(); // Reset animation for the new image
                  _animationController
                      .forward(); // Start animation for the new image
                });
                _pauseTimer();
              },
              itemBuilder: (context, index) {
                return Center(
                  child: Stack(
                    children: [
                      Image.file(
                        File(widget.imagePaths[index]),
                        fit: BoxFit.contain,
                      ),
                    ],
                  )
                );
              },
            ),
          ),
          // Progress Bar
          Positioned(
            top: 10, // Position the progress bar at the top
            left: 10,
            right: 10,
            child: LinearProgressIndicator(
              value: 1.0 - _animationController.value,
              // Invert the progress for the indicator
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          // User Icon
          Positioned(
            top: 10, // Adjust the position as needed
            left: 10, // Adjust the position as needed
            child: CircleAvatar(
              radius: 15, // Size of the user icon
              backgroundColor: Colors.white, // Background color of the circle
              child: Icon(
                Icons.account_circle, // User icon
                size: 30, // Size of the icon
                color: Colors.black, // Color of the icon
              ),
            ),
          ),
          // Comment Field
          Positioned(
            bottom: 50, // Position the comment field above the bottom
            left: 10,
            right: 10,
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                hintText: "Add a comment...",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

