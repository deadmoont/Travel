import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel/screens/fav_screen.dart';
import 'package:travel/screens/recommend.dart';
import 'package:travel/screens/settings.dart';
import 'package:travel/screens/edit_profile.dart';
import 'package:travel/screens/trip_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:geolocator/geolocator.dart';

import 'dinning.dart';
import 'hotels.dart';
import 'nearbyattrac.dart';


class HomeScreen extends StatefulWidget {
  final Function(bool) toggleTheme; // Function to toggle the theme
  final bool isDarkMode;            // Boolean to store current theme mode

  const HomeScreen({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String userName = '';
  String userEmail = '';
  String profileImage = '';  // To store the profile image URL
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = userData['name'];
        userEmail = user.email!;
        profileImage = userData['profileImage'] ?? ''; // Get the profile image URL
      });
    }
  }

  // List of widgets for different navigation sections
  final List<Widget> _widgetOptions = <Widget>[
    const HomeSection(),
    TripScreen(), // Your existing TripScreen remains unchanged
    const Text('Explore Destinations'),
    const Text('Travel Tips'),
    FavScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Itinerary App'),
        backgroundColor: Colors.deepOrange,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  userName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              accountEmail: Text(userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : null,
                child: profileImage.isEmpty
                    ? Text(
                  userName.isNotEmpty ? userName[0] : '?',
                  style: const TextStyle(fontSize: 40.0, color: Colors.black),
                )
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      toggleTheme: widget.toggleTheme,
                      isDarkMode: widget.isDarkMode,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel_outlined),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
      ),
    );
  }

}


class HomeSection extends StatefulWidget {
  const HomeSection({Key? key}) : super(key: key);

  @override
  _HomeSectionState createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  final PageController _pageController = PageController();


  Future<void> _checkLocationPermissionAndNavigate() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled. Please enable them to find nearby attractions.')),
      );
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // If permissions are granted and location services are enabled, navigate to the NearbyAttractions page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NearbyAttractions()),
    );
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(  // Wrap Column inside SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Transform.translate(
            offset: Offset(0, -16), // Adjust this value to move the container up
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.0)),
              ),
              child: Text(
                'Explore Your Next Adventure!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 220, // Increased height for better visuals
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0), // More pronounced curve
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: PageView(
                controller: _pageController,
                children: [
                  _buildPage('Find Nearby Attractions', 'assets/images/attractions.jpg', Colors.teal),
                  _buildPage('Book Accommodations', 'assets/images/accomodations.jpg', Colors.blue),
                  _buildPage('Discover Dining Options', 'assets/images/dining.jpg', Colors.red),
                  _buildPage('Check Upcoming Events', 'assets/images/events.jpg', Colors.purple),
                  _buildPage('Travel Essentials', 'assets/images/essentials.jpg', Colors.orange),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 5,
              effect: ExpandingDotsEffect(
                activeDotColor: Colors.deepOrange,
                dotColor: Colors.black.withOpacity(0.5),
                dotHeight: 10, // Slightly larger dot for better visibility
                dotWidth: 10,
                spacing: 16,
              ),
            ),
          ),
          SizedBox(height: 32), // Add spacing between card view and slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Recommended Places',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16),
          RecommendationSlider(),
          SizedBox(height: 16), // Add the RecommendationSlider widget here
        ],
      ),
    );
  }

  Widget _buildPage(String title, String imagePath, Color color) {
    return GestureDetector(
      onTap: () async {
        if (title == 'Find Nearby Attractions') {
          _checkLocationPermissionAndNavigate();
        }else if (title == 'Book Accommodations') {
          // Check if location services are enabled
          if (await Geolocator.isLocationServiceEnabled()) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Hotels()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enable location services to book accommodations.')),
            );
          }
        }
        if (title == 'Discover Dining Options') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DinnerScreen()),
          );
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0), // Ensure the image follows the border radius
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.3)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(24.0), // Ensure the gradient also follows the border radius
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: [
                    Shadow(
                      blurRadius: 6.0,
                      color: Colors.black.withOpacity(0.7),
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }


}


