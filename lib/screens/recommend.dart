import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecommendationSlider extends StatefulWidget {
  @override
  _RecommendationSliderState createState() => _RecommendationSliderState();
}

class _RecommendationSliderState extends State<RecommendationSlider> {
  // Set up the PageController with an initial page of 0 and viewportFraction to show 3 items
  final PageController _pageController = PageController(
    viewportFraction: 0.33, // Shows 3 items at once
    initialPage: 0, // Ensure it starts from the first page
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('places').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No recommendations available.'));
        }

        List<DocumentSnapshot> places = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: places.length,
                itemBuilder: (context, index) {
                  var place = places[index].data() as Map<String, dynamic>;

                  String title = place['name'] ?? 'No Title';
                  String description = place['description'] ?? 'No Description';
                  String imageUrl = place['imageUrl'] ?? 'https://via.placeholder.com/500x160';
                  double rating = (place['rating'] is double)
                      ? place['rating'] as double
                      : (place['rating'] is int)
                      ? (place['rating'] as int).toDouble()
                      : 0.0;

                  // Apply a negative offset to shift the elements to the left
                  return Transform.translate(
                    offset: Offset(-110.0, 0.0),  // Negative value for left shift
                    child: GestureDetector(
                      onTap: () {
                        _showDescription(context, title, description);
                      },
                      child: _buildPage(
                        title,
                        imageUrl,
                        rating,
                      ),
                    ),
                  );
                },
              ),
            )
            ,

            SizedBox(height: 16),
            // Removed SmoothPageIndicator as per request
          ],
        );
      },
    );
  }

  Widget _buildPage(String title, String imageUrl, double rating) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0), // Adjusted margin for better spacing
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.error, color: Colors.red)),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 6.0,
                          color: Colors.black.withOpacity(0.7),
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rating: ${rating.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                      shadows: [
                        Shadow(
                          blurRadius: 6.0,
                          color: Colors.black.withOpacity(0.7),
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDescription(BuildContext context, String title, String description) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
