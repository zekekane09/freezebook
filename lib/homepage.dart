import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:freezebook/playersDistributionOneLine.dart';
import 'package:freezebook/pusoy13game.dart';
import 'package:freezebook/utils/sharedpreferencesextension.dart';
import 'package:freezebook/videoscrollerapp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game/distributecard.dart';
import 'homescreen.dart'; // Ensure other screens are imported
import 'loginpage.dart';
import 'menuscreen.dart';
import 'movie_explorer_app.dart';
import 'notificationscreen.dart'; // Import your NotificationScreen

class Homepage extends StatefulWidget {

  const Homepage({super.key,});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  get username => null;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);
   
    
  }
  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onTabChanged() async {
    if (_tabController.index == 2) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getStringKey(SharedPreferencesKeys.playerId);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  Pusoy13Game(username: username)),
      );
    } else if ((_tabController.index == 4)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  DistributeCard()),
      );
    } else if ((_tabController.index == 5)){
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  PlayersDistributionOneLine()),
      );
    }
    else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    }
  }


  @override
  Widget build(BuildContext context) {
    
    return WillPopScope(
      onWillPop: () async {
        return await _showLogoutDialog(context);
      },
      child: Scaffold(
        body: Container(
          color: Colors.grey,
          child: Column(
            children: [
              // Main Content
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    children: [
                      // Header
                      Builder(
                        builder: (context) {
                          final tabIndex = _tabController.index;
                          return tabIndex == 0
                              ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text("Freezebook", style: TextStyle(color: Colors.white, fontSize: 30)),
                                Spacer(),
                                Row(
                                  children: [
                                    Icon(Icons.add_circle, color: Colors.white),
                                    SizedBox(width: 10),
                                    Icon(Icons.search, color: Colors.white),
                                    SizedBox(width: 10),
                                    Icon(Icons.email, color: Colors.white),
                                  ],
                                ),
                              ],
                            ),
                          )
                              : SizedBox.shrink();
                        },
                      ),
                      // Tab Bar
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Color(0xc64d4dfa),
                        labelColor: Color(0xc64d4dfa),
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(icon: Icon(Icons.home)),
                          Tab(icon: Icon(Icons.video_collection)),
                          Tab(icon: Icon(Icons.person)),
                          Tab(icon: Icon(Icons.shopping_cart)),
                          Tab(icon: Icon(Icons.notifications)),
                          Tab(icon: Icon(Icons.menu)),
                        ],
                      ),
                      // Tab Content
                      
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            HomeScreen(),
                            CreateGameScreen(),
                            Pusoy13Game(
                              username: username,
                            ),
                            TikTokCloneApp(),
                            DistributeCard(),
                            PlayersDistributionOneLine(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout or Close App?'),
        content: Text('Do you want to log out or close the app?'),
        actions: [
          TextButton(
            onPressed: () {
              // Log out the user
              Navigator.of(context).pop(false); // Return false to prevent closing the app
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
              );
            },
            child: Text('Logout'),
          ),
          TextButton(
            onPressed: () {
              // Close the app
              Navigator.of(context).pop(true); // Return true to allow closing the app
            },
            child: Text('Close App'),
          ),
        ],
      ),
    )) ?? false; // Default to false if dialog is dismissed
  }
}