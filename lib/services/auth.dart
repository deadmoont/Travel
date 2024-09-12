import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get current user's data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      String? userId = getCurrentUserId();
      if (userId != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Method to get the current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // SignUp User
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // Register user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Add user to Firestore database
        await _firestore.collection("users").doc(cred.user!.uid).set({
          'name': name,
          'uid': cred.user!.uid,
          'email': email,
        });

        res = "success";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }


  Future<void> updateUserProfile(Map<String, dynamic> userProfile) async {
    try {
      // Fetch current user ID
      String? userId = getCurrentUserId();

      // Check if userId is valid
      if (userId == null) {
        print('User not logged in or userId is null.');
        return;
      }

      // Check if the document for the user exists
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        // Handle case where the user document doesn't exist
        print('User document does not exist.');
        return;
      }

      // Log the userProfile data for debugging
      print('Updating user profile with: $userProfile');

      // If user document exists, update profile data
      await userDocRef.update(userProfile);
      print('User profile updated successfully.');
    } catch (e) {
      print('Error updating user profile: $e');
      throw ('Failed to update profile: $e');
    }
  }



  // LogIn user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // SignOut
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
