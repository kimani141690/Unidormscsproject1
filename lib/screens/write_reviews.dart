import 'package:flutter/material.dart';
import '../colors.dart';
import '../models/reviews_service.dart';
import '../models/reviews_service.dart';
import 'bottom_navigation.dart';

class WriteReviewScreen extends StatefulWidget {
  @override
  _WriteReviewScreenState createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  int _currentIndex = 0;
  final ReviewService _reviewService = ReviewService();

  void _submitReview() async {
    if (_rating == 0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating and a review.')),
      );
      return;
    }

    try {
      await _reviewService.submitReview(_reviewController.text, _rating);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully.')),
      );

      // Clear the input fields
      _reviewController.clear();
      setState(() {
        _rating = 0;
      });

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
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
        title: Text('Write a Review', style: TextStyle(color: AppColors.textBlack)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.0), // Add space after the app bar
            Text('Rate the place:', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                  ),
                  color: Colors.amber,
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Write your review',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _submitReview,
                child: Text('Submit Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        context: context,
      ),
    );
  }
}
