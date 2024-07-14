import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package
import '../colors.dart';
import 'bottom_navigation.dart';
import 'home_screen.dart';

class NoticeScreen extends StatefulWidget {
  @override
  _NoticeScreenState createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize AudioPlayer
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  void _fetchUnreadCount() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: currentUser?.uid)
        .where('isRead', isEqualTo: false)
        .get();

    setState(() {
      _notificationCount = querySnapshot.docs.length;
    });
  }

  void _playNotificationSound() async {
    await _audioPlayer.play(AssetSource('notification.mp3')); // Ensure you have a notification.mp3 file in assets/sounds/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Notification', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),

      ),
      body: Container(
        color: AppColors.textWhite,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: currentUser?.uid)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading notifications'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No notifications available'));
            }

            // Check for new notifications
            final newNotifications = snapshot.data!.docs
                .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isRead'] == false && data['timestamp'].toDate().isAfter(DateTime.now().subtract(Duration(seconds: 5)));
            })
                .toList();

            if (newNotifications.isNotEmpty) {
              _playNotificationSound();
              _fetchUnreadCount();
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final notification = snapshot.data!.docs[index];
                final data = notification.data() as Map<String, dynamic>;

                return _buildNoticeTile(
                  context,
                  data['message'] ?? 'Notification',
                  data['timestamp'].toDate().toString(),
                  notification.id,
                  data['isRead'] ?? false, // Ensure `isRead` exists
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        },
        notificationCount: _notificationCount,
        context: context, // Pass the context here
      ),
    );
  }

  Widget _buildNoticeTile(BuildContext context, String title, String subtitle, String notificationId, bool isRead) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0), // Add vertical spacing between tiles
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : AppColors.backgroundColor, // No background color if read
        boxShadow: isRead ? [] : [], // No shadow if read
        borderRadius: BorderRadius.circular(8), // Optional: add border radius if needed
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: () async {
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(notificationId)
              .update({'isRead': true});

          _fetchUnreadCount();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: Text(subtitle),
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: AppColors.textBlack),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
