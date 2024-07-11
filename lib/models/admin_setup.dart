import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> adminSetup() async {
  await Firebase.initializeApp();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  const adminEmail = 'admin@gmail.com';
  const adminPassword = 'admin123';
  const adminUsername = 'Admin';

  try {
    // Check if admin already exists
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('email', isEqualTo: adminEmail)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isNotEmpty) {
      print('Admin already exists');
      return;
    }

    // Create admin user
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: adminEmail,
      password: adminPassword,
    );
    User? user = userCredential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'username': adminUsername,
        'email': adminEmail,
        'role': 'admin',
      });
      print('Admin user created successfully');
    }
  } catch (e) {
    print('Error creating admin user: $e');
  }
}
