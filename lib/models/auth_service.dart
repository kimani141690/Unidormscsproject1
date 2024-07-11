import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  // Validate password
  String? validatePassword(String password, String email) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    if (password.contains(email.split('@')[0])) {
      return 'Password must not contain your email name.';
    }

    return null;
  }

  // Register with email and password
  Future<String?> registerWithEmailAndPassword(String username, String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'phoneNumber': null, // Initialize phoneNumber to null
          'roomNumber': null,  // Initialize roomNumber to null
          'profileImage': null, // Initialize profileImage to null
          'role': 'student',
        });
        return user.uid;
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified(User user) async {
    await user.reload();
    return user.emailVerified;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        print('Google Sign-In aborted by user');
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user is already in Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Add user to Firestore if not already present
          await _firestore.collection('users').doc(user.uid).set({
            'username': user.displayName ?? 'Google User',
            'email': user.email,
            'phoneNumber': null, // Initialize phoneNumber to null
            'profileImage': null, // Initialize profileImage to null
            'role': 'student',
          });
        }
      }
    } catch (e) {
      print('Error during Google Sign-In: ${e.toString()}');
    }
  }

  // Perform login with email and password
  Future<bool> performLogin(String email, String password) async {
    try {
      UserCredential result = await signInWithEmailAndPassword(email, password);
      User? user = result.user;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Check if the current user is an admin
  Future<bool> isAdmin(User user) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists && userDoc.get('role') == 'admin';
  }

  Future<bool> isStudent(User user) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc['role'] == 'student') {
      return true;
    }
    return false;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
