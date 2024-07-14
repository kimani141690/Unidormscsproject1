import 'package:flutter/material.dart';
import 'package:unidorms/screens/write_reviews.dart';
import '../colors.dart';
import '../models/reviews_service.dart';
import 'bottom_navigation.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<Map<String, dynamic>> reviews = [];
  final ReviewService _reviewService = ReviewService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    List<Map<String, dynamic>> fetchedReviews = await _reviewService.fetchReviews();
    setState(() {
      reviews = fetchedReviews;
    });
  }

  void _showReviewDetails(BuildContext context, Map<String, dynamic> review) async {
    Map<String, dynamic> userData = await _reviewService.fetchUserData(review['userId']);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: userData['profileImage'] != null
                      ? NetworkImage(userData['profileImage'])
                      : AssetImage('assets/images/userAvatar.jpg') as ImageProvider,
                  radius: 40,
                ),
                SizedBox(height: 16),
                Text(
                  userData['username'] ?? 'User',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    );
                  }),
                ),
                SizedBox(height: 16),
                Text(review['review']),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close', style: TextStyle(color: AppColors.textBlack)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.of(context).pushReplacementNamed('/notice');
      } else if (index == 1) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (index == 2) {
        Navigator.of(context).pushReplacementNamed('/profile');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Reviews', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => WriteReviewScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                ),
                child: Text('Write Review', style: TextStyle(color: AppColors.textBlack)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('${review['username']} (${review['rating']} stars)'),
                    subtitle: Text(review['review'].length > 30
                        ? '${review['review'].substring(0, 30)}...'
                        : review['review']),
                    onTap: () => _showReviewDetails(context, review),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        context: context,
      ),
    );
  }
}
