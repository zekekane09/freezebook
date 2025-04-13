import 'dart:async';
import 'dart:io'; // For File

import 'package:flutter/material.dart';

import 'api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _imagePaths = []; // List to store image paths
  late Future<List<dynamic>> _newsFeedFuture;
  final TextEditingController _postController = TextEditingController();
  bool _isPosting = false;
  @override
  void initState() {
    super.initState();
    fetchVideosFromLocalStorage(); // Fetch images when the widget is initialized
    _newsFeedFuture = getNewsFeed();
    getStories();
  }
  Future<List<dynamic>> getNewsFeed() async {

    return await ApiService.getNewsFeed();
  }
  void getStories() async{
    ApiService.getStories();
  }

  Future<void> fetchVideosFromLocalStorage() async {
    List<String> imagePaths = [];
    String directoryPath = '/storage/emulated/0/DCIM';
    Directory directory = Directory(directoryPath);

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Profile and Create Post Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            sliver: SliverToBoxAdapter(
              child: _buildProfileRow(),
            ),
          ),

          // Divider
          const SliverToBoxAdapter(
            child: Divider(color: Colors.grey, height: 1),
          ),

          // Image Carousel
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.23,
              child: _buildImageCarousel(),
            ),
          ),

          // Divider
          const SliverToBoxAdapter(
            child: Divider(color: Colors.grey, height: 1),
          ),

          // News Feed Posts
          FutureBuilder<List<dynamic>>(
            future: _newsFeedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text("Error: ${snapshot.error}",
                      style: TextStyle(color: Colors.white))),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text("No news feed available",
                      style: TextStyle(color: Colors.white))),
                );
              }

              final posts = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPostItem(posts[index]),
                  childCount: posts.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[850],
            title: const Text('Create Post', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _postController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isPosting)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_postController.text.isNotEmpty) {
                              await ApiService.createPost;
                            }
                          },
                          child: const Text('Post'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Extracted Widgets for better readability
  Widget _buildProfileRow() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.account_circle, size: 45),
          onPressed: () {},
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: _showCreatePostDialog, // Updated here
              child: const Text("What's on your mind?",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.account_box, color: Color(0xFF7eb022), size: 30),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _imagePaths.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 10 : 0, right: 7),
          child: GestureDetector(
            onTap: () => _showFullscreenImage(index),
            child: Stack(
              children: [
                Container(
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    image: DecorationImage(
                      image: FileImage(File(_imagePaths[index])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Positioned(
                  top: 5,
                  left: 5,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle,
                      size: 25,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostItem(dynamic post) {
    final playerPostData = post['_playerpostdata'];
    final List<dynamic> images = post['images'];

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: playerPostData?['profile_picture']?['url'] != null
                      ? NetworkImage(playerPostData!['profile_picture']['url'])
                      : null,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerPostData?['fullname'] ?? 'Unknown',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        post.containsKey('created_at')
                            ? timeAgo(post['created_at'])
                            : 'No date available',
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              post['textcontent'] ?? 'No content available',
              style: const TextStyle(color: Colors.white),
            ),
            if (images.isNotEmpty) ...[
              if (images.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final image = images[index];
                      return image?['url'] != null
                          ? Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Image.network(image['url'], height: 180),
                      )
                          : SizedBox.shrink();
                    },
                  ),
                )
            ],
          ],
        ),
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
  // late Animation<double> _animation;
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

    // _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController)
    //   ..addListener(() {
    //     setState(() {
    //       // This will update the UI with the current animation value
    //     });
    //   });

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

String timeAgo(int milliseconds) {
  final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final Duration difference = DateTime.now().difference(dateTime);

  if (difference.inDays > 7) {
    return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}