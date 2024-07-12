import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../colors.dart';
import 'bottom_navigation.dart';
import 'room_details.dart';

class CatalogueScreen extends StatefulWidget {
  @override
  _CatalogueScreenState createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  List<String> categories = [
    'All',
    'Single Room',
    '2 Bed Room',
    '4 Bed Room'
  ];
  late Future<List<DocumentSnapshot>> roomsFuture;

  @override
  void initState() {
    super.initState();
    roomsFuture = _fetchRooms();
  }

  Future<List<DocumentSnapshot>> _fetchRooms() async {
    QuerySnapshot querySnapshot;
    if (_selectedCategory == 'All') {
      querySnapshot = await FirebaseFirestore.instance.collection('rooms').get();
    } else {
      String roomType;
      switch (_selectedCategory) {
        case 'Single Room':
          roomType = 'Single Bed Delux Room';
          break;
        case '2 Bed Room':
          roomType = '2-Bed Room Deluxe Room';
          break;
        case '4 Bed Room':
          roomType = '4-Bed Deluxe Room';
          break;
        default:
          roomType = 'All';
      }
      querySnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('roomType', isEqualTo: roomType)
          .get();
    }
    return querySnapshot.docs;
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      roomsFuture = _fetchRooms();
    });
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (index == 0) {
        Navigator.of(context).pushReplacementNamed('/notice');
      }
    });
  }

  void _showRoomNotAvailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room not available'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8DBAC4),
        title: Text('Catalogue', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/homepage.jpg',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () => _onCategorySelected(category),
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedCategory == category
                          ? AppColors.backlight
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: _selectedCategory == category
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Room List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: roomsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error fetching rooms'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No rooms available'));
                } else {
                  // Use a Set to track displayed rooms to avoid duplicates
                  Set<String> displayedRooms = Set();

                  return ListView(
                    children: snapshot.data!.where((roomDoc) {
                      final roomId = roomDoc.id;
                      if (displayedRooms.contains(roomId)) {
                        return false;
                      } else {
                        displayedRooms.add(roomId);
                        return true;
                      }
                    }).map((roomDoc) {
                      Map<String, dynamic> roomData =
                      roomDoc.data() as Map<String, dynamic>;
                      bool isAvailable = roomData['status'] == 'Available';

                      return GestureDetector(
                        onTap: isAvailable
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoomDetailsScreen(roomData: roomDoc),
                            ),
                          );
                        }
                            : _showRoomNotAvailableMessage,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  roomData['roomType'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 10),
                                CachedNetworkImage(
                                  imageUrl: roomData['image'],
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Available Capacity: ${roomData['availableCapacity']}',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Status: ${roomData['status']}',
                                      style: TextStyle(
                                        color: isAvailable
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
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
